require 'friendly_id'
require 'globalize'

module Refinery
  module Blog
    class Category < Refinery::Core::BaseModel
      extend FriendlyId
      extend GlobalizeFinder

      has_many :categorizations, dependent: :destroy, foreign_key: :blog_category_id
      has_many :posts, through: :categorizations, source: :blog_post

      translates :title, :slug

      validates :title, presence: true, uniqueness: true, length: { maximum: Refinery::STRING_MAX_LENGTH }
      # validates :slug, allow_blank: true, length: { maximum: Refinery::STRING_MAX_LENGTH }

      # Docs for friendly_id http://github.com/norman/friendly_id
      friendly_id_options = { use: [:slugged, :globalize] }
      friendly_id :title, friendly_id_options

      def title
        return self[:title] if self[:title].present?
        translation = translations.detect {|t| t.title.present? }
        translation.title if translation
      end

      alias_method :to_s, :title

      def should_generate_new_friendly_id?
        # slug.blank?
        true
      end

    private

    end
  end
end
