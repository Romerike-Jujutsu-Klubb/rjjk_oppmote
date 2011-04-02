Thread.with_large_stack do
  require 'replicator'
end.join
Log.v "WifiDetector", "Woohoo!  Network event!"
Replicator.synchronize($broadcast_context)
