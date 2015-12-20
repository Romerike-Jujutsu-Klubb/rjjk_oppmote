with_large_stack { require 'yaml' }

ruboto_import_widgets :Button, :EditText, :LinearLayout, :TextView

class LoginActivity
  def onCreate(bundle)
    super
    setTitle 'Innlogging'

    window.soft_input_mode = WindowManager::LayoutParams::SOFT_INPUT_STATE_ALWAYS_VISIBLE

    self.content_view = linear_layout orientation: LinearLayout::VERTICAL do
      text_view text: 'E-post:', id: 42,
          input_type: InputType::TYPE_CLASS_TEXT | InputType::TYPE_TEXT_VARIATION_EMAIL_ADDRESS
      @email_view = edit_text width: :fill_parent
      text_view text: 'Passord:', id: 43
      @password_view = edit_text width: :fill_parent,
          transformation_method: android.text.method.PasswordTransformationMethod.instance
      button text: 'Lagre', on_click_listener: ->(*) { save_login }
    end
  end

  def onResume
    super
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

  def save_login
    filename = File.join(files_dir.path, 'config.yml')
    with_large_stack do
      File.open(filename, 'w') { |f| f << YAML.dump({:email => @email_view.text.to_s, :password => @password_view.text.to_s}) }
    end
    puts "Wrote config to #{filename.inspect}"
    finish
  end

end
