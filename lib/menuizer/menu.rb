class Menuizer::Menu
  def initialize(namespace)
    @namespace = namespace ? "#{namespace}_" : nil
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
    result
  end


  def header(title)
    current << Item.new({
      type: :header,
    },{
      namespace: @namespace,
      title: title,
    })
  end
  def item(title, path: nil, **opts)
    unless block_given?
      item = Item.new({
        type: :item,
        parent: @parent,
        **opts,
      },{
        namespace: @namespace,
        title: title,
        path: path,
      })
      map[title] = item
      current << item
    else
      owner = @parent
      parents = @current
      item = @parent = Item.new({
        type: :tree,
        children: [],
        parent: owner,
        **opts,
      },{
        namespace: @namespace,
        title: title,
      })
      @current = item.children
      yield
      children, @current, @parent = @current, parents, owner
      current << item
    end
  end

  def items
    @items ||= []
  end

  private

    def current
      @current ||= items
    end
    def map
      @map ||= {}
    end

    def to_title(title)
      if title.respond_to?(:model_name)
        title.model_name.human
      else
        title
      end
    end
    def to_path(path:, title:)
      if path
        path
      else
        if title.respond_to?(:model_name)
          :"#{@namespace}#{title.model_name.plural}_path"
        end
      end
    end
end
