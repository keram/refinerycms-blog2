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
      end

      initializer 'register blog to other engines and plugins' do
        Refinery::Dashboard.sidebar_actions.insert(1, '/refinery/admin/blog/dashboard_actions') if defined? Refinery::Dashboard

        if defined? Refinery::Links
          Refinery::Links.tabs.push('blog_posts')
        end
      end

      initializer 'register stylesheets' do
        Refinery::Core.config.register_stylesheet 'refinery/refinery-blog'
      end

      initializer 'register images tab' do
        Refinery::Blog::Posts::Tab.register do |tab|
          tab.name = 'imageable'
          tab.partial = '/refinery/admin/imagenization/tabs/images'
        end unless Refinery::Blog::Posts.tabs.collect(&:name).include?('imageable')
      end

      initializer 'reload routes' do
        # This condition is here because somehow, in testing, blog is loaded before authentication,
        #  and that probably cause this nasty error:
        # /gems/devise-3.2.2/lib/devise.rb:447:in `configure_warden!': undefined method `failure_app=' for nil:NilClass (NoMethodError)
        # from /devise-3.2.2/lib/devise/rails/routes.rb:20:in `finalize_with_devise!'
        # TODO definitely this needs to be fixed so for future me: FIXME FIXME please, please (your past me)
        if defined?(Refinery::User)
          Rails.application.routes_reloader.reload!
        end
      end

      config.after_initialize do
        Refinery.register_extension(Refinery::Blog)
      end
    end
  end
end
