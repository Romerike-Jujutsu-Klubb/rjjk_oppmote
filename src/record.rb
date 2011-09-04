class Record
  attr_reader :attributes

  def initialize(*args)
    super()
    if args.size == 1 && args[0].is_a?(Hash)
      @attributes = args[0]
    end
  end

  def [](key)
    attributes[key]
  end

end