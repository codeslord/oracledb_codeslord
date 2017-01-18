 To check instance-wise total allocated, total used TEMP for both rac and non-rac

set lines 152
col FreeSpaceGB format 999.999
col UsedSpaceGB format 999.999
col TotalSpaceGB format 999.999
col host_name format a30
col tablespace_name format a30
select tablespace_name,
(free_blocks*8)/1024/1024 FreeSpaceGB,
(used_blocks*8)/1024/1024 UsedSpaceGB,
(total_blocks*8)/1024/1024 TotalSpaceGB,
i.instance_name,i.host_name
from gv$sort_segment ss,gv$instance i where ss.tablespace_name in (select tablespace_name from dba_tablespaces where contents='TEMPORARY') and
i.inst_id=ss.inst_id;

Total Used and Total Free Blocks

select inst_id, tablespace_name, total_blocks, used_blocks, free_blocks  from gv$sort_segment;

Another Query to check TEMP USAGE

col name for a20
SELECT d.status "Status", d.tablespace_name "Name", d.contents "Type", d.extent_management
"ExtManag",
TO_CHAR(NVL(a.bytes / 1024 / 1024, 0),'99,999,990.900') "Size (M)", TO_CHAR(NVL(t.bytes,
0)/1024/1024,'99999,999.999') ||'/'||TO_CHAR(NVL(a.bytes/1024/1024, 0),'99999,999.999') "Used (M)",
TO_CHAR(NVL(t.bytes / a.bytes * 100, 0), '990.00') "Used %"
FROM sys.dba_tablespaces d, (select tablespace_name, sum(bytes) bytes from dba_temp_files group by
tablespace_name) a,
(select tablespace_name, sum(bytes_cached) bytes from
v$temp_extent_pool group by tablespace_name) t
WHERE d.tablespace_name = a.tablespace_name(+) AND d.tablespace_name = t.tablespace_name(+)
AND d.extent_management like 'LOCAL' AND d.contents like 'TEMPORARY';

Temporary Tablespace groups

SELECT * FROM DATABASE_PROPERTIES where PROPERTY_NAME='DEFAULT_TEMP_TABLESPACE';

select tablespace_name,contents from dba_tablespaces where tablespace_name like '%TEMP%';

select * from dba_tablespace_groups;

Block wise Check

select TABLESPACE_NAME, TOTAL_BLOCKS, USED_BLOCKS, MAX_USED_BLOCKS, MAX_SORT_BLOCKS, FREE_BLOCKS from V$SORT_SEGMENT;

select sum(free_blocks) from gv$sort_segment where tablespace_name = 'TEMP';
To Check Percentage Usage of Temp Tablespace

select (s.tot_used_blocks/f.total_blocks)*100 as "percent used"
from (select sum(used_blocks) tot_used_blocks
from v$sort_segment where tablespace_name='TEMP') s,
(select sum(blocks) total_blocks
from dba_temp_files where tablespace_name='TEMP') f;

To check Used Extents ,Free Extents available in Temp Tablespace

SELECT tablespace_name, extent_size, total_extents, used_extents,free_extents, max_used_size FROM v$sort_segment;

To list all tempfiles of Temp Tablespace

col file_name for a45
select tablespace_name,file_name,bytes/1024/1024,maxbytes/1024/1024,autoextensible from dba_temp_files  order by file_name;

