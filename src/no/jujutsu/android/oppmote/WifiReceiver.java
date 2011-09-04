package no.jujutsu.android.oppmote;

import android.util.Log;
import org.ruboto.Script;

public class WifiReceiver extends org.ruboto.RubotoBroadcastReceiver {
    private boolean scriptLoaded = false;

    public WifiReceiver() {
        super("wifi_receiver.rb");
        System.out.println("WifiReceiver constructor");
        Log.d("WifiReceiver", "constructor");
        if (Script.isInitialized()) {
            scriptLoaded = true;
        }
    }

    public void onReceive(android.content.Context context, android.content.Intent intent) {
        System.out.println("WifiReceiver.onReceive context: " + context);
        Log.d("WifiReceiver", "onReceive context: " + context);
        if (!scriptLoaded) {
            if (Script.setUpJRuby(context)) {
                loadScript();
                scriptLoaded = true;
            } else {
                // FIXME(uwe): What to do if the Ruboto Core platform is missing?
            }
        }
        super.onReceive(context, intent);
    }

}
