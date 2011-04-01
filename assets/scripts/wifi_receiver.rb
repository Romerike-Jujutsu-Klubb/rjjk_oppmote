require 'replicator'

Log.v "WifiDetector", "Woohoo!  Network event!"
Replicator.synchronize($broadcast_context)
