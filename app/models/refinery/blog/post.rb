require 'friendly_id'
require 'globalize'
require 'acts-as-taggable-on'
require 'seo_meta'

module Refinery
  module Blog
    class Post < Refinery::Core::BaseModel
      extend FriendlyId
      extend GlobalizeFinder
      include Refinery::Blog::Engine.helpers

      is_imageable

      STATES = %w(draft review live)

      translates :title, :status, :slug, :custom_slug, :body, :perex, include: :seo_meta

      class Translation
        is_seo_meta
      end

      # Delegate SEO Attributes to globalize3 translation
      seo_fields = ::SeoMeta.attributes.keys.map{|a| [a, :"#{a}="]}.flatten
      delegate(*(seo_fields << { to: :translation }))

      has_many :categorizations, dependent: :destroy, foreign_key: :blog_post_id
      has_many :categories, through: :categorizations, source: :blog_category

      has_many :blog_post_authors, dependent: :destroy, foreign_key: :blog_post_id
      has_many :authors, through: :blog_post_authors, source: :user

      # Docs for friendly_id http://github.com/norman/friendly_id
      friendly_id_options = { use: [:slugged, :reserved, :globalize],
                  reserved_words: %w(categories tags posts) }

      friendly_id :title, friendly_id_options

      acts_as_taggable
      acts_as_opengraph

      validates :title, presence: true,
                        uniqueness: true,
                        length: { maximum: Refinery::STRING_MAX_LENGTH },
                        format: { with: /\A[\w]+/ }
      validates :slug, allow_blank: true, length: { maximum: Refinery::STRING_MAX_LENGTH }
      validates :custom_slug, uniqueness: true, allow_blank: true, length: { maximum: Refinery::STRING_MAX_LENGTH }
      validates :authors, presence: true
      validates :source_url, allow_blank: true, length: { maximum: Refinery::STRING_MAX_LENGTH }
      validates :source_url_title, allow_blank: true, length: { maximum: Refinery::STRING_MAX_LENGTH }
      validates :status, allow_blank: true, inclusion: { in: STATES }

      class << self

        def by_month(date)
          where(published_at: date.beginning_of_month..date.end_of_month)
        end

        def by_year(date)
          where(published_at: date.beginning_of_year..date.end_of_year)
        end

        def published_dates_older_than(date)
          published_before(date).select(:published_at).map(&:published_at)
        end

        def recent(count)
          live.limit(count)
        end

        def popular(count)
          unscoped.order(access_count: :desc).limit(count)
        end

        def previous(item)
          published_before(item.published_at).reorder(published_at: :desc).first
        end

        def next(current_record)
          with_globalize(status: 'live').where('published_at > ?', current_record.published_at).reorder(published_at: :asc).first
        end

        def published_before(date=Time.now)
          with_globalize(status: 'live').where('published_at < ?', date)
        end
        alias_method :live, :published_before
      end

      def next
        self.class.next(self)
      end

      def prev
        self.class.previous(self)
      end

      def live?
        status == 'live' && published_at <= Time.now
      end

      def draft?
        status == 'draft'
      end

      def title
        return self[:title] if self[:title].present?
        translation = translations.detect {|t| t.title.present? }
        translation.title if translation
      end

      def featured_image
        @featured_image ||= images.first
      end

      def opengraph_title
        browser_title.presence || title
      end

      def opengraph_description
        meta_description.presence || perex.presence
      end

      def opengraph_site_name
        Refinery::Core.site_name
      end

      def opengraph_image
        if featured_image.present?
          featured_image.thumbnail(geometry: :medium).url(host: Refinery::Images.dragonfly_url_host)
        end
      end

      def publish
        translation.update_attribute(:status, 'live')
      end

      def unpublish
        translation.update_attribute(:status, 'draft')
      end

    private

      def should_generate_new_friendly_id?
        self[:slug] = custom_slug if custom_slug.present? || custom_slug != translation.custom_slug
        slug.blank?
      end

    end
  end
end
