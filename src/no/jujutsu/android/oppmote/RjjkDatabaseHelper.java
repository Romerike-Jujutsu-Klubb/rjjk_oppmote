package no.jujutsu.android.oppmote;

import org.jruby.Ruby;
import org.jruby.javasupport.util.RuntimeHelpers;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.javasupport.JavaUtil;
import org.jruby.exceptions.RaiseException;
import org.ruboto.Script;

public class RjjkDatabaseHelper extends android.database.sqlite.SQLiteOpenHelper {
  private Ruby __ruby__;

  public static final int CB_CLOSE = 0;
  public static final int CB_GET_READABLE_DATABASE = 1;
  public static final int CB_GET_WRITABLE_DATABASE = 2;
  public static final int CB_CREATE = 3;
  public static final int CB_OPEN = 4;
  public static final int CB_UPGRADE = 5;
  public static final int CB_CLONE = 6;
  public static final int CB_EQUALS = 7;
  public static final int CB_FINALIZE = 8;
  public static final int CB_HASH_CODE = 9;
  public static final int CB_TO_STRING = 10;
  private IRubyObject[] callbackProcs = new IRubyObject[11];

  public  RjjkDatabaseHelper(android.content.Context context, java.lang.String name, android.database.sqlite.SQLiteDatabase.CursorFactory factory, int version) {
    super(context, name, factory, version);
  }

  private Ruby getRuby() {
    if (__ruby__ == null) __ruby__ = Script.getRuby();
    return __ruby__;
  }

  public void setCallbackProc(int id, IRubyObject obj) {
    callbackProcs[id] = obj;
  }
	
  public void close() {
    if (callbackProcs[CB_CLOSE] != null) {
      super.close();
      try {
        RuntimeHelpers.invoke(getRuby().getCurrentContext(), callbackProcs[CB_CLOSE], "call" );
      } catch (RaiseException re) {
        re.printStackTrace();
      }
    } else {
      super.close();
    }
  }

  public android.database.sqlite.SQLiteDatabase getReadableDatabase() {
    if (callbackProcs[CB_GET_READABLE_DATABASE] != null) {
      super.getReadableDatabase();
      try {
        return (android.database.sqlite.SQLiteDatabase)RuntimeHelpers.invoke(getRuby().getCurrentContext(), callbackProcs[CB_GET_READABLE_DATABASE], "call" ).toJava(android.database.sqlite.SQLiteDatabase.class);
      } catch (RaiseException re) {
        re.printStackTrace();
        return null;
      }
    } else {
      return super.getReadableDatabase();
    }
  }

  public android.database.sqlite.SQLiteDatabase getWritableDatabase() {
    if (callbackProcs[CB_GET_WRITABLE_DATABASE] != null) {
      super.getWritableDatabase();
      try {
        return (android.database.sqlite.SQLiteDatabase)RuntimeHelpers.invoke(getRuby().getCurrentContext(), callbackProcs[CB_GET_WRITABLE_DATABASE], "call" ).toJava(android.database.sqlite.SQLiteDatabase.class);
      } catch (RaiseException re) {
        re.printStackTrace();
        return null;
      }
    } else {
      return super.getWritableDatabase();
    }
  }

  public void onCreate(android.database.sqlite.SQLiteDatabase db) {
    if (callbackProcs[CB_CREATE] != null) {
      try {
        RuntimeHelpers.invoke(getRuby().getCurrentContext(), callbackProcs[CB_CREATE], "call" , JavaUtil.convertJavaToRuby(getRuby(), db));
      } catch (RaiseException re) {
        re.printStackTrace();
      }
    }
  }

  public void onOpen(android.database.sqlite.SQLiteDatabase db) {
    if (callbackProcs[CB_OPEN] != null) {
      super.onOpen(db);
      try {
        RuntimeHelpers.invoke(getRuby().getCurrentContext(), callbackProcs[CB_OPEN], "call" , JavaUtil.convertJavaToRuby(getRuby(), db));
      } catch (RaiseException re) {
        re.printStackTrace();
      }
    } else {
      super.onOpen(db);
    }
  }

  public void onUpgrade(android.database.sqlite.SQLiteDatabase db, int oldVersion, int newVersion) {
    if (callbackProcs[CB_UPGRADE] != null) {
      try {
        RuntimeHelpers.invoke(getRuby().getCurrentContext(), callbackProcs[CB_UPGRADE], "call" , JavaUtil.convertJavaToRuby(getRuby(), db), JavaUtil.convertJavaToRuby(getRuby(), oldVersion), JavaUtil.convertJavaToRuby(getRuby(), newVersion));
      } catch (RaiseException re) {
        re.printStackTrace();
      }
    }
  }

  public boolean equals(java.lang.Object o) {
    if (callbackProcs[CB_EQUALS] != null) {
      super.equals(o);
      try {
        return (Boolean)RuntimeHelpers.invoke(getRuby().getCurrentContext(), callbackProcs[CB_EQUALS], "call" , JavaUtil.convertJavaToRuby(getRuby(), o)).toJava(boolean.class);
      } catch (RaiseException re) {
        re.printStackTrace();
        return false;
      }
    } else {
      return super.equals(o);
    }
  }

  public int hashCode() {
    if (callbackProcs[CB_HASH_CODE] != null) {
      super.hashCode();
      try {
        return (Integer)RuntimeHelpers.invoke(getRuby().getCurrentContext(), callbackProcs[CB_HASH_CODE], "call" ).toJava(int.class);
      } catch (RaiseException re) {
        re.printStackTrace();
        return 0;
      }
    } else {
      return super.hashCode();
    }
  }

  public java.lang.String toString() {
    if (callbackProcs[CB_TO_STRING] != null) {
      super.toString();
      try {
        return (java.lang.String)RuntimeHelpers.invoke(getRuby().getCurrentContext(), callbackProcs[CB_TO_STRING], "call" ).toJava(java.lang.String.class);
      } catch (RaiseException re) {
        re.printStackTrace();
        return null;
      }
    } else {
      return super.toString();
    }
  }
}
