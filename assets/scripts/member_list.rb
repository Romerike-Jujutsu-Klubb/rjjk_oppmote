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
              c = db.rawQuery('SELECT id, first_name, last_name FROM members', nil)
              while c.moveToNext
                @members << Member.new('id' => c.getInt(0), 'first_name' => c.getString(1), 'last_name' => c.getString(2))
              end

              @groups_members = []
              c = db.rawQuery('SELECT group_id, member_id FROM groups_members', nil)
              while c.moveToNext
                member_id = c.getInt(1)
                java.lang.System.out.println "member_id: #{member_id.inspect}"
                member = @members.find{|m| m['id'] == member_id}
                java.lang.System.out.println "member: #{member.inspect}"
                group_id = c.getInt(0)
                java.lang.System.out.println "group_id: #{group_id.inspect}"
                java.lang.System.out.println "group ids: #{@groups.map{|g| g['id']}.inspect}"
                group = @groups.find{|g| g['id'] == group_id}
                group.members << member if group && member
              end
            end.join
            db.close
            java.lang.System.out.println 'list view...'
            @list_view = list_view :list => @groups.find{|g| g['name'] == group_name}.members.map{|m| "#{m['first_name']} #{m['first_name']}"}.sort
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
