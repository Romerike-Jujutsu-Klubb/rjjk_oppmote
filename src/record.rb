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

  def method_missing(m, *args)
    return attributes[m.to_s] if attributes.include?(m.to_s)
    puts "Unknown method: #{m} #{args} #{attributes}"
    super
  end

  def respond_to?(m)
    attributes.include?(m.to_s) || super
  end
end
