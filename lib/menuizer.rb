require "menuizer/version"
require "menuizer/menu"

module Menuizer
  class << self
    def configure(namespace=nil)
      yield (map[namespace] = Menu.new(namespace))
    end
    def menu(namespace=nil)
      map[namespace]
    end

    private

      def map
        @map ||= {}
      end
  end
end