// Generated Ruboto subclass with method base "on"

package no.jujutsu.android.oppmote;

import org.ruboto.JRubyAdapter;
import org.ruboto.Log;
import org.ruboto.Script;

public class RjjkDatabaseHelper extends android.database.sqlite.SQLiteOpenHelper {
  public static final int CB_CREATE = 0;
  public static final int CB_OPEN = 1;
  public static final int CB_UPGRADE = 2;

    private String rubyClassName = "RjjkDatabaseHelper";
    private String scriptName = "RjjkDatabaseHelper";
    private Object rubyInstance = this;
    private Object[] callbackProcs = new Object[3];

  public RjjkDatabaseHelper(android.content.Context context, java.lang.String name, android.database.sqlite.SQLiteDatabase.CursorFactory factory, int version) {
    super(context, name, factory, version);
  }

    public void setCallbackProc(int id, Object obj) {
        callbackProcs[id] = obj;
    }
	
  public void onCreate(android.database.sqlite.SQLiteDatabase db) {
    if (JRubyAdapter.isInitialized()) {
      if (callbackProcs != null && callbackProcs[CB_CREATE] != null) {
        JRubyAdapter.runRubyMethod(callbackProcs[CB_CREATE], "call" , db);
      } else {
        String rubyClassName = Script.toCamelCase(scriptName);
        if ((Boolean)JRubyAdapter.runScriptlet("defined?(" + rubyClassName + ") == 'constant' && " + rubyClassName + ".instance_methods(false).any?{|m| m.to_sym == :on_create}")) {
          // FIXME(uwe): Simplify when we stop support for RubotoCore 0.4.7
          if (JRubyAdapter.isJRubyPreOneSeven()) {
            JRubyAdapter.put("$arg_db", db);
            JRubyAdapter.put("$ruby_instance", rubyInstance);
            JRubyAdapter.runScriptlet("$ruby_instance.on_create($arg_db)");
          } else {
            if (JRubyAdapter.isJRubyOneSeven()) {
              JRubyAdapter.runRubyMethod(rubyInstance, "on_create", db);
            } else {
              throw new RuntimeException("Unknown JRuby version: " + JRubyAdapter.get("JRUBY_VERSION"));
            }
          }
        } else {
          if ((Boolean)JRubyAdapter.runScriptlet("defined?(" + rubyClassName + ") == 'constant' && " + rubyClassName + ".instance_methods(false).any?{|m| m.to_sym == :onCreate}")) {
            // FIXME(uwe): Simplify when we stop support for RubotoCore 0.4.7
            if (JRubyAdapter.isJRubyPreOneSeven()) {
              JRubyAdapter.put("$arg_db", db);
              JRubyAdapter.put("$ruby_instance", rubyInstance);
              JRubyAdapter.runScriptlet("$ruby_instance.onCreate($arg_db)");
            } else {
              if (JRubyAdapter.isJRubyOneSeven()) {
                JRubyAdapter.runRubyMethod(rubyInstance, "onCreate", db);
              } else {
                throw new RuntimeException("Unknown JRuby version: " + JRubyAdapter.get("JRUBY_VERSION"));
              }
            }
          }
        }
      }
    } else {
      Log.i("Method called before JRuby runtime was initialized: RjjkDatabaseHelper#onCreate");
    }
  }

