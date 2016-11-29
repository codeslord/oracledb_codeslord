set lines 200 pages 1000
col event for a30
col username for a15
col osuser for a10
col machine for a10
col program for a30
select sid,blocking_session,username,sql_id,event,machine,osuser,program,last_call_et from v$session where blocking_session > 0;
