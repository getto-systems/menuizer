class Menuizer::Menu::Item < OpenStruct
  def initialize(opts)
    super
    @opts = opts
  end

  def title
    if title = @opts[:title]
      @opts[:title]
    else
      I18n.translate :"menuizer.#{item}", default: [:"activerecord.models.#{item}", "#{item}"]
    end
  end
  def path
    if path = @opts[:path]
      if namespace
        [namespace[0..-2].to_sym,*path]
      else
        path
      end
    else
      case item
      when Symbol
        if namespace
          [namespace[0..-2].to_sym,item]
        else
          [item]
        end
      end
    end
  end
end
