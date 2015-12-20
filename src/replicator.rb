# encoding: UTF-8
require 'yaml'
require 'group'
require 'group_schedule'
require 'member'

java_import 'android.util.Log'

class Replicator
  HELLO_ID = 1
  SERVER = org.ruboto.JRubyAdapter.debug_build? ? '192.168.0.100:3000' : 'jujutsu.no'

  import android.app.Notification
  import android.app.PendingIntent
  import android.content.Context
  import android.net.http.AndroidHttpClient
  import android.view.View
  import android.widget.Toast
  import org.apache.http.HttpStatus
  import org.apache.http.client.entity.UrlEncodedFormEntity
  import org.apache.http.client.methods.HttpGet
  import org.apache.http.client.methods.HttpPost
  import org.apache.http.client.protocol.ClientContext
  import org.apache.http.message.BasicNameValuePair
  import org.apache.http.protocol.BasicHttpContext
  import org.apache.http.protocol.HttpContext
  import org.apache.http.util.EntityUtils

  def self.get_login_form(client, http_context)
    method = HttpGet.new("http://#{SERVER}/user/login")
    response = EntityUtils.toString(client.execute(method, http_context).entity)
    response =~ /<input name="authenticity_token" type="hidden" value="([^"]*)"\s*\/?>/
    $1
  end

  def self.submit_login_form(client, http_context, authenticity_token)
    puts 'submit_login_form'
    method = HttpPost.new("http://#{SERVER}/user/login")
    method.setHeader('Content-Type', 'application/x-www-form-urlencoded')
    list = [
        BasicNameValuePair.new('authenticity_token', authenticity_token),
        BasicNameValuePair.new('user[login]', @@login),
        BasicNameValuePair.new('user[password]', @@password)
    ]
    entity = UrlEncodedFormEntity.new(list)
    method.setEntity(entity)
    response = client.execute(method, http_context)

    status_code = response.status_line.status_code
    if status_code == HttpStatus::SC_MOVED_TEMPORARILY
      redirect_url = response.get_last_header('Location').value
      Log.v 'RJJK Oppmøte', "Following redirect: #{redirect_url}"
      redirect_method = HttpGet.new(redirect_url)
      response = client.execute(redirect_method, http_context)
    end

    body = EntityUtils.toString(response.entity)
    Log.v 'RJJK Oppmøte', "Got login body: #{body}"
    body =~ %r{<meta content="([^"]*)" name="csrf-token" />}
    authenticity_token = $1
  end

  def self.load_groups(client, http_context)
    puts 'load_groups'
    method = HttpGet.new("http://#{SERVER}/groups/yaml")
    response = EntityUtils.toString(client.execute(method, http_context).entity)
    puts "load_groups responded: #{response}"
    groups = YAML.load(response)
    db = $db_helper.getWritableDatabase
    db.execSQL 'DELETE FROM groups_members'
    db.execSQL "DELETE FROM groups WHERE id NOT IN (#{groups.map { |g| g['id'] }.join(',')})"
    groups.each do |group|
      c = db.rawQuery("SELECT id FROM groups WHERE id = #{group['id']}", nil)
      count = c.getCount
      c.close
      if count == 0
        db.execSQL "INSERT INTO groups VALUES (#{group['id']}, '#{group['name']}')"
      else
        db.execSQL "UPDATE groups SET name = '#{group['name']}' WHERE id = #{group['id']}"
      end

      group['members'].each do |member_id|
        c = db.rawQuery("SELECT group_id FROM groups_members WHERE group_id = #{group['id']} AND member_id = #{member_id}", nil)
        count = c.getCount
        c.close
        if count == 0
          db.execSQL "INSERT INTO groups_members VALUES (#{group['id']}, #{member_id})"
        end
      end
    end
    db.close
  end

  def self.load_group_schedules(client, http_context)
    Log.v 'RJJK Oppmøte', 'Fetch group schedules body'
    method = HttpGet.new("http://#{SERVER}/group_schedules/yaml")
    response = client.execute(method, http_context)

    Log.v 'RJJK Oppmøte', "headers: #{response.all_headers.map { |h| [h.name, h.value] }}"

    authenticity_token = response.get_first_header('X-CSRF-Token')
    body = EntityUtils.toString(response.entity)
    Log.v 'RJJK Oppmøte', "Got group schedules body: #{body}"
    group_schedules = YAML.load(body)
    group_schedules.each do |gs|
      Log.v 'RJJK Oppmøte', "GroupSchedule: #{gs.inspect}"
      Thread.with_large_stack do
        db = $db_helper.getWritableDatabase
        c = db.rawQuery("SELECT id FROM group_schedules WHERE id = #{gs['id']}", nil)
        count = c.getCount
        c.close
        if count == 0
          db.execSQL "INSERT INTO group_schedules (id, group_id, weekday, start_at, end_at) VALUES (#{gs['id']}, #{gs['group_id']}, #{gs['weekday']}, '#{gs['start_at']}', '#{gs['end_at']}')"
        end

        db.close
      end.join
    end
    authenticity_token
  end

  def self.load_members(client, http_context)
    method = HttpGet.new("http://#{SERVER}/members/yaml")
    response = client.execute(method, http_context)
    status_code = response.status_line.status_code
    unless status_code == 200
      raise "Bad status code loading members: #{status_code}"
    end
    body = EntityUtils.toString(response.entity)
    members = YAML.load(body)
    Log.v 'RJJK Oppmøte', "Members: #{members.inspect}"

    members.each do |m|
      Log.v 'RJJK Oppmøte', "Member: #{m.inspect}"
      Thread.with_large_stack do
        db = $db_helper.getWritableDatabase
        c = db.rawQuery("SELECT id FROM members WHERE id = #{m['id']}", nil)
        mcount = c.getCount
        c.close
        if mcount > 0
          db.execSQL "DELETE FROM members WHERE id = #{m['id']}"
        end
        db.execSQL "INSERT INTO members(id, first_name, last_name, male, address, payment_problem, instructor, rank_pos, rank_name, active) VALUES (
        #{m['id']}, '#{m['first_name']}', '#{m['last_name'].gsub("'", "''")}', #{m['male'] == 't' ? 1 : 0},
        '#{m['address']}', #{m['payment_problem'] == 't' ? 1 : 0}, #{m['instructor'] == 't' ? 1 : 0},
        #{m['rank_pos'] || 'NULL'}, '#{m['rank_name']}', #{m['active'] ? 1 : 0})"
        db.close
      end.join
    end
  end

  def self.upload_attendances(client, http_context, authenticity_token)
    Thread.with_large_stack do
      db = $db_helper.getWritableDatabase
      c = db.rawQuery('SELECT group_schedule_id, member_id, year, week FROM attendances', nil)
      while c.moveToNext
        gsid = c.getInt(0)
        mid = c.getInt(1)
        year = c.getInt(2)
        week = c.getInt(3)
        puts "Sending #{gsid}, #{mid}, #{year}, #{week}"
        method = HttpPost.new("http://#{SERVER}/attendances")
        method.setHeader('Content-Type', 'application/x-www-form-urlencoded')
        method.setHeader('X-CSRF-Token', authenticity_token)
        list = []
        list << BasicNameValuePair.new('authenticity_token', authenticity_token)
        list << BasicNameValuePair.new('attendance[group_schedule_id]', gsid.to_s)
        list << BasicNameValuePair.new('attendance[member_id]', mid.to_s)
        list << BasicNameValuePair.new('attendance[year]', year.to_s)
        list << BasicNameValuePair.new('attendance[week]', week.to_s)
        entity = UrlEncodedFormEntity.new(list)
        method.setEntity(entity)
        EntityUtils.toString(client.execute(method, http_context).entity)
      end
      c.close
      db.execSQL 'DELETE FROM attendances'
      db.close
    end.join
  end

  def self.synchronize(context)
    config = Config.new(context)
    unless config.ok?
      puts "Config not OK: #{config}"
      puts "Config.email: #{config.email}"
      puts "Config.password: #{config.password}"
      return false
    end
    @@login = config.email
    @@password = config.password

    Thread.with_large_stack do

      Log.v 'WifiDetector', 'Synchronize with server'
      wifi_service = context.getSystemService(Java::android.content.Context::WIFI_SERVICE)
      ssid = wifi_service.connection_info.getSSID
      if true || ssid
        @notification_manager = context.getSystemService(Java::android.content.Context::NOTIFICATION_SERVICE)
        icon = $package.R::drawable::icon
        tickerText = 'Sync!'
        notify_when = java.lang.System.currentTimeMillis
        notification = Notification.new(icon, tickerText, notify_when)
        context = context
        contentTitle = 'RJJK Oppmøte'
        contentText = 'Se på oppmøte'
        notificationIntent = Java::android.content.Intent.new(context, $package.GroupList.java_class)
        contentIntent = PendingIntent.getActivity(context, 0, notificationIntent, 0)
        notification.setLatestEventInfo(context, contentTitle, contentText, contentIntent)

        @notification_manager.notify(HELLO_ID, notification)

        begin
          client = AndroidHttpClient.newInstance('Android')
          http_context = BasicHttpContext.new
          http_context.setAttribute(ClientContext.COOKIE_STORE, org.apache.http.impl.client.BasicCookieStore.new)

          Log.v 'RJJK Oppmøte', 'Login...get'

          authenticity_token = get_login_form(client, http_context)

          Log.v 'RJJK Oppmøte', 'Login...post'

          authenticity_token = submit_login_form(client, http_context, authenticity_token)
          Log.v 'RJJK Oppmøte', "authenticity_token: #{authenticity_token.inspect}"

          Log.v 'RJJK Oppmøte', 'Members'
          load_members(client, http_context)
          Log.v 'RJJK Oppmøte', 'Groups'
          load_groups(client, http_context)
          Log.v 'RJJK Oppmøte', 'Group Schedules'
          load_group_schedules(client, http_context)
          Log.v 'RJJK Oppmøte', "authenticity_token: #{authenticity_token.inspect}"

          context.runOnUiThread do
            Toast.makeText(context, 'Got new data', 5000).show
          end if context.respond_to? :runOnUiThread

          upload_attendances(client, http_context, authenticity_token)

          context.runOnUiThread do
            Toast.makeText(context, 'Sunchronized with server', 5000).show
            if context.respond_to? :update_groups
              puts 'notify client'
              context.update_groups
            else
              puts "primitive client: #{context}"
            end
          end if context.respond_to? :runOnUiThread
        rescue Exception => e
          Log.e 'RJJK Oppmøte', "Exception getting data from server: #{$!.message}\n#{$!.backtrace.join("\n")}"
          context.runOnUiThread do
            context.toast "Exception syncing: #{e}"
          end
        ensure
          client.close if client
        end
      else
        Log.v 'WifiDetector', 'Removing notification.'
        context.runOnUiThread do
          Toast.makeText(context, 'Not connected to any WIFI network', 5000).show
          @notification_manager.cancel(HELLO_ID)
        end if context.respond_to? :runOnUiThread
      end
    end
  end

end