SELECT d.tablespace_name tablespace , d.file_name filename, d.file_id fl_id, d.bytes/1024/1024
size_m
, NVL(t.bytes_cached/1024/1024, 0) used_m, TRUNC((t.bytes_cached / d.bytes) * 100) pct_used
FROM
sys.dba_temp_files d, v$temp_extent_pool t, v$tempfile v
WHERE (t.file_id (+)= d.file_id)
AND (d.file_id = v.file#);

Additional checks

select distinct(temporary_tablespace) from dba_users;

select username,default_tablespace,temporary_tablespace from dba_users order by temporary_tablespace;

SELECT * FROM DATABASE_PROPERTIES where PROPERTY_NAME='DEFAULT_TEMP_TABLESPACE';

Changing the default temporary Tablespace

SQL> alter database default temporary tablespace TEMP;

Database altered.

To add tempfile to Temp Tablespace

alter tablespace  temp  add tempfile '&tempfilepath' size 1800M;

alter tablespace temp add tempfile '/m001/oradata/SID/temp02.dbf' size 1000m;

alter tablespace TEMP add tempfile '/SID/oradata/data02/temp04.dbf' size 1800M autoextend on maxsize 1800M;

To resize the  tempfile in Temp Tablespace

alter database tempfile '/u02/oradata/TESTDB/temp01.dbf' resize 250M

alter database tempfile '/SID/oradata/data02/temp12.dbf' autoextend on maxsize 1800M;

alter tablespace TEMP add tempfile '/SID/oradata/data02/temp05.dbf' size 1800m reuse;

To find Sort Segment Usage by Users

select username,sum(extents) "Extents",sum(blocks) "Block"
from v$sort_usage
group by username;

To find Sort Segment Usage by a particular User

SELECT s.username,s.sid,s.serial#,u.tablespace, u.contents, u.extents, u.blocks
FROM v$session s, v$sort_usage u
WHERE s.saddr=u.session_addr
order by u.blocks desc;

To find Total Free space in Temp Tablespace

select 'FreeSpace  ' || (free_blocks*8)/1024/1024 ||' GB'  from v$sort_segment where tablespace_name='TEMP';

select tablespace_name , (free_blocks*8)/1024/1024  FreeSpaceInGB,
(used_blocks*8)/1024/1024  UsedSpaceInGB,
(total_blocks*8)/1024/1024  TotalSpaceInGB
from v$sort_segment where tablespace_name like '%TEMP%'

To find  Total Space Allocated for Temp Tablespace

select 'TotalSpace ' || (sum(blocks)*8)/1024/1024 ||' GB'  from dba_temp_files where tablespace_name='TEMP';

Get 10 sessions with largest temp usage

cursor bigtemp_sids is
select * from (
select s.sid,
s.status,
s.sql_hash_value sesshash,
u.SQLHASH sorthash,
s.username,
u.tablespace,
sum(u.blocks*p.value/1024/1024) mbused ,
sum(u.extents) noexts,
nvl(s.module,s.program) proginfo,
floor(last_call_et/3600)||':'||
floor(mod(last_call_et,3600)/60)||':'||
mod(mod(last_call_et,3600),60) lastcallet
from v$sort_usage u,
v$session s,
v$parameter p
where u.session_addr = s.saddr
and p.name = 'db_block_size'
group by s.sid,s.status,s.sql_hash_value,u.sqlhash,s.username,u.tablespace,
nvl(s.module,s.program),
floor(last_call_et/3600)||':'||
floor(mod(last_call_et,3600)/60)||':'||
mod(mod(last_call_et,3600),60)
order by 7 desc,3)
where rownum < 11;

Displays the amount of IO for each tempfile

SELECT SUBSTR(t.name,1,50) AS file_name,
f.phyblkrd AS blocks_read,
f.phyblkwrt AS blocks_written,
f.phyblkrd + f.phyblkwrt AS total_io
FROM   v$tempstat f,v$tempfile t
WHERE  t.file# = f.file#
ORDER BY f.phyblkrd + f.phyblkwrt DESC;

select * from (SELECT u.tablespace, s.username, s.sid, s.serial#, s.logon_time, program, u.extents, ((u.blocks*8)/1024) as MB,
i.inst_id,i.host_name
FROM gv$session s, gv$sort_usage u ,gv$instance i
WHERE s.saddr=u.session_addr and u.inst_id=i.inst_id  order by MB DESC) a where rownum<10;

Check for ORA-1652

show parameter background

cd <background dump destination>

ls -ltr|tail

view <alert log file name>

shift + G ---> to get the tail end...

?ORA-1652 ---- to search of the error...

shift + N ---- to step for next reported error...

I used these queries to check some settings:

-- List all database files and their tablespaces:
select  file_name, tablespace_name, status
,bytes   /1000000  as MB
,maxbytes/1000000  as MB_max
from dba_data_files ;

-- What temporary tablespace is each user using?:
select username, temporary_tablespace, default_tablespace from dba_users ;

-- List all tablespaces and some settings:
select tablespace_name, status, contents, extent_management
from dba_tablespaces ;

TABLESPACE_NAME                CONTENTS  EXTENT_MAN STATUS
------------------------------ --------- ---------- ---------
SYSTEM                         PERMANENT DICTIONARY ONLINE
TOOLS                          PERMANENT DICTIONARY ONLINE
TEMP                           TEMPORARY DICTIONARY OFFLINE
TMP                            TEMPORARY LOCAL      ONLINE

Now, the above query and the storage clause of the old 'create tablespace TEMP' command seem to tell us the tablespace only allows temporary objects, so it should be safe to assume that no one created any tables or other permanent objects in TEMP by mistake, as I think Oracle would prevent that. However, just to be absolutely certain, I decided to double-check. Checking for any tables in the tablespace is very easy:

-- Show number of tables in the TEMP tablespace - SHOULD be 0:
select count(*)  from dba_all_tables
where tablespace_name = 'TEMP' ;

Checking for any other objects (views, indexes, triggers, pl/sql, etc.) is trickier, but this query seems to work correctly - note that you'll probably need to connect internal in order to see the sys_objects view:

-- Shows all objects which exist in the TEMP tablespace - should get
-- NO rows for this:
column owner        format a20
column object_type  format a30
column object_name  format a40
select
o.owner  ,o.object_name
,o.object_type
from sys_objects s
,dba_objects o
,dba_data_files df
where df.file_id = s.header_file
and o.object_id = s.object_id
and df.tablespace_name = 'TEMP' ;

Identifying WHO is currently using TEMP Segments

10g onwards

SELECT sysdate,a.username, a.sid, a.serial#, a.osuser, (b.blocks*d.block_size)/1048576 MB_used, c.sql_text
FROM v$session a, v$tempseg_usage b, v$sqlarea c,
     (select block_size from dba_tablespaces where tablespace_name='TEMP') d
    WHERE b.tablespace = 'TEMP'
    and a.saddr = b.session_addr
    AND c.address= a.sql_address
    AND c.hash_value = a.sql_hash_value
    AND (b.blocks*d.block_size)/1048576 > 1024
    ORDER BY b.tablespace, 6 desc;
