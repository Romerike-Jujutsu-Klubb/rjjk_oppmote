package no.jujutsu.android.oppmote;

public class WifiDetectorService extends org.ruboto.RubotoService {
	public void onCreate() {
	    System.out.println("WifiDetectorService.onCreate()");
		setScriptName("wifi_detector_service.rb");
		super.onCreate();
	}

}
