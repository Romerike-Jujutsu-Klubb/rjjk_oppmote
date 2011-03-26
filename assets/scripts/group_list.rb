java.lang.System.out.println 'require ruboto...'

require 'ruboto'

java.lang.System.out.println 'require database...'

require 'database'

java.lang.System.out.println 'require thread_ext...'

require 'thread_ext'

java.lang.System.out.println 'widgets...'

ruboto_import_widgets :ListView, :TextView, :LinearLayout, :Button

java.lang.System.out.println 'handle create...'

$activity.handle_create do |bundle|
  begin
    puts "puts"
    java.lang.System.out.println 'Sysout'

    setTitle 'Grupper'

    java.lang.System.out.println 'setup content...'

    setup_content do
      begin
        java.lang.System.out.println 'layout...'
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

    #  handle_item_click do |parent, view, position, id|
    #    toast view.text
    #  end

    begin
      db = $db_helper.getWritableDatabase
      if db.rawQuery('SELECT id FROM groups WHERE id = 1', nil).getCount == 0
        db.execSQL "INSERT INTO groups VALUES (1, 'Panda')"
      end
    rescue
      java.lang.System.out.println "Exception: #$!"
    ensure
      db.close if db
    end
  rescue
    toast 'Error in handle create'
  end

end
