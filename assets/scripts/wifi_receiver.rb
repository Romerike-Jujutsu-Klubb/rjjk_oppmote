require 'yaml'
require 'database'
require 'thread_ext'
require 'group'

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

Log.v "WifiDetector", "Woohoo!  Network event!"
Log.v "WifiDetector", $broadcast_intent.getExtras.to_s
wifi_service = $broadcast_context.getSystemService(Java::android.content.Context::WIFI_SERVICE)
ssid         = wifi_service.connection_info.getSSID
if true || ssid
  @notification_manager = $broadcast_context.getSystemService(Java::android.content.Context::NOTIFICATION_SERVICE)
  icon                  = $package.R::drawable::icon
  tickerText            = "Sync!"
  notify_when           = java.lang.System.currentTimeMillis
  notification          = Notification.new(icon, tickerText, notify_when)
  context               = $broadcast_context
  contentTitle          = "RJJK Oppmøte"
  contentText           = "Se på oppmøte"
  notificationIntent    = Java::android.content.Intent.new(context, $package.GroupList.java_class)
  contentIntent         = PendingIntent.getActivity($broadcast_context, 0, notificationIntent, 0)
  notification.setLatestEventInfo(context, contentTitle, contentText, contentIntent)

  @notification_manager.notify(HELLO_ID, notification);

  Thread.start do
    begin
      db = $db_helper.getWritableDatabase
      client = AndroidHttpClient.newInstance('Android')
      http_context = BasicHttpContext.new
      http_context.setAttribute(ClientContext.COOKIE_STORE, org.apache.http.impl.client.BasicCookieStore.new);
      method = HttpGet.new("http://#{SERVER}/user/login")
      EntityUtils.toString(client.execute(method, http_context).entity)

      method = HttpPost.new("http://#{SERVER}/user/login")
      method.setHeader("Content-Type", "application/x-www-form-urlencoded");
      list = [BasicNameValuePair.new('user[login]', 'uwe'), BasicNameValuePair.new('user[password]', 'CokaBrus')]
      entity = UrlEncodedFormEntity.new(list)
      method.setEntity(entity)
      EntityUtils.toString(client.execute(method, http_context).entity)

      method = HttpGet.new("http://#{SERVER}/groups/yaml")
      response = EntityUtils.toString(client.execute(method, http_context).entity)
      Log.v "RJJK Oppmøte", "Got response: #{response}"
      groups = YAML.load(response)
      groups.each do |group|
        Log.v "RJJK Oppmøte", "Group: #{group.inspect}"
        Thread.with_large_stack do
          c = db.rawQuery("SELECT id FROM groups WHERE id = #{group.attributes['id']}", nil)
          if c.getCount == 0
            db.execSQL "INSERT INTO groups VALUES (#{group.attributes['id']}, '#{group.attributes['name']}')"
          end
          c.close
        end.join
      end

      method = HttpGet.new("http://#{SERVER}/members/yaml")
      response = EntityUtils.toString(client.execute(method, http_context).entity)
      Log.v "RJJK Oppmøte", "Got members response: #{response}"
      members = YAML.load(response)
      members.each do |member|
        Log.v "RJJK Oppmøte", "Member: #{member.inspect}"
        Thread.with_large_stack do
          c = db.rawQuery("SELECT id FROM members WHERE id = #{member['id']}", nil)
          if c.getCount > 0
            db.execSQL "DELETE FROM members WHERE id = #{member['id']}"
          end
          db.execSQL "INSERT INTO members(id, first_name) VALUES (#{member['id']}, '#{member['first_name']}')"
          c.close
        end.join
      end

    rescue
      Log.e "RJJK Oppmøte", "Exception getting data from server: #{$!.message}\n#{$!.backtrace.join("\n")}"
    ensure
      db.close if db
    end
  end

else
  Log.v "WifiDetector", "Removing notification."
  Toast.makeText($broadcast_context, "Not connected to any WIFI network", 5000).show
  @notification_manager.cancel(HELLO_ID)
end
