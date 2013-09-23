plugin = Refinery::Plugins['blog']

if plugin
  if defined?(Refinery::User)
    Refinery::User.all.each do |user|
      if user.plugins.where(name: plugin.name).blank?
        user.plugins.create(name: plugin.name,
                            position: (user.plugins.maximum(:position) || -1) +1)
      end
    end
  end

  pages = {
    blog: {
      title: 'Blog',
      status: 'live',
      deletable: false,
      custom_slug: 'blog',
      plugin_page_id: plugin.name,
      page_type: 'Blog'
    },
    blog_categories: {
      title: 'Categories',
      status: 'live',
      parent: :blog,
      deletable: false,
      show_in_menu: false,
      custom_slug: 'categories',
      plugin_page_id: "#{plugin.name}_categories",
      page_type: 'CollectionPage'
    },
    blog_tags: {
      title: 'Tags',
      status: 'live',
      parent: :blog,
      deletable: false,
      show_in_menu: false,
      custom_slug: 'tagged',
      plugin_page_id: "#{plugin.name}_tags",
      page_type: 'CollectionPage'
    },
    blog_archive: {
      title: 'Archive',
      status: 'live',
      parent: :blog,
      deletable: false,
      show_in_menu: false,
      custom_slug: 'archive',
      plugin_page_id: "#{plugin.name}_archive",
      page_type: 'CollectionPage'
    }
  }

  Refinery::Pages::Import.new(plugin, pages, false).run

  unless Refinery::Blog::Category.any?
    Refinery::Blog::Category.create(title: 'Uncategorized')
  end

end
