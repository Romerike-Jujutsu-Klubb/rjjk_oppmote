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
            end.join
            db.close
            java.lang.System.out.println 'list view...'
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

  rescue
    toast 'Error in handle_create'
  end

  startService(Java::android.content.Intent.new($activity.application_context, Java::no.jujutsu.android.oppmote.WifiDetectorService.java_class))
end
