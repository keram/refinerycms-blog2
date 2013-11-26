module Refinery
  module Blog
    class PostsController < BlogController
      before_action :find_all_posts, only: [:index]
      before_action :paginate_all_posts, only: [:index]
      before_action :find_post, only: [:show]

      MAX_RESULTS = 256

      respond_to :html, :rss

      def index
        if request.format.rss?
          @posts = Post.with_globalize
                      .recent(max_results_for_rss)
                      .includes(:categories)
        end

        respond_with @posts do |format|
          format.html
          format.rss { render layout: false }
        end
      end

      def show
        @post.increment!(:access_count, 1) if @post.live? && !current_refinery_user

        present(@post)
      end

      def tagged
        @page = Page.find_by(plugin_page_id: 'blog_tags')
        @tag = params[:name].to_s
        @posts = Post.with_globalize.tagged_with(@tag).paginate(page: paginate_page, per_page: paginate_per_page)
      end

      def archive
        @page = Page.find_by(plugin_page_id: 'blog_archive')

        if params[:month].present?
          date = "#{params[:month]}/#{params[:year]}"
          archive_date = Time.parse(date)
          @date_title = ::I18n.l(archive_date, format: '%B %Y')
          @posts = Post.live.by_month(archive_date).paginate(page: paginate_page, per_page: paginate_per_page)
        else
          date = "01/#{params[:year]}"
          archive_date = Time.parse(date)
          @date_title = ::I18n.l(archive_date, format: '%Y')
          @posts = Post.live.by_year(archive_date).paginate(page: paginate_page, per_page: paginate_per_page)
        end
      end

      private

      def find_all_posts
        @posts = Post.live.with_globalize
                    .includes(:translations).references(:categories)
                    .order(published_at: :desc)
      end

      def paginate_all_posts
        find_all_posts if @posts.nil?
        @posts = @posts.paginate(page: paginate_page, per_page: paginate_per_page)
      end

      def blog_post
        if current_refinery_user && current_refinery_user.authorized_plugins.include?('blog')
          Post
        else
          Post.live
        end
      end

      def find_post
        @post ||= blog_post.includes(:translations).with_globalize(slug: params[:id].to_s).first

        @post || error_404
      end

      def draft_page?
        @page.status == 'draft' || (@post && @post.status != 'live')
      end

      def max_results_for_rss
        return MAX_RESULTS unless params[:max_results].present? || !params[:max_results].respond_to?(:to_i)
        [params[:max_results].to_i, MAX_RESULTS].min
      end

    end
  end
end
