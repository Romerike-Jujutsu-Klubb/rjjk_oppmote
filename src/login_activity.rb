with_large_stack{require 'yaml'}

ruboto_import_widgets :Button, :EditText, :LinearLayout, :TextView

$activity.handle_create do |bundle|
  setTitle "Innlogging"

  setup_content do
    linear_layout :orientation => LinearLayout::VERTICAL do
      text_view :text => 'E-post:'
      @email_view = edit_text :width => :fill_parent
      text_view :text => 'Passord:'
      @password_view = edit_text :width => :fill_parent, :transformation_method => android.text.method.PasswordTransformationMethod.instance
      button :text => 'Lagre'
    end
  end

  handle_resume do
    filename = File.join(files_dir.path, 'config.yml')
    if File.exists? filename
      puts "Read config from #{filename.inspect}"
      config = YAML.load_file(filename)
      p config
    else
      config = {}
    end
    @email_view.text = config[:email]
    @password_view.text = config[:password]
  end

  handle_click do
    filename = File.join(files_dir.path, 'config.yml')
    with_large_stack do
      File.open(filename, 'w'){|f| f << YAML.dump({:email => @email_view.text.to_s, :password => @password_view.text.to_s})}
    end
    puts "Wrote config to #{filename.inspect}"
    finish
  end

end