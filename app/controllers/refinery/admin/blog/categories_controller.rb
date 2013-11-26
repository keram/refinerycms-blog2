module Refinery
  module Admin
    module Blog
      class CategoriesController < BlogController

        crudify :'refinery/blog/category', paging: false

        private

        def redirect_url
          if @category && @category.persisted?
            refinery.edit_admin_blog_category_path(@category,
              locale: params[:switch_frontend_locale].presence || Globalize.locale)
          else
            refinery.admin_blog_categories_path
          end
        end

        def find_category
          if (id = params[:id].to_s).present?
            Globalize.with_locales(Refinery::I18n.frontend_locales) do |locale|
              @category ||= Refinery::Blog::Category.with_globalize(slug: id).first
            end

            @category ||= Refinery::Blog::Category.find(id)
          end

          @category || error_404
        end

        def category_params
          params.require(:category).permit(:title)
        end

      end
    end
  end
end
