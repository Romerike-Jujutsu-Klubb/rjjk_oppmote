class Config
  def initialize(context)
    @context = context
    if exists?
      puts "Read config from #{filename.inspect}"
      @config = YAML.load_file(filename)
    else
      @config = {}
    end
  end

  def email
    @config[:email]
  end

  def password
    @config[:password]
  end

  def ok?
    email && password
  end

  def exists?
    File.exists? filename
  end

  def filename
    File.join(@context.files_dir.path, 'config.yml')
  end

  def to_s
    inspect
  end
end
