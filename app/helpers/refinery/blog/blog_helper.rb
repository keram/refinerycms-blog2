module Refinery
  module Blog
    module BlogHelper

      # In the admin area we use a slightly different title
      # to inform the which pages are draft or hidden pages
      def record_meta_information(record)
        meta_information = ActiveSupport::SafeBuffer.new

        meta_information << content_tag(:span, class: 'label notice') do
          ::I18n.t('draft', scope: 'refinery.admin.pages.page')
        end if record.respond_to?(:draft?) && record.draft?

        meta_information << content_tag(:span, class: 'label important') do
          ::I18n.t('untranslated', scope: 'refinery.admin.pages.page')
        end if record.respond_to?(:translation) && record.translation.new_record?

        meta_information
      end

      # todo: make some nice OOP adapter
      def comment_service_for post
        case Refinery::Blog.comment_service
        when 'discus'
          disqus = {
            page: {
              identifier: dom_id(post),
            # title: ''
            # url: ''
            }
          }

          render partial: '/refinery/disqus/thread', locals: { options: disqus }
        end
      end

      # todo: make some nice OOP adapter
      def sharing_service_for post
        case Refinery::Blog.sharing_service
        when 'share_this'
          render partial: '/refinery/share_this/share_this', locals: { namespace: :blog_post }
        end
      end

      def posts_dates_group_by_year_from_date date
        Refinery::Blog::Post.order(published_at: :desc).
            published_dates_older_than(date).
            group_by {|date| date.year }
      end

      def oldest_post
        Refinery::Blog::Post.live.order(:published_at).first
      end

      def newest_post
        Refinery::Blog::Post.live.order(:published_at).last
      end

    end
  end
end
