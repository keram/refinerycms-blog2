plugin = Refinery::Plugins['blog']
if plugin
  Refinery::Core::Engine.routes.draw do

    match 'preview/blog_post', via: [:post, :patch], to: 'blog/posts_preview#show', as: :preview_blog_post

    # Frontend routes
    if plugin.page.present? && Refinery::Pages.marketable_urls
      # For some strange reasons localized urls doesn't work when rules for archive are with
      # others in Globalize.with_locales block (categories, posts)
      # maybe some crazy internal sorting there happens, anyway I hope we will find explanation.
      Globalize.with_locales plugin.page.translated_locales do |locale|
        if plugin.archive_page.present?
          get "#{plugin.archive_page.nested_path}", to: 'blog/posts#archive_index'
          get "#{plugin.archive_page.nested_path}/:year(/:month)", to: 'blog/posts#archive', as: "blog_archive_posts_#{locale}"
        end
      end

      Globalize.with_locales plugin.page.translated_locales do |locale|
        get plugin.page.nested_path, to: 'blog/posts#index', as: "blog_posts_#{locale}"
        get "#{plugin.page.nested_path}/feed.rss", to: 'blog/posts#index', as: "rss_feed_#{locale}", defaults: { format: 'rss' }

        if plugin.categories_page.present?
          get plugin.categories_page.nested_path, to: 'blog/categories#index', as: "blog_categories_#{locale}"
          get "#{plugin.categories_page.nested_path}/:id", to: 'blog/categories#show', as: "blog_category_#{locale}"
        end

        if plugin.tags_page.present?
          get "#{plugin.tags_page.nested_path}/:name", to: 'blog/posts#tagged', as: "tagged_posts_#{locale}"
        end

        if plugin.posts_page.present?
          get "#{plugin.posts_page.nested_path}/:id", to: 'blog/posts#show', as: "blog_post_#{locale}"
        end
      end
    else

      namespace :blog do
        root to: 'posts#index'

        resources :posts, only: [:show]
        resources :categories, only: [:index, :show]

        get 'archive', to: 'posts#archive_index'
        get 'archive/:year(/:month)', to: 'posts#archive', as: 'archive_posts'
        get 'tagged/:tag_id(/:tag_name)', to: 'posts#tagged', as: 'tagged_posts'
        get 'feed.rss', to: 'posts#index', as: 'rss_feed', defaults: {format: 'rss'}
      end
    end


    # Admin routes
    namespace :admin, path: Refinery::Core.backend_route do
      namespace :blog do
        root to: 'posts#index'
        resources :posts, except: :show do
          post :toggle_publish, on: :member
        end

        resources :categories, except: :show
      end
    end
  end
end
