package no.jujutsu.android.oppmote;

import org.ruboto.Script;

public class WifiReceiver extends org.ruboto.RubotoBroadcastReceiver {
    private boolean scriptLoaded = false;

    public WifiReceiver() {
        super("wifi_receiver.rb");
        if (Script.isInitialized()) {
            scriptLoaded = true;
        }
    }

    public void onReceive(android.content.Context context, android.content.Intent intent) {
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
