module Refinery
  module Blog
    class Engine < Rails::Engine
      extend Refinery::Engine
      isolate_namespace Refinery::Blog

      engine_name :refinery_blog

      initializer 'register blog plugin' do
        Refinery::Plugin.register do |plugin|
          plugin.name = 'blog'
          plugin.url = proc { Refinery::Core::Engine.routes.url_helpers.admin_blog_posts_path }
          plugin.pathname = root
          plugin.activity = {
            class_name: :'refinery/blog/post'
          }
        end

        Refinery::Dashboard.sidebar_actions.insert(1, '/refinery/admin/blog/dashboard_actions')
      end

      initializer 'register stylesheets' do
        Refinery::Core.config.register_stylesheet 'refinery/refinery-blog'
      end

      initializer 'reload routes' do
        Rails.application.routes_reloader.reload!
      end

      config.after_initialize do
        Refinery.register_extension(Refinery::Blog)
      end
    end
  end
end
