require "menuizer/version"
require "menuizer/menu"
require "menuizer/menu/item"

module Menuizer
  class << self
    def configure(namespace=nil)
      yield (config[namespace] ||= OpenStruct.new)
    end
    def menu(namespace=nil)
      Menu.new(namespace).tap{|menu|
        c = config[namespace]
        if c.respond_to?(:converter)
          c.converter.each do |key,block|
            menu.set_converter key, &block
          end
        end
        if c.respond_to?(:file_path) && path = c.file_path
          require "yaml"
          menu.load YAML.load_file(path)
        end
      }
    end

    private

      def config
        @config ||= {}
      end
  end
end
