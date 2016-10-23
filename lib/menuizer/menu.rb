class Menuizer::Menu
  attr_reader :data

  def initialize(namespace,config,data)
    @config = config
    @data = data
    @parent = nil

    @namespace = namespace
    if @namespace
      @namespace = "#{namespace}_"
      item_class = :"Item_#{namespace}"
    else
      item_class = :ItemDefault
    end

    if self.class.const_defined?(item_class)
      @item_class = self.class.const_get(item_class)
    else
      @item_class = self.class.const_set(item_class, Class.new(Item))

      if converter = @config.converter
        @item_class.instance_eval do
          converter.each do |key,block|
            define_method key do
              block.call @opts[key], @opts
            end
          end
        end
      end
    end

    if path = @config.file_path
      require "yaml"
      if @config.cache
        yml = @config.yml ||= YAML.load_file(path)
      else
        yml = YAML.load_file(path)
      end
      load_data yml
    end
  end

  def activate(key)
    active_items.each do |item|
      item.is_active = false
    end

    @active_item = item = map[key]
    while item
      item.is_active = true
      item = item.parent
    end
  end
  def active_item
    @active_item ||= nil
  end
  def active_items
    result = []
    item = active_item
    while item
      result << item
      item = item.parent
    end
    result.reverse
  end

  def item(key)
    map[key]
  end

  def items
    @items ||= []
  end

  private

    def load_data(data)
      return unless data.respond_to?(:each)
      data.each do |item|
        if item.respond_to?(:map)
          item = item.map{|k,v| [k.to_sym,v]}.to_h
          if header = item.delete(:header)
            add_header header
          elsif items = item.delete(:items)
            if generator = @config.generator[items]
              load_data generator.call(self)
            end
          else
            add_item item.delete(:item), item
          end
        end
      end
    end

    def add_header(header)
      current << @item_class.new(
        type: :header,
        namespace: @namespace,
        title: header,
      )
    end
    def add_item(item, opts)
      props = {
        parent: @parent,
        namespace: @namespace,
        item: item,
      }

      unless children = opts.delete(:children)
        instance = @item_class.new(
          **opts,
          type: :item,
          **props,
        )
      else
        instance = @item_class.new(
          **opts,
          type: :tree,
          children: [],
          **props,
        )
        parents, owner = @current, @parent
        @current, @parent = instance.children, instance
        load_data children
        @current, @parent = parents, owner
      end

      current << instance
      map[item] = instance
    end

    def current
      @current ||= items
    end
    def map
      @map ||= {}
    end
end
