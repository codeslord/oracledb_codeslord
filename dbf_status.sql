set lines 200 pages 1000
col file_name for a55
select d.file_name,d.tablespace_name,v.status,v.enabled 
from dba_data_files d,v$datafile v
where d.file_id=v.file#
order by d.tablespace_name;
