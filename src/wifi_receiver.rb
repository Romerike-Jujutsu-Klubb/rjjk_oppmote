require 'replicator'

class WifiReceiver
  def onReceive(context, intent)
    Log.v 'WifiDetector', 'Woohoo!  Network event!'
    Log.d 'WifiDetector', "self: #{self.inspect}"
    Log.d 'WifiDetector', "context: #{context.inspect}"
    Replicator.synchronize(context)
  end
end
