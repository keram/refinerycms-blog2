module Refinery
  module Blog
    module Posts
      class << self

        def add_section_extra position, section_name, extra_name, &block
          @sections_extras ||= {}
          @sections_extras[:"#{position}_#{section_name}"] ||= {}
          @sections_extras[:"#{position}_#{section_name}"][extra_name] = block
        end

        def get_extras position, section_name
          return {} unless @sections_extras

          @sections_extras[:"#{position}_#{section_name}"] || {}
        end
      end
    end
  end
end
