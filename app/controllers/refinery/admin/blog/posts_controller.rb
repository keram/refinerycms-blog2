module Refinery
  module Admin
    module Blog
      class PostsController < BlogController

        before_action :find_all_categories, except: :index
        before_action :find_all_users, except: :index

        crudify :'refinery/blog/post', order: 'published_at DESC'

        def new
          @post = Refinery::Blog::Post.new
          @post.authors << current_refinery_user
          @post.categories << @categories.first if @categories.any?
        end

        def show
          present(@post)
        end

        def toggle_publish
          find_post

          if @post.live?
            @post.unpublish

            flash.notice = t(
              'refinery.crudify.unpublished',
              kind: t(Refinery::Blog::Post.model_name.i18n_key, scope: 'activerecord.models'),
              what: @post.title
            )
          else
            @post.publish

            flash.notice = t(
              'refinery.crudify.published',
              kind: t(Refinery::Blog::Post.model_name.i18n_key, scope: 'activerecord.models'),
              what: @post.title
            )
          end

          render :edit
        end

        private

        def redirect_url
          if @post && @post.persisted?
            refinery.edit_admin_blog_post_path(@post,
              locale: params[:switch_frontend_locale].presence || Globalize.locale)
          else
            refinery.admin_blog_posts_path
          end
        end

        def find_post
          if (id = params[:id].to_s).present?
            Globalize.with_locales(Refinery::I18n.frontend_locales) do |locale|
              @post ||= Refinery::Blog::Post.with_globalize(slug: id).first
            end

            @post ||= Refinery::Blog::Post.find(id)
          end

          @post || error_404
        end

        def find_all_categories
          @categories = Refinery::Blog::Category.all
        end

        def find_all_users
          @users = Refinery::User.joins(:plugins).where('refinery_user_plugins.name = ?', refinery_plugin.name)
        end

        def post_params
          params.require(:post).permit(permitted_post_params)
        end

        def permitted_post_params
          @permitted_post_params ||= [
            :title, :body, :perex, :teaser, :source_url,
            :source_url_title, :access_count,
            :status, :published_at,
            :tag_list, :custom_slug,
            :browser_title, :meta_description,
            category_ids: [],
            author_ids: [],
            imagenizations_attributes: [
              :id, :image_id, :featured, :position,
              image_attributes: [:id, :alt, :caption]]]
        end

        def paginate_per_page
          Refinery::Blog.per_admin_page
        end

      end
    end
  end
end
