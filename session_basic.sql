set lines 200 pages 1000
col osuser for a15
col machine for a30
col username for a20
select sid,serial#,username,machine,terminal,osuser,state,status,sql_id from v$session;
