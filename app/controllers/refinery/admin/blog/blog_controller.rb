module Refinery
  module Admin
    module Blog
      class BlogController < ::Refinery::AdminController
        helper Refinery::Blog::Engine.helpers
      end
    end
  end
end
