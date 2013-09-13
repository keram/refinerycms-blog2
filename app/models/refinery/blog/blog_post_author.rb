module Refinery
  module Blog
    class BlogPostAuthor < ActiveRecord::Base

      self.table_name = 'refinery_blog_post_authors'
      belongs_to :blog_post, class_name: 'Refinery::Blog::Post', foreign_key: :blog_post_id
      belongs_to :user, class_name: 'Refinery::User', foreign_key: :user_id

    end
  end
end
