class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def up

    create_table :tags do |t|
      t.string :name, null: false, index: true, unique: true
    end

    create_table :taggings do |t|
      t.references :tag,      null: false

      t.references :taggable, polymorphic: true, null: false
      t.references :tagger,   polymorphic: true

      t.string :context,      null: false

      t.datetime :created_at, null: false

      t.index :tag_id
      t.index [:taggable_id, :taggable_type, :context]
    end

  end

  def down
    drop_table :taggings
    drop_table :tags
  end
end
