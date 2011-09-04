require 'ruboto'

java_import 'android.util.Log'

$service.handle_start_command do |intent, flags, startId|
  Log.i("WifiDetector", "Service command started")
  @receiver = Java::no.jujutsu.android.oppmote.WifiReceiver.new
  filter = Java::android.content.IntentFilter.new(Java::android.net.wifi.WifiManager::NETWORK_STATE_CHANGED_ACTION)
  $service.registerReceiver(@receiver, filter)
  Java::android.app.Service::START_STICKY
end

$service.handle_destroy do
  Log.i("WifiDetector", "Service destroyed")
  $service.unregisterReceiver(@receiver)
  @receiver = nil
end
