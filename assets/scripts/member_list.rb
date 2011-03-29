require 'ruboto'
require 'database'
require 'thread_ext'

ruboto_import_widgets :ListView, :TextView, :LinearLayout, :Button
java_import "android.content.Intent"

$activity.handle_create do |bundle|
  begin
    group_name = getIntent().getExtras().getString("group_name")
    setTitle "Medlemmer: #{group_name}"

    setup_content do
      begin
        linear_layout :orientation => LinearLayout::VERTICAL do
          begin
            db = $db_helper.getWritableDatabase
            Thread.with_large_stack do
              
              @groups = []
              c = db.rawQuery('SELECT id, name FROM groups', nil)
              while c.moveToNext
                @groups << Group.new('id' => c.getInt(0), 'name' => c.getString(1))
              end
              
              @members = []
              c = db.rawQuery('SELECT id, first_name FROM members', nil)
              while c.moveToNext
                @members << Member.new('id' => c.getInt(0), 'first_name' => c.getString(1))
              end

              @groups_members = []
              c = db.rawQuery('SELECT group_id, member_id FROM groups_members', nil)
              while c.moveToNext
                member_id = c.getInt(0)
                member = @members.find{|m| m['id'] == member_id}
                group_id = c.getInt(1)
                group = @groups.find{|g| g['id'] == group_id}
                group.members << member
              end
            end.join
            db.close
            java.lang.System.out.println 'list view...'
            @list_view = list_view :list => @groups.find{|g| g['name'] == group_name}.members.map{|m| m['first_name']}
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
      toast "Item Click: #{view.text}"
      group_name = view.text
      i = Intent.new
      i.setClassName($package, 'MemberList')
      startActivity(i)
    end

  rescue
    toast 'Error in handle_create'
  end

end
