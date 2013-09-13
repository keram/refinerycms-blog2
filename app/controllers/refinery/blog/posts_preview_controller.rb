module Refinery
  module Blog
    class PostsPreviewController < PreviewsController
      helper Refinery::Core::Engine.helpers
      helper Blog::Engine.helpers

      before_action :set_post

      def show
        @page = Page.live.includes(:translations).find_by(plugin_page_id: 'blog')
      end

      private

      def post_params
        params.require(:post).permit(
            :title, :body, :teaser, :source_url,
            :source_url_title, :access_count,
            :status, :featured_image_id, :published_at,
            :tag_list, :custom_slug,
            :browser_title, :meta_description,
            category_ids: [],
            author_ids: [])
      end

      def set_post
        @post ||= if (id = params[:id].to_s).present?
          Post.find(id).tap { |post| post.attributes = post_params }
        else
          Post.new(post_params)
        end
      end

    end
  end
end
