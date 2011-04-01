require 'yaml'
require 'database'
require 'thread_ext'
require 'group'
require 'member'

class Replicator
  HELLO_ID = 1;
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
    method.setHeader("Content-Type", "application/x-www-form-urlencoded");
    list = [BasicNameValuePair.new('user[login]', 'uwe'), BasicNameValuePair.new('user[password]', 'CokaBrus')]
    entity = UrlEncodedFormEntity.new(list)
    method.setEntity(entity)
    EntityUtils.toString(client.execute(method, http_context).entity)
  end

  def self.load_groups(client, http_context)
    method = HttpGet.new("http://#{SERVER}/groups/yaml")
    response = EntityUtils.toString(client.execute(method, http_context).entity)
    Log.v "RJJK Oppmøte", "Got response: #{response}"
    groups = YAML.load(response)
    groups.each do |group|
      Log.v "RJJK Oppmøte", "Group: #{group.inspect}"
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

  def self.load_members(client, http_context)
    Log.v "RJJK Oppmøte", "Get members"
    method = HttpGet.new("http://#{SERVER}/members/yaml")
    response = EntityUtils.toString(client.execute(method, http_context).entity)
    Log.v "RJJK Oppmøte", "Got members response: #{response}"
    members = YAML.load(response)
    members.each do |m|
      Log.v "RJJK Oppmøte", "Member: #{m.inspect}"
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

  def self.synchronize(context)
    Log.v "WifiDetector", "Woohoo!  Network event!"
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
        rescue
          Log.e "RJJK Oppmøte", "Exception getting data from server: #{$!.message}\n#{$!.backtrace.join("\n")}"
        ensure
          client.close if client
        end
      end

    else
      Log.v "WifiDetector", "Removing notification."
      Toast.makeText(context, "Not connected to any WIFI network", 5000).show
      @notification_manager.cancel(HELLO_ID)
    end
  end
end
