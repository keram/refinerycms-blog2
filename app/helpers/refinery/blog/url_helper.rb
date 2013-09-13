module Refinery
  module Blog
    module UrlHelper

      def blog_post_path(post, locale = Globalize.locale)
        refinery.send(:"blog_post_#{locale}_path", post, locale: locale)
      end

      def blog_posts_path(locale = Globalize.locale)
        refinery.send(:"blog_posts_#{locale}_path", locale: locale)
      end

      def blog_category_path(category, locale = Globalize.locale)
        refinery.send(:"blog_category_#{locale}_path", category, locale: locale)
      end

      def blog_categories_path(locale = Globalize.locale)
        refinery.send(:"blog_categories_#{locale}_path", locale: locale)
      end

      def tagged_posts_path(tag, locale = Globalize.locale)
        refinery.send(:"tagged_posts_#{locale}_path", tag.name.parameterize, locale: locale)
      end

      def archive_posts_path(year, month=nil, locale = Globalize.locale)
        refinery.send(:"archive_posts_#{locale}_path", year, month, locale: locale)
      end

      def rss_feed_path(locale = Globalize.locale)
        refinery.send(:"rss_feed_#{locale}_path", locale: locale)
      end
    end
  end
end

