class Menuizer::Menu::Item < OpenStruct
  def initialize(opts)
    super
    @opts = opts
  end

  def title
    title = @opts[:title]
    if title.respond_to?(:model_name) && title.model_name.respond_to?(:human)
      title.model_name.human
    else
      title
    end
  end
  def path
    if path = @opts[:path]
      path
    else
      title = @opts[:title]
      if title.respond_to?(:model_name) && title.model_name.respond_to?(:plural)
        :"#{namespace}#{title.model_name.plural}"
      end
    end
  end
end
