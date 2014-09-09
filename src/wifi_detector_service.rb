require 'ruboto'

java_import 'android.util.Log'

class WifiDetectorService
  def onStartCommand(intent, flags, startId)
    Log.i('WifiDetector', 'Service command started')
    @receiver = Java::no.jujutsu.android.oppmote.WifiReceiver.new
    filter = Java::android.content.IntentFilter.new(Java::android.net.wifi.WifiManager::NETWORK_STATE_CHANGED_ACTION)
    registerReceiver(@receiver, filter)
    Java::android.app.Service::START_STICKY
  end

  def onDestroy
    Log.i('WifiDetector', 'Service destroyed')
    unregisterReceiver(@receiver)
    @receiver = nil
  end
end
