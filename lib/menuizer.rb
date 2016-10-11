require "menuizer/version"
require "menuizer/menu"
require "menuizer/menu/item"

module Menuizer
  class << self
    def configure(namespace=nil)
      yield config_for_namespace(namespace)
    end
    def menu(namespace=nil)
      Menu.new namespace, config_for_namespace(namespace)
    end

    private

      def config
        @config ||= {}
      end
      def config_for_namespace(namespace)
        config[namespace] ||= OpenStruct.new
      end
  end
end
