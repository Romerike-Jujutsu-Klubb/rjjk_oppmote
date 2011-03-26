begin
  java.lang.System.out.println 'database...'

  java_import 'no.jujutsu.android.oppmote.RjjkDatabaseHelper'

  java.lang.System.out.println 'create helper...'

  $db_helper = RjjkDatabaseHelper.new($activity, 'main', nil, 1)

  java.lang.System.out.println 'add on create...'

  $db_helper.setCallbackProc(RjjkDatabaseHelper::CB_CREATE) do |db|
    java.lang.System.out.println 'create...'

    db.execSQL('CREATE TABLE groups (id int primary key, name varchar(32) unique not null)')
    
    java.lang.System.out.println 'create OK'
  end

  java.lang.System.out.println 'database OK'
rescue
  java.lang.System.out.println "Exception: #{$!}"
end
