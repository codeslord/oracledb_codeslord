select sum(bytes/1024/1024) Total_MB from dba_data_files where file_id=&fileid;
select sum(bytes/1024/1024) Free_MB from dba_free_space where file_id=&fileid;

SELECT FILE#,name, bytes/1024/1024 AS size_mb
FROM   v$datafile;

set lines 200 pages 1000
col for file_name for a55
select file_id,file_name,tablespace_name from dba_data_files where tablespace_name in ('DATA3','DATA7','INDEX2','INDEX3','VERITAS_I3_DATA') order by 3;
