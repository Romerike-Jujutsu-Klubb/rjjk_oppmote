class GroupList
  include Ruboto::Activity::Reload

  def onCreate(bundle)
    super
    setTitle 'Grupper'

    self.content_view = linear_layout :orientation => LinearLayout::VERTICAL do
      @list_view = list_view :list => [], :id => 42,
          :on_item_click_listener => proc { |parent, view, position, id| show_group(view) }
    end
  rescue Object
    puts "Error in setup content: #{$!.message}"
    puts $!.backtrace.join("\n")
    toast 'Error in setup content'
  end

  def onResume
    super
    $db_helper ||= RjjkDatabaseHelper.new(self, 'main', nil, 1)
    puts "ListView: #{@list_view} #{@list_view.adapter.inspect}"
    update_groups
    # startService(Java::android.content.Intent.new($activity.application_context, Java::no.jujutsu.android.oppmote.WifiDetectorService.java_class))
    show_login_activity unless Config.new(self).ok?
  end

  def onCreateOptionsMenu(menu)
    menu.add('Sett passord').set_on_menu_item_click_listener do |menu_item|
      show_login_activity
      true
    end
    menu.add('Synkroniser').setOnMenuItemClickListener do |menu_item|
      java.lang.System.out.println 'Synchronize'
      Replicator.synchronize(self)
      java.lang.System.out.println 'Synchronizing...'
      toast 'Synchronizing with server'
      true
    end
    menu.add('Avslutt').setOnMenuItemClickListener do |menu_item|
      finish
      true
    end
    true
  end

  def update_groups
    with_large_stack :size => 256 do
      groups = load_groups
      puts "LOADED groups: #{@list_view} #{@list_view.adapter.inspect} #{groups}"
      if groups.empty?
        Replicator.synchronize(self)
      else
        run_on_ui_thread do
          @list_view.adapter.clear
          @list_view.adapter.add_all groups
        end
      end
    end
    puts 'Groups updated!'
  end

  private

  def show_login_activity
    i = Intent.new
    i.setClassName($package_name, 'org.ruboto.RubotoActivity')
    configBundle = android.os.Bundle.new
    configBundle.put_string('Script', 'login_activity.rb')
    i.putExtra('Ruboto Config', configBundle)
    startActivity(i)
  end

  def show_group(view)
    group_name = view.text
    i = Intent.new
    i.setClassName($package_name, $package_name + '.MemberList')
    i.putExtra('group_name', group_name)
    startActivity(i)
  end

  def load_groups
    db = $db_helper.getWritableDatabase
    puts 'Got DB!'
    groups = []
    c = db.rawQuery('SELECT name FROM groups', nil)
    while c.moveToNext
      groups << c.getString(0)
    end
    c.close
    db.close
    groups.to_java
  rescue
    puts "Exception loading groups: #{$!}"
  end

end
