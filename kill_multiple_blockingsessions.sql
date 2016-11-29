spool kill_session.sql
select 'alter system kill session ''' ||sid|| ',' || serial#|| ''' immediate;' from v$session where blocking_session > 0;
spool off
@kill_session.sql
