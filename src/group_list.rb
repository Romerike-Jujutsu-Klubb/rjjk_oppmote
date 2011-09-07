require 'ruboto'
require 'database'

ruboto_import_widgets :ListView, :TextView, :LinearLayout, :Button
java_import "android.content.Intent"

def load_groups
    db = $db_helper.getWritableDatabase
    groups = []
    c = db.rawQuery('SELECT name FROM groups', nil)
    while c.moveToNext
      groups << c.getString(0)
    end
    c.close
    db.close
  groups.to_java
end

def update_groups(list_view)
  with_large_stack :size => 256 do
    groups = load_groups
    run_on_ui_thread{list_view.adapter.clear ; groups.each{|g| list_view.adapter.add(g)}}
  end
end

$activity.handle_create do |bundle|
  puts '$activity.handle_create'
  begin
    setTitle 'Grupper'

    setup_content do
      puts 'setup_content'
      begin
        linear_layout :orientation => LinearLayout::VERTICAL do
          @list_view = list_view :list => []
        end
      rescue Object
        puts "Error in setup content: #{$!.message}"
        puts $!.backtrace.join("\n")
        toast 'Error in setup content'
      end
    end

    handle_resume do
      update_groups(@list_view)
    end

    handle_item_click do |parent, view, position, id|
      group_name = view.text
      i = Intent.new
      i.setClassName($package_name, $package_name + '.MemberList')
      i.putExtra("group_name", group_name)
      startActivity(i)
    end

    handle_create_options_menu do |menu|
      add_menu 'Sett passord' do
        i = Intent.new
        i.setClassName($package_name, 'org.ruboto.RubotoActivity')
        configBundle = android.os.Bundle.new
        configBundle.put_string('Script', 'login_activity.rb')
        i.putExtra("RubotoActivity Config", configBundle)
        startActivity(i)
      end
      add_menu 'Synkroniser' do
        java.lang.System.out.println "Synchronize"
        Thread.with_large_stack do
          require 'replicator'
          Replicator.synchronize(self)
          update_groups(@list_view)
        end
        java.lang.System.out.println "Synchronizing..."
        toast 'Synchronizing with server'
      end
      add_menu 'Avslutt' do
        finish
      end
      true
    end

  rescue Object
    puts 'Error in handle_create'
    toast 'Error in handle_create'
  end

  # startService(Java::android.content.Intent.new($activity.application_context, Java::no.jujutsu.android.oppmote.WifiDetectorService.java_class))
end
