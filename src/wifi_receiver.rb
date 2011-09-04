with_large_stack{require 'replicator'}

$broadcast_receiver.handle_receive do |context, intent|
  Log.v "WifiDetector", "Woohoo!  Network event!"
  Log.d "WifiDetector", "self: #{self.inspect}"
  Log.d "WifiDetector", "context: #{context.inspect}"
  Replicator.synchronize(context)
end
