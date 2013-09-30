module Refinery
  module Admin
    module Blog
      class PostsController < BlogController

        before_action :find_all_categories, except: :index
        before_action :find_all_users, except: :index

        crudify :'refinery/blog/post'

        def new
          @post = Refinery::Blog::Post.new
          @post.authors << current_refinery_user
          @post.categories << @categories.first if @categories.any?
        end

        private

        def redirect_url
          if @post.persisted? && @post.draft?
            refinery.edit_admin_blog_post_path(@post, frontend_locale_param)
          else
            refinery.admin_blog_posts_path(frontend_locale_param)
          end
        end

        def find_post
          if (id = params[:id].to_s).friendly_id?
            Globalize.with_locales(Refinery::I18n.frontend_locales) do |locale|
              @post ||= Refinery::Blog::Post.with_globalize(slug: id).first unless @post
            end
          else
            @post ||= Refinery::Blog::Post.find(id)
          end
        end

        def find_all_categories
          @categories = Refinery::Blog::Category.all
        end

        def find_all_users
          @users = Refinery::User.joins(:plugins).where('refinery_user_plugins.name = ?', refinery_plugin.name)
        end

        def post_params
          params[:post][:status] = 'live' if params[:publish].present?
          params.require(:post).permit(
              :title, :body, :teaser, :source_url,
              :source_url_title, :access_count,
              :status, :featured_image_id, :published_at,
              :tag_list, :custom_slug,
              :browser_title, :meta_description,
              category_ids: [],
              author_ids: []
          )
        end

        def paginate_per_page
          Refinery::Blog.per_admin_page
        end

      end
    end
  end
end
