require 'ruboto'
require 'database'
require 'thread_ext'
require 'member'
require 'group'
require 'date'

ruboto_import_widgets :ListView, :TextView, :LinearLayout, :Button
java_import "android.content.Intent"

$activity.handle_create do |bundle|
  begin
    group_name = getIntent().getExtras().getString("group_name")

    Thread.with_large_stack do
      db = $db_helper.getWritableDatabase
      @groups = []
      c = db.rawQuery('SELECT id, name FROM groups', nil)
      while c.moveToNext
        @groups << Group.new('id' => c.getInt(0), 'name' => c.getString(1))
        @group = @groups.last if @groups.last['name'] == group_name
      end
      c.close

      (0..6).each do |i|
        @date = Date.today - i
        c = db.rawQuery("SELECT id FROM group_schedules WHERE group_id = #{@group['id']} AND weekday = #{@date.wday}", nil)
        if c.moveToNext
          @gs_id = c.getInt(0)
          $activity.runOnUiThread{toast "Group schedule: #{@gs_id}"}
        else
          $activity.runOnUiThread{toast "Group schedule not found: group_id = #{@group['id']} AND weekday = #{@date.wday}"}
        end
        c.close
        break if @gs_id
      end

      @members = []
      c = db.rawQuery('SELECT id, first_name, last_name FROM members', nil)
      while c.moveToNext
        @members << Member.new('id' => c.getInt(0), 'first_name' => c.getString(1), 'last_name' => c.getString(2))
      end
      c.close

      @groups_members = []
      c = db.rawQuery('SELECT group_id, member_id FROM groups_members', nil)
      while c.moveToNext
        member_id = c.getInt(1)
        member = @members.find{|m| m['id'] == member_id}
        group_id = c.getInt(0)
        group = @groups.find{|g| g['id'] == group_id}
        group.members << member if group && member
      end
      c.close
    end.join

    setTitle "Medlemmer: #{group_name} #{@date.strftime('%Y-%m-%d')}"

    setup_content do
      begin
        linear_layout :orientation => LinearLayout::VERTICAL do
          begin
            Thread.with_large_stack do
              db = $db_helper.getWritableDatabase

              db.close
            end.join
            @list_view = list_view :list => @groups.find{|g| g['name'] == group_name}.members.map{|m| "#{m['first_name']} #{m['last_name']}"}.sort
            @list_view.setChoiceMode(ListView::CHOICE_MODE_MULTIPLE)
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
      name = view.text
      db = $db_helper.getWritableDatabase
      if name =~ /^(.*) (.*?)$/
        fname, lname = $1, $2
      else
        toast "Member name mismatch: #{name}"
      end

      c = db.rawQuery("SELECT id FROM members WHERE first_name = '#{fname}' AND last_name = '#{lname}'", nil)
      if c.moveToNext
        mid = c.getInt(0)
      else
        toast "Member not found: #{name}"
      end
      c.close

      c = db.rawQuery("SELECT count(*) FROM attendances WHERE group_schedule_id = #{@gs_id} AND year = #{@date.year} AND week = #{@date.cweek}", nil)
      c.moveToNext
      att_total = c.getInt(0)
      c.close

      c = db.rawQuery("SELECT member_id FROM attendances WHERE group_schedule_id = #{@gs_id} AND member_id = #{mid} AND year = #{@date.year} AND week = #{@date.cweek}", nil)
      att_cnt = c.getCount
      c.close
      if att_cnt == 0
        db.execSQL "INSERT INTO attendances (group_schedule_id, member_id, year, week) VALUES (#{@gs_id}, #{mid}, #{@date.year}, #{@date.cweek})"
        setTitle "Medlemmer: #{group_name} #{@date.strftime('%Y-%m-%d')} #{att_total + 1}"
        toast "Present: #{name}, Total: #{att_total + 1}"
      else
        db.execSQL "DELETE FROM attendances WHERE group_schedule_id = #{@gs_id} AND member_id = #{mid} AND year = #{@date.year} AND week = #{@date.cweek}"
        setTitle "Medlemmer: #{group_name} #{@date.strftime('%Y-%m-%d')} #{att_total - 1}"
        toast "Not present: #{name}, Total: #{att_total - 1}"
      end
      db.close
    end

  rescue
    toast 'Error in handle_create'
  end

end
