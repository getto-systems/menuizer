class Menuizer::Menu::Item < OpenStruct
  def initialize(opts)
    super
    @opts = opts
  end

  def title
    if model && model.model_name.respond_to?(:human)
      model.model_name.human
    else
      @opts[:title]
    end
  end
  def path
    if path = @opts[:path]
      if path.respond_to?(:unshift)
        if namespace
          path.unshift namespace[0..-2].to_sym
        end
      end
      path
    else
      if model && model.model_name.respond_to?(:plural)
        :"#{namespace}#{model.model_name.plural}"
      end
    end
  end
end
