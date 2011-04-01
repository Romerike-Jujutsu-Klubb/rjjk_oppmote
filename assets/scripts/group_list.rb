require 'ruboto'
require 'database'
require 'thread_ext'

ruboto_import_widgets :ListView, :TextView, :LinearLayout, :Button
java_import "android.content.Intent"

$activity.handle_create do |bundle|
  begin
    setTitle 'Grupper'

    setup_content do
      begin
        linear_layout :orientation => LinearLayout::VERTICAL do
          begin
            db = $db_helper.getWritableDatabase
            Thread.with_large_stack do
              @groups = []
              c = db.rawQuery('SELECT name FROM groups', nil)
              while c.moveToNext
                @groups << c.getString(0)
              end
              c.close
            end.join
            db.close
            @list_view = list_view :list => @groups
          rescue
            toast "Error in linearlayout: #$!"
            java.lang.System.out.println "Exception during layout: #$!\n#{$!.backtrace.join("\n")}"
          end
        end
      rescue
        toast 'Error in setup content'
      end
    end

    handle_item_click do |parent, view, position, id|
      group_name = view.text
      i = Intent.new
      i.setClassName($package_name, $package_name + '.MemberList')
      i.putExtra("group_name", group_name)
      startActivity(i)
    end

    handle_create_options_menu do |menu|
      menu.add 'Update scripts'
      menu.add 'Synchronize'
      true
    end

    handle_options_item_selected do |menu_item|
      toast menu_item.title
      case menu_item.title
      when 'Update scripts'
        java.lang.System.out.println "Copy scripts"
        org.ruboto.Script.copy_scripts self
        java.lang.System.out.println "Copy scripts...OK"
        toast 'Scripts updated from APK'
      when 'Synchronize'
        java.lang.System.out.println "Synchronize"
        Thread.with_large_stack do
          require 'replicator'
          Replicator.synchronize(self)
        end.join
        java.lang.System.out.println "Synchronize...OK"
        toast 'Synchronized with server'
      else
        toast "Unknown menu item: #{menu_item.title}"
      end
    end

  rescue
    toast 'Error in handle_create'
  end

  startService(Java::android.content.Intent.new($activity.application_context, Java::no.jujutsu.android.oppmote.WifiDetectorService.java_class))
end
