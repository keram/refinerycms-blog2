class CreateBlogPosts < ActiveRecord::Migration

  def up
    create_table :refinery_blog_posts do |t|
      t.string :slug, null: false
      t.string :source_url
      t.string :source_url_title
      t.integer :access_count,    null: false, default: 0
      t.datetime :published_at,   null: false

      t.timestamps null: false
    end

    Refinery::Blog::Post.create_translation_table!({
      title: { type: :string, null: false, default: '' },
      slug: { type: :string, null: false, default: '' },
      status: { type: :string, null: false, default: 'draft', limit: 16 },
      custom_slug: :string,
      body: :text,
      teaser: :text,
      perex: :text,
      teaser: :text
    })

    add_index :refinery_blog_post_translations, [:locale, :status, :slug], unique: true, name: 'index_on_locale_status_slug'

    create_table :refinery_blog_post_authors do |t|
      t.references :blog_post, null: false
      t.references :user, null: false
      t.index [:blog_post_id, :user_id], unique: true, name: 'index_blog_post_id_and_user_id'
    end

    create_table :refinery_blog_categories do |t|
      t.string :slug, null: false
      t.timestamps null: false
    end

    create_table :refinery_blog_categorization do |t|
      t.references :blog_post, null: false
      t.references :blog_category, null: false
      t.index [:blog_post_id, :blog_category_id], unique: true, name: 'index_post_id_and_category_id'
    end

    Refinery::Blog::Category.create_translation_table!({
      title: { type: :string, null: false, default: '' },
      slug: { type: :string, null: false, default: '' }
    })
  end

  def down
    if defined?(::Refinery::UserPlugin)
      ::Refinery::UserPlugin.destroy_all({ name: 'blog' })
    end

    if defined?(::Refinery::Page)
      ::Refinery::Page.delete_all({ plugin_page_id: 'blog' })
    end

    drop_table :refinery_blog_posts
    drop_table :refinery_blog_authors
    drop_table :refinery_blog_categories
    drop_table :refinery_blog_categorization

    Refinery::Blog::Post.drop_translation_table!
    Refinery::Blog::Category.drop_translation_table!
  end

end
