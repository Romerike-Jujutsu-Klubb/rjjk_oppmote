package no.jujutsu.android.oppmote;

public class GroupList extends org.ruboto.RubotoActivity {
	public void onCreate(android.os.Bundle arg0) {
    try {
      setSplash(Class.forName("no.jujutsu.android.oppmote.R$layout").getField("splash").getInt(null));
    } catch (Exception e) {}

    setScriptName("group_list.rb");
    super.onCreate(arg0);
  }
}
