 select username from dba_users order by username
/
undefine user
accept userid prompt 'Enter user to clone: '
accept newuser prompt 'Enter new username: '
accept passwd prompt 'Enter new password: '
select username, created from dba_users
where  lower(username) = lower('&newuser')
/
accept poo prompt 'Continue? (ctrl-c to exit)'
spool D:\TEST\clone.sql
select 'create user ' || '&newuser' || ' identified by ' || '&passwd' ||
       ' default tablespace ' || default_tablespace ||
       ' temporary tablespace ' || temporary_tablespace || ';' "user"
from   dba_users
where  username = '&userid'
/
select 'alter user &newuser quota '||
       decode(max_bytes, -1, 'unlimited', ceil(max_bytes / 1024 / 1024) || 'M') ||
       ' on ' || tablespace_name || ';'
from   dba_ts_quotas where username = '&&userid'
/
select 'grant ' ||granted_role || ' to &newuser' ||
       decode(admin_option, 'NO', ';', 'YES', ' with admin option;') "ROLE"
from   dba_role_privs where  grantee = '&&userid'
/
select 'grant ' || privilege || ' to &newuser' ||
       decode(admin_option, 'NO', ';', 'YES', ' with admin option;') "PRIV"
from   dba_sys_privs where  grantee = '&&userid'
/
spool off
undefine user
set verify on
set feedback on
set heading on
------------------------------------------------------------------------------------------------------------------------------------------------------
SQL>@D:\TEST\clone.sql
