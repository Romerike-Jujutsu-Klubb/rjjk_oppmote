begin
  java.lang.System.out.println 'database...'

  java_import 'no.jujutsu.android.oppmote.RjjkDatabaseHelper'

  java.lang.System.out.println 'create helper...'

  $db_helper = RjjkDatabaseHelper.new($activity, 'main', nil, 1)

  java.lang.System.out.println 'add on create...'

  $db_helper.setCallbackProc(RjjkDatabaseHelper::CB_CREATE) do |db|
    java.lang.System.out.println 'create...'

    db.execSQL('CREATE TABLE members (
      id int primary key,
      first_name varchar(100) not null,
      last_name varchar(100) not null,
      email varchar(128),
      phone_mobile varchar(32),
      phone_home varchar(32),
      phone_work varchar(32),
      phone_parent varchar(32),
      birthdate date,
      male boolean not null,
      joined_on date,
      contract_id integer references contracts(id),
      parent_name varchar(100),
      address varchar(100) not null,
      postal_code varchar(4),
      payment_problem boolean not null,
      instructor boolean not null,
      image blob,
      image_content_type varchar(32),
      kid varchar(64)
    )')

    db.execSQL('CREATE TABLE groups (
      id int primary key,
      name varchar(32) unique not null
    )')

    db.execSQL('CREATE TABLE groups_members (
      group_id integer not null references groups(id),
      member_id integer not null references members(id)
    )')
    
    db.execSQL('CREATE TABLE group_schedules (
      id integer primary key,
      group_id integer not null references groups(id),
      weekday integer not null,
      start_at integer not null,
      end_at integer not null
    )')
    
    db.execSQL('CREATE TABLE attendances (
      id integer primary key,
      member_id integer not null references members(id),
      group_schedule_id integer not null references group_schedules(id),
      year integer not null,
      week integer not null
    )')
    
    java.lang.System.out.println 'create OK'
  end

  java.lang.System.out.println 'database OK'
rescue
  java.lang.System.out.println "Exception: #{$!}"
end
