package no.jujutsu.android.oppmote;

public class SyncService extends org.ruboto.RubotoService {
	public void onCreate() {
		setScriptName("sync_service.rb");
		super.onCreate();
	}

}
