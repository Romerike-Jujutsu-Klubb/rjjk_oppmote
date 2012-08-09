package no.jujutsu.android.oppmote;

public class SyncService extends org.ruboto.RubotoService {
	public void onCreate() {
	    System.out.println("SyncService.onCreate()");
		setScriptName("sync_service.rb");
		super.onCreate();
	}

}