  public void onOpen(android.database.sqlite.SQLiteDatabase db) {
    if (JRubyAdapter.isInitialized()) {
      if (callbackProcs != null && callbackProcs[CB_OPEN] != null) {
        super.onOpen(db);
        JRubyAdapter.runRubyMethod(callbackProcs[CB_OPEN], "call" , db);
      } else {
        String rubyClassName = Script.toCamelCase(scriptName);
        if ((Boolean)JRubyAdapter.runScriptlet("defined?(" + rubyClassName + ") == 'constant' && " + rubyClassName + ".instance_methods(false).any?{|m| m.to_sym == :on_open}")) {
          super.onOpen(db);
          // FIXME(uwe): Simplify when we stop support for RubotoCore 0.4.7
          if (JRubyAdapter.isJRubyPreOneSeven()) {
            JRubyAdapter.put("$arg_db", db);
            JRubyAdapter.put("$ruby_instance", rubyInstance);
            JRubyAdapter.runScriptlet("$ruby_instance.on_open($arg_db)");
          } else {
            if (JRubyAdapter.isJRubyOneSeven()) {
              JRubyAdapter.runRubyMethod(rubyInstance, "on_open", db);
            } else {
              throw new RuntimeException("Unknown JRuby version: " + JRubyAdapter.get("JRUBY_VERSION"));
            }
          }
        } else {
          if ((Boolean)JRubyAdapter.runScriptlet("defined?(" + rubyClassName + ") == 'constant' && " + rubyClassName + ".instance_methods(false).any?{|m| m.to_sym == :onOpen}")) {
            super.onOpen(db);
            // FIXME(uwe): Simplify when we stop support for RubotoCore 0.4.7
            if (JRubyAdapter.isJRubyPreOneSeven()) {
              JRubyAdapter.put("$arg_db", db);
              JRubyAdapter.put("$ruby_instance", rubyInstance);
              JRubyAdapter.runScriptlet("$ruby_instance.onOpen($arg_db)");
            } else {
              if (JRubyAdapter.isJRubyOneSeven()) {
                JRubyAdapter.runRubyMethod(rubyInstance, "onOpen", db);
              } else {
                throw new RuntimeException("Unknown JRuby version: " + JRubyAdapter.get("JRUBY_VERSION"));
              }
            }
          } else {
            super.onOpen(db);
          }
        }
      }
    } else {
      Log.i("Method called before JRuby runtime was initialized: RjjkDatabaseHelper#onOpen");
      super.onOpen(db);
    }
  }

  public void onUpgrade(android.database.sqlite.SQLiteDatabase db, int oldVersion, int newVersion) {
    if (JRubyAdapter.isInitialized()) {
      if (callbackProcs != null && callbackProcs[CB_UPGRADE] != null) {
        JRubyAdapter.runRubyMethod(callbackProcs[CB_UPGRADE], "call" , new Object[]{db, oldVersion, newVersion});
      } else {
        String rubyClassName = Script.toCamelCase(scriptName);
        if ((Boolean)JRubyAdapter.runScriptlet("defined?(" + rubyClassName + ") == 'constant' && " + rubyClassName + ".instance_methods(false).any?{|m| m.to_sym == :on_upgrade}")) {
          // FIXME(uwe): Simplify when we stop support for RubotoCore 0.4.7
          if (JRubyAdapter.isJRubyPreOneSeven()) {
            JRubyAdapter.put("$arg_db", db);
            JRubyAdapter.put("$arg_oldVersion", oldVersion);
            JRubyAdapter.put("$arg_newVersion", newVersion);
            JRubyAdapter.put("$ruby_instance", rubyInstance);
            JRubyAdapter.runScriptlet("$ruby_instance.on_upgrade($arg_db, $arg_oldVersion, $arg_newVersion)");
          } else {
            if (JRubyAdapter.isJRubyOneSeven()) {
              JRubyAdapter.runRubyMethod(rubyInstance, "on_upgrade", new Object[]{db, oldVersion, newVersion});
            } else {
              throw new RuntimeException("Unknown JRuby version: " + JRubyAdapter.get("JRUBY_VERSION"));
            }
          }
        } else {
          if ((Boolean)JRubyAdapter.runScriptlet("defined?(" + rubyClassName + ") == 'constant' && " + rubyClassName + ".instance_methods(false).any?{|m| m.to_sym == :onUpgrade}")) {
            // FIXME(uwe): Simplify when we stop support for RubotoCore 0.4.7
            if (JRubyAdapter.isJRubyPreOneSeven()) {
              JRubyAdapter.put("$arg_db", db);
              JRubyAdapter.put("$arg_oldVersion", oldVersion);
              JRubyAdapter.put("$arg_newVersion", newVersion);
              JRubyAdapter.put("$ruby_instance", rubyInstance);
              JRubyAdapter.runScriptlet("$ruby_instance.onUpgrade($arg_db, $arg_oldVersion, $arg_newVersion)");
            } else {
              if (JRubyAdapter.isJRubyOneSeven()) {
                JRubyAdapter.runRubyMethod(rubyInstance, "onUpgrade", new Object[]{db, oldVersion, newVersion});
              } else {
                throw new RuntimeException("Unknown JRuby version: " + JRubyAdapter.get("JRUBY_VERSION"));
              }
            }
          }
        }
      }
    } else {
      Log.i("Method called before JRuby runtime was initialized: RjjkDatabaseHelper#onUpgrade");
    }
  }

}
