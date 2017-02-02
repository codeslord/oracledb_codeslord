select sum(bytes/1024/1024) Total_MB from dba_data_files where file_id=&fileid;
select sum(bytes/1024/1024) Free_MB from dba_free_space where file_id=&fileid;
