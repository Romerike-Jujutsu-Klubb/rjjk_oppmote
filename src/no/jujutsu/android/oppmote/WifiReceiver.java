package no.jujutsu.android.oppmote;

public class WifiReceiver extends org.ruboto.RubotoBroadcastReceiver {
	public void onReceive(android.content.Context arg0, android.content.Intent arg1) {

               setScriptName("wifi_receiver.rb");
               super.onReceive(arg0,arg1);
        }

}
