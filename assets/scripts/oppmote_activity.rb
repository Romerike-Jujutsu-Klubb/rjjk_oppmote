require 'ruboto.rb'

ruboto_import_widgets :TextView, :LinearLayout, :Button

$activity.handle_create do |bundle|
  setTitle 'This is the Title'

  setup_content do
    linear_layout :orientation => LinearLayout::VERTICAL do
      @text_view = text_view :text => "What hath Matz wrought?", :id => 42
      button :text => "M-x butterfly", :width => :wrap_content, :id => 43
    end
  end

  handle_click do |view|
    if view.getText == 'M-x butterfly'
      @text_view.setText "What hath Matz wrought!"
      toast 'Flipped a bit via butterfly'
    end
    true
  end

  Thread.start do
    require File.expand_path('setup_load_path', File.dirname(__FILE__))
    PROJECT_DIR = File.expand_path('..', File.dirname(__FILE__))
    SRC_DIR = "#{PROJECT_DIR}/scripts"
    DATA_DIR = "#{PROJECT_DIR}/data"
    FileUtils.mkdir_p(DATA_DIR)
    GEM_DIR = "#{PROJECT_DIR}/scripts/gems/1.8"
    ENV['GEM_PATH'] = GEM_DIR
    org.ruboto.Script.execLargeStack{require 'rubygems'}
    org.ruboto.Script.execLargeStack{require 'active_support'}
    require 'active_support/dependencies'

    $: << SRC_DIR
    ActiveSupport::Dependencies.autoload_paths << SRC_DIR
    $: << "#{SRC_DIR}/models"
    ActiveSupport::Dependencies.autoload_paths << "#{SRC_DIR}/models"
    $: << "#{PROJECT_DIR}/lib"
    ActiveSupport::Dependencies.autoload_paths << "#{PROJECT_DIR}/lib"

    require 'active_record'
  end

end
