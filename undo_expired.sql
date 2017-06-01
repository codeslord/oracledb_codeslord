select status, count(*) Num_Extents, sum(blocks) Num_Blocks, round((sum(bytes)/1024/1024),2) MB 
from dba_undo_extents group by status order by status;

Expired Undo
=======================================================
select   tablespace_name,   
status,
count(extent_id) "Extent Count",
sum(blocks) "Total Blocks",         
sum(blocks)*8/(1024*1024) total_space_gb
from     dba_undo_extents
group by    tablespace_name, status;
