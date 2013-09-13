module Refinery
  module Blog
    class CategoriesController < BlogController

      def index
        # you can use meta fields from your model instead (e.g. browser_title)
        # by swapping @page for @category in the line below:
        present(@page)
      end

      def show
        @category ||= Category.includes(:translations).with_globalize(slug: params[:id])
      end

      private

      def find_page
        @page ||= Page.live.includes(:translations).find_by(plugin_page_id: 'blog_categories')
      end

    end
  end
end
