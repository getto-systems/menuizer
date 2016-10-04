class Menuizer::Menu::Item < OpenStruct
  def initialize(public_hash,opts)
    super(public_hash)
    @opts = opts
  end

  def title
    if @opts[:title].respond_to?(:model_name) && @opts[:title].model_name.respond_to?(:human)
      @opts[:title].model_name.human
    else
      @opts[:title]
    end
  end
  def path
    if @opts[:path]
      @opts[:path]
    else
      if @opts[:title].respond_to?(:model_name) && @opts[:title].model_name.respond_to?(:plural)
        :"#{@opts[:namespace]}#{@opts[:title].model_name.plural}"
      end
    end
  end
end
