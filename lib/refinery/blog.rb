require 'refinerycms-core'
require 'globalize3'
require 'friendly_id'

module Refinery
  autoload :BlogGenerator, 'generators/refinery/blog/blog_generator'

  module Blog
    require 'refinery/blog/engine'
    require 'refinery/blog/configuration'

    autoload :Version, 'refinery/blog/version'

    class << self
      def root
        @root ||= Pathname.new(File.expand_path('../../../', __FILE__))
      end

      def comment_services
        @comment_services ||= %w(discus)
      end

      def sharing_services
        @sharing_service = %w(share_this)
      end
    end

  end
end
