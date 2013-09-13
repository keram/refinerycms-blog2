module Refinery
  module Blog
    class BlogController < ::ApplicationController
      helper Blog::Engine.helpers

      before_action :find_all_categories
      before_action :find_latest_posts
      before_action :find_tags

      before_action :find_page

      LATEST_POSTS_PER_PAGE = 7

      private

      def find_page
        @page ||= Page.live.includes(:translations).find_by(plugin_page_id: 'blog')
      end

      def find_latest_posts
        @latest_posts = Post.live.includes(:translations)
                            .with_globalize.paginate(page: 1, per_page: LATEST_POSTS_PER_PAGE)
                            .order(published_at: :desc)
      end

      def find_tags
        @tags = Post.live.tag_counts_on(:tags)
      end

      def find_all_categories
        @categories = Category.with_globalize
                    .includes(:categorizations, :translations)
                    .where.not(refinery_blog_categorization: { blog_post_id: nil }) #'refinery_blog_posts.id IS NOT NULL')
      end

      def paginate_per_page
        Blog.per_page
      end

    end
  end
end
