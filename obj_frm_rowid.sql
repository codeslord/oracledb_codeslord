set lines 200 pages 1000
col object_name for a30
select object_name,object_type,owner from dba_objects where object_id = (select dbms_rowid.rowid_object( '&rowid' ) from dual);
