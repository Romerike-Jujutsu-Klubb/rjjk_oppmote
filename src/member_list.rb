class MemberList
  include Ruboto::Activity::Reload

  def onCreate(bundle)
    super
    @group_name = getIntent().getExtras().getString('group_name')
    att_total = nil

    Thread.with_large_stack do
      db = $db_helper.getWritableDatabase
      @groups = []
      c = db.rawQuery('SELECT id, name FROM groups', nil)
      while c.moveToNext
        @groups << Group.new('id' => c.getInt(0), 'name' => c.getString(1))
        @group = @groups.last if @groups.last['name'] == @group_name
      end
      c.close

      (0..6).each do |i|
        @date = Date.today - i
        c = db.rawQuery("SELECT id FROM group_schedules WHERE group_id = #{@group['id']} AND weekday = #{@date.wday}", nil)
        if c.moveToNext
          @gs_id = c.getInt(0)
        end
        c.close
        break if @gs_id
      end

      @members = []
      c = db.rawQuery('SELECT id, first_name, last_name, rank_pos, rank_name FROM members', nil)
      while c.moveToNext
        @members << Member.new('id' => c.getInt(0), 'first_name' => c.getString(1),
            'last_name' => c.getString(2), 'rank_pos' => c.getInt(3), 'rank_name' => c.getString(4))
      end
      c.close

      @groups_members = []
      c = db.rawQuery('SELECT group_id, member_id FROM groups_members', nil)
      while c.moveToNext
        member_id = c.getInt(1)
        member = @members.find { |m| m['id'] == member_id }
        group_id = c.getInt(0)
        group = @groups.find { |g| g['id'] == group_id }
        group.members << member if group && member
      end
      c.close

      c = db.rawQuery("SELECT count(*) FROM attendances WHERE group_schedule_id = #{@gs_id} AND year = #{@date.year} AND week = #{@date.cweek}", nil)
      c.moveToNext
      att_total = c.getInt(0)
      c.close
      db.close
    end.join

    setTitle "#{@group_name} #{@date.strftime('%Y-%m-%d')} #{att_total}/#{@group.members.size}"

    members = @group.members.sort_by { |m| [-(m.rank_pos), "#{m['first_name']} #{m['last_name']}"] }
    items = members.map { |m| "#{m['first_name']} #{m['last_name']}" }
    self.content_view = @list_view = list_view :list => items,
        :item_layout => android.R::layout::simple_list_item_multiple_choice,
        :choice_mode => ListView::CHOICE_MODE_MULTIPLE,
        :on_item_click_listener => proc { |parent, view, position, id| mark_member(view) }
    db = $db_helper.getWritableDatabase
    members.each_with_index do |m, i|
      c = db.rawQuery("SELECT member_id FROM attendances WHERE group_schedule_id = #{@gs_id} AND member_id = #{m['id']} AND year = #{@date.year} AND week = #{@date.cweek}", nil)
      att_cnt = c.getCount
      c.close
      @list_view.setItemChecked i, att_cnt > 0
    end
    db.close
  end

  # FIXME(uwe):  Only needed for Ruboto::Activity::Reload.
  # FIXME(uwe):  Should not be enecessary.  Fix in Ruboto!
  def onResume
    super
  end

  # FIXME(uwe):  Only needed for Ruboto::Activity::Reload.
  # FIXME(uwe):  Should not be enecessary.  Fix in Ruboto!
  def onPause
    super
  end


  private

  def mark_member(view)
    name = view.text
    if name =~ /^(.*) (.*?)$/
      fname, lname = $1, $2
    else
      toast "Member name mismatch: #{name}"
    end

    db = $db_helper.getWritableDatabase
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
      setTitle "Medlemmer: #{@group_name} #{@date.strftime('%Y-%m-%d')} #{att_total + 1}/#{@group.members.size}"
      view.setSelected(true)
      # toast "Present: #{name}, Total: #{att_total + 1}"
    else
      db.execSQL "DELETE FROM attendances WHERE group_schedule_id = #{@gs_id} AND member_id = #{mid} AND year = #{@date.year} AND week = #{@date.cweek}"
      setTitle "Medlemmer: #{@group_name} #{@date.strftime('%Y-%m-%d')} #{att_total - 1}/#{@group.members.size}"
      view.setSelected(false)
      # toast "Not present: #{name}, Total: #{att_total - 1}"
    end
    db.close
  end

end
