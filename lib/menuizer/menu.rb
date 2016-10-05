class Menuizer::Menu
  def initialize(namespace)
    if namespace
      @namespace = "#{namespace}_"
      item_class = :"Item_#{namespace}"
      if self.class.const_defined?(item_class)
        @item_class = self.class.const_get(item_class)
      else
        @item_class = self.class.const_set(item_class, Class.new(Item))
      end
    else
      @namespace = nil
      @item_class = Item
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
    @active_item
  end
  def active_items
    result = []
    item = @active_item
    while item
      result << item
      item = item.parent
    end
    result.reverse
  end

  def set_converter(key,&block)
    @item_class.class_eval do
      define_method key do
        block.call @opts[key], @opts
      end
    end
  end

  def load(data)
    return unless data.respond_to?(:each)
    data.each do |item|
      if item.respond_to?(:map) && item.respond_to?(:delete)
        item = item.map{|k,v| [k.to_sym,v]}.to_h
        if title = item.delete(:header)
          add_header title
        else
          add_item item.delete(:item), item
        end
      end
    end
  end

  def items
    @items ||= []
  end

  private

    def add_header(title)
      current << @item_class.new(
        type: :header,
        namespace: @namespace,
        title: title,
      )
    end
    def add_item(title, opts)
      model = to_model title

      unless children = opts.delete(:children)
        item = @item_class.new(
          type: :item,
          parent: @parent,
          namespace: @namespace,
          title: title,
          model: model,
          **opts,
        )
        map[title] = item
        current << item
      else
        owner = @parent
        parents = @current
        item = @parent = @item_class.new(
          type: :tree,
          children: [],
          parent: owner,
          namespace: @namespace,
          title: title,
          model: model,
          **opts,
        )
        @current = item.children
        self.load children
        @current, @parent = parents, owner
        current << item
      end
    end
    def to_model(title)
      return unless title.is_a?(Symbol)
      parent = Object
      title.to_s.split("::").each do |tip|
        return unless parent.const_defined?(tip)
        parent = parent.const_get(tip)
      end
      if parent.respond_to?(:model_name)
        parent
      end
    end

    def current
      @current ||= items
    end
    def map
      @map ||= {}
    end
end
