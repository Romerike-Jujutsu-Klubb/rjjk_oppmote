# encoding: UTF-8
require 'yaml'
require 'database'
require 'group'
require 'group_schedule'
require 'member'

java_import 'android.util.Log'

class Replicator
  HELLO_ID = 1
  SERVER = 'jujutsu.no'

  import 'android.app.Notification'
  import 'android.app.PendingIntent'
  import 'android.content.Context'
  import 'android.net.http.AndroidHttpClient'
  import 'android.view.View'
  import 'android.widget.Toast'
  import 'org.apache.http.client.methods.HttpGet'
  import 'org.apache.http.client.methods.HttpPost'
  import 'org.apache.http.util.EntityUtils'
  import org.apache.http.client.entity.UrlEncodedFormEntity
  import org.apache.http.client.protocol.ClientContext
  import org.apache.http.message.BasicNameValuePair
  import org.apache.http.protocol.HttpContext
  import org.apache.http.protocol.BasicHttpContext

  def self.get_login_form(client, http_context)
    method = HttpGet.new("http://#{SERVER}/user/login")
    EntityUtils.toString(client.execute(method, http_context).entity)
  end

  def self.submit_login_form(client, http_context)
    method = HttpPost.new("http://#{SERVER}/user/login")
    method.setHeader("Content-Type", "application/x-www-form-urlencoded")
    list = [BasicNameValuePair.new('user[login]', @@login), BasicNameValuePair.new('user[password]', @@password)]
    entity = UrlEncodedFormEntity.new(list)
    method.setEntity(entity)
    EntityUtils.toString(client.execute(method, http_context).entity)
  end

  def self.load_groups(client, http_context)
    method = HttpGet.new("http://#{SERVER}/groups/yaml")
    response = EntityUtils.toString(client.execute(method, http_context).entity)
    groups = YAML.load(response)
    groups.each do |group|
      Thread.with_large_stack do
        db = $db_helper.getWritableDatabase
        c = db.rawQuery("SELECT id FROM groups WHERE id = #{group['id']}", nil)
        count = c.getCount
        c.close
        if count == 0
          db.execSQL "INSERT INTO groups VALUES (#{group['id']}, '#{group['name']}')"
        end

        group['members'].each do |mid|
          c = db.rawQuery("SELECT group_id FROM groups_members WHERE group_id = #{group['id']} AND member_id = #{mid}", nil)
          count = c.getCount
          c.close
          if count == 0
            db.execSQL "INSERT INTO groups_members VALUES (#{group['id']}, #{mid})"
          end
        end

        db.close
      end.join
    end
  end

  def self.load_group_schedules(client, http_context)
    Log.v "RJJK Oppmøte", "Fetch group schedules response"
    method = HttpGet.new("http://#{SERVER}/group_schedules/yaml")
    response = EntityUtils.toString(client.execute(method, http_context).entity)
    Log.v "RJJK Oppmøte", "Got group schedules response: #{response}"
    group_schedules = YAML.load(response)
    group_schedules.each do |gs|
      Log.v "RJJK Oppmøte", "GroupSchedule: #{gs.inspect}"
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
  end

  def self.load_members(client, http_context)
    method = HttpGet.new("http://#{SERVER}/members/yaml")
    response = EntityUtils.toString(client.execute(method, http_context).entity)
    members = YAML.load(response)
    members.each do |m|
      Thread.with_large_stack do
        db = $db_helper.getWritableDatabase
        c = db.rawQuery("SELECT id FROM members WHERE id = #{m['id']}", nil)
        mcount = c.getCount
        c.close
        if mcount > 0
          db.execSQL "DELETE FROM members WHERE id = #{m['id']}"
        end
        db.execSQL "INSERT INTO members(id, first_name, last_name, male, address, payment_problem, instructor) VALUES (
        #{m['id']}, '#{m['first_name']}', '#{m['last_name'].gsub("'", "''")}', #{m['male'] == 't' ? 1 : 0},
        '#{m['address']}', #{m['payment_problem'] == 't' ? 1 : 0}, #{m['instructor'] == 't' ? 1 : 0}
      )"
        db.close
      end.join
    end
  end

  def self.upload_attendances(client, http_context)
    Thread.with_large_stack do
      db = $db_helper.getWritableDatabase
      c = db.rawQuery("SELECT group_schedule_id, member_id, year, week FROM attendances", nil)
      while c.moveToNext
        gsid = c.getInt(0)
        mid = c.getInt(1)
        year = c.getInt(2)
        week = c.getInt(3)
        puts "Sending #{gsid}, #{mid}, #{year}, #{week}"
        method = HttpPost.new("http://#{SERVER}/attendances")
        method.setHeader("Content-Type", "application/x-www-form-urlencoded");
        list = []
        list << BasicNameValuePair.new('attendance[group_schedule_id]', gsid.to_s)
        list << BasicNameValuePair.new('attendance[member_id]', mid.to_s)
        list << BasicNameValuePair.new('attendance[year]', year.to_s)
        list << BasicNameValuePair.new('attendance[week]', week.to_s)
        entity = UrlEncodedFormEntity.new(list)
        method.setEntity(entity)
        EntityUtils.toString(client.execute(method, http_context).entity)
      end
      c.close
      db.execSQL "DELETE FROM attendances"
      db.close
    end.join
  end

  def self.synchronize(context)
    filename = File.join(context.files_dir.path, 'config.yml')
    return false unless File.exists? filename
    puts "Read config from #{filename.inspect}"
    config = YAML.load_file(filename)
    @@login = config[:email]
    @@password = config[:password]

    Log.v "WifiDetector", "Synchronize with server"
    wifi_service = context.getSystemService(Java::android.content.Context::WIFI_SERVICE)
    ssid         = wifi_service.connection_info.getSSID
    if true || ssid
      @notification_manager = context.getSystemService(Java::android.content.Context::NOTIFICATION_SERVICE)
      icon                  = $package.R::drawable::icon
      tickerText            = "Sync!"
      notify_when           = java.lang.System.currentTimeMillis
      notification          = Notification.new(icon, tickerText, notify_when)
      context               = context
      contentTitle          = "RJJK Oppmøte"
      contentText           = "Se på oppmøte"
      notificationIntent    = Java::android.content.Intent.new(context, $package.GroupList.java_class)
      contentIntent         = PendingIntent.getActivity(context, 0, notificationIntent, 0)
      notification.setLatestEventInfo(context, contentTitle, contentText, contentIntent)

      @notification_manager.notify(HELLO_ID, notification);

      Thread.start do
        begin
          client = AndroidHttpClient.newInstance('Android')
          http_context = BasicHttpContext.new
          http_context.setAttribute(ClientContext.COOKIE_STORE, org.apache.http.impl.client.BasicCookieStore.new);

          get_login_form(client, http_context)
          submit_login_form(client, http_context)
          load_members(client, http_context)
          load_groups(client, http_context)
          load_group_schedules(client, http_context)

          context.runOnUiThread do
            Toast.makeText(context, "Got new data", 5000).show
          end if context.respond_to? :runOnUiThread

          upload_attendances(client, http_context)

          context.runOnUiThread do
            Toast.makeText(context, "Sunchronized with server", 5000).show
          end if context.respond_to? :runOnUiThread
        rescue Exception
          Log.e "RJJK Oppmøte", "Exception getting data from server: #{$!.message}\n#{$!.backtrace.join("\n")}"
        ensure
          client.close if client
        end
      end
    else
      Log.v "WifiDetector", "Removing notification."
      context.runOnUiThread do
        Toast.makeText(context, "Not connected to any WIFI network", 5000).show
        @notification_manager.cancel(HELLO_ID)
      end if context.respond_to? :runOnUiThread
    end
  end

end
