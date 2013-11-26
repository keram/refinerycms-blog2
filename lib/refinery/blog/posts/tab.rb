module Refinery
  module Blog
    module Posts

      def self.tabs
        @tabs ||= []
      end

      class Tab
        attr_accessor :name, :partial, :templates

        def self.register(&block)
          tab = self.new

          yield tab

          raise "A tab MUST have a name!: #{tab.inspect}" if tab.name.blank?
          raise "A tab MUST have a partial!: #{tab.inspect}" if tab.partial.blank?

          tab.templates = %w[all] if tab.templates.blank?
          tab.templates = Array(tab.templates)

          tab
        end

      protected

        def initialize
          Refinery::Blog::Posts.tabs << self # add me to the collection of registered page tabs
        end
      end
    end
  end
end
