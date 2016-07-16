SET LINES 200 PAGES 1000
col ACTION_TIME for a30
col ACTION for a11
col NAMESPACE for a11
col VERSION for a20
col COMMENTS for a22
COL HOST_NAME for a25
COL BUNDLE_SERIES for a15
select host_name,instance_name from v$instance;
select * from dba_registry_history;
