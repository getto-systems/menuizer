class Menuizer::Menu::Item < OpenStruct
  def initialize(opts)
    super
    @opts = opts
  end

  def title
    if title = @opts[:title]
      @opts[:title]
    else
      I18n.translate :"#{namespace}menuizer.#{item}", default: [:"activerecord.models.#{item}", "#{item}"]
    end
  end
  def path
    unless path = @opts[:path]
      case item
      when Symbol
        path = [item.to_s.pluralize.to_sym]
      end
    end

    if path
      if namespace
        [namespace[0..-2].to_sym,*path]
      else
        path
      end
    end
  end
end
