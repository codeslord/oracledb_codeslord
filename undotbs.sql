
To check retention guarantee for undo tablespace

select tablespace_name,status,contents,logging,retention from dba_tablespaces where tablespace_name like '%UNDO%';

To show ACTIVE/EXPIRED/UNEXPIRED Extents of Undo Tablespace

select     tablespace_name,   
status,
count(extent_id) "Extent Count",
sum(blocks) "Total Blocks",         
sum(blocks)*8/(1024*1024) total_space
from     dba_undo_extents
group by    tablespace_name, status;

Extent Count and Total Blocks

set linesize 152  
col tablespace_name for a20
col status for a10

select tablespace_name,status,count(extent_id) "Extent Count",
sum(blocks) "Total Blocks",sum(bytes)/(1024*1024*1024) spaceInGB
from   dba_undo_extents
where  tablespace_name in ('&undotbsp')
group by  tablespace_name,status;

To show UndoRetention Value

Show parameter undo_retention;


Undo retention in hours

col "Retention" for a30
col name for a30
col value for a50
select name "Retention",value/60/60 "Hours" from v$parameter where name like '%undo_retention%';

To check space related statistics of  UndoTablespace from stats$undostat of 90 days

select UNDOBLKS,BEGIN_TIME,MAXQUERYLEN,UNXPSTEALCNT,EXPSTEALCNT,NOSPACEERRCNT from stats$undostat where BEGIN_TIME between sysdate-90 and sysdate and UNXPSTEALCNT > 0;

To check space related statistics of  UndoTablespace from v$undostat

select
sum(ssolderrcnt) "Total ORA-1555s",
round(max(maxquerylen)/60/60) "Max Query HRS",
sum(unxpstealcnt) "UNExpired STEALS",
sum(expstealcnt) "Expired STEALS"
from v$undostat
order by begin_time;
Date wise occurrence of ORA-1555

select to_char(begin_time, 'mm/dd/yyyy hh24:mi') "Int. Start",
ssolderrcnt "ORA-1555s", maxquerylen "Max Query",
unxpstealcnt "UNExp SCnt",UNXPBLKRELCNT "UnEXPblks", expstealcnt "Exp SCnt",EXPBLKRELCNT "ExpBlks",
NOSPACEERRCNT nospace
from v$undostat where ssolderrcnt>0
order by begin_time;

Total number of ORA-1555s since instance startup

select 'TOTAL # OF ORA-01555 SINCE INSTANCE STARTUP : '|| to_char(startup_time,'DD-MON-YY HH24:MI:SS')
from v$instance;

To check for Active Transactions

set head on
select usn,extents,round(rssize/1048576)
rssize,hwmsize,xacts,waits,optsize/1048576 optsize,shrinks,wraps
from v$rollstat where xacts>0
order by rssize;

Undo Space Utilization by each Sessions

set lines 200
col sid for 99999
col username for a10
col name for a15
select  s.sid,s.serial#,username,s.machine,
t.used_ublk ,t.used_urec,rn.name,(t.used_ublk *8)/1024/1024 SizeGB
from    v$transaction t,v$session s,v$rollstat rs, v$rollname rn
where   t.addr=s.taddr and rs.usn=rn.usn and rs.usn=t.xidusn and rs.xacts>0;

List of long running queries since instance startup

set head off
select 'LIST OF LONG RUNNING - QUERY SINCE INSTANCE STARTUP' from dual;
set head on
select     *
from
(select to_char(begin_time, 'DD-MON-YY hh24:mi:ss') BEGIN_TIME ,
round((maxquerylen/3600),1) Hours
from v$undostat
order by maxquerylen desc)
where    rownum < 11;

Undo Space used by all transactions

set lines 200
col sid for 99999
col username for a10
col name for a15
select  s.sid,s.serial#,username,s.machine,
t.used_ublk ,t.used_urec,rn.name,(t.used_ublk *8)/1024/1024 SizeGB
from    v$transaction t,v$session s,v$rollstat rs, v$rollname rn
where   t.addr=s.taddr and rs.usn=rn.usn and rs.usn=t.xidusn and rs.xacts>0;

List of All active Transactions

select  sid,username,
t.used_ublk ,t.used_urec
from    v$transaction t,v$session s
where   t.addr=s.taddr;

To list all Datafile of UndoTablespace

select tablespace_name,file_name,file_id,autoextensible,bytes/1048576
Mbytes, maxbytes/1048576 maxMbytes
from dba_data_files
where tablespace_name like '%UNDO%'
or tablespace_name like '%RBS%'
order by tablespace_name,file_name;

select tablespace_name,file_name,file_id,autoextensible,bytes/1048576
Mbytes, maxbytes/1048576 maxMbytes
from dba_data_files
where tablespace_name like '%UNDOTBS2%'
order by tablespace_name,file_name;

col file_name for a40
set pagesize 100
select tablespace_name,file_name,file_id,autoextensible,bytes/1048576
Mbytes, maxbytes/1048576 maxMbytes
from dba_data_files
where tablespace_name like '%APPS_UNDOTS1%'
order by tablespace_name,file_name;

select file_name,tablespace_name,bytes/1024/1024,maxbytes/1024/1024,autoextensible
from dba_data_files where file_name like '%undo%' order by file_name;

To check when a table is last analysed

select OWNER,TABLE_NAME,TABLESPACE_NAME,STATUS,LAST_ANALYZED,PARTITIONED,DEPENDENCIES,DROPPED from dba_tables where TABLE_NAME like 'MLC_PICK_LOCKS_DETAIL';

select OWNER,TABLE_NAME,TABLESPACE_NAME,LAST_ANALYZED,PARTITIONED,DEPENDENCIES,DROPPED from dba_tables where TABLE_NAME like 'APPS.XLA_AEL_GL_V';

To list all Undo datafiles with status and size

show parameter undo
show parameter db_block_size
col tablespace_name form a20
col file_name form a60
set lines 120
select tablespace_name, file_name, status, bytes/1024/1024 from dba_data_files
where tablespace_name=(select tablespace_name from dba_tablespaces where contents='UNDO');

Total undo space

select    sum(bytes)/1024/1024/1024 GB from dba_data_files  where tablespace_name='&Undo_TB_Name';

Undo Tablespace

select tablespace_name from dba_tablespaces where tablespace_name like '%UNDO%';

To find MaxQueryLength from stats$undostat

Select Max(MAXQUERYLEN) from stats$undostat;

*select max(maxquerylen) from v$undostat;

*select begin_date,u.maxquerylen from
(select to_char(begin_time,'DD-MON-YYYY:HH24-MI-SS') begin_date,maxquerylen
from v$undostat order by maxquerylen desc) u  where rownum<11;

*select begin_date,u.maxquerylen from
(select maxquerylen,to_char(begin_time,'DD-MON-YYYY:HH24-MI-SS') begin_date from
v$undostat order by maxquerylen DESC) u  where rownum<26 order by begin_date ASC, maxquerylen DESC;

*select begin_date,u.maxquerylen from
(select maxquerylen,to_char(begin_time,'DD-MON-YYYY:HH24-MI-SS') begin_date from
v$undostat order by maxquerylen DESC) u  where rownum<26 order by  maxquerylen DESC;

*select sum(u.maxquerylen)/25 AvgUndoRetTime
from (select maxquerylen from v$undostat order by maxquerylen desc) u  where rownum<26;
*select sum(u.maxquerylen)
from (select maxquerylen from v$undostat order by maxquerylen desc) u  where rownum<26;

DBA_UNDO_EXTENTS

set linesize 152  
col tablespace_name for a20
col status for a10
select tablespace_name,status,count(extent_id) "Extent Count",
sum(blocks) "Total Blocks",sum(bytes)/(1024*1024*1024) spaceInGB
from   dba_undo_extents
group by  tablespace_name, status
order by tablespace_name;

Mapping Undo Segments to usernames

select  s.sid,s.serial#,username,s.machine,
t.used_ublk ,t.used_urec,(rs.rssize)/1024/1024 MB,rn.name
from    v$transaction t,v$session s,v$rollstat rs, v$rollname rn
where   t.addr=s.taddr and rs.usn=rn.usn and rs.usn=t.xidusn and rs.xacts>0;



Total Undo Statistics
alter session set nls_date_format='dd-mon-yy hh24:mi';
set lines 120
set pages 2000
select BEGIN_TIME,  END_TIME, UNDOBLKS, TXNCOUNT , MAXQUERYLEN  , UNXPSTEALCNT ,
EXPSTEALCNT , SSOLDERRCNT , NOSPACEERRCNT
from v$undostat;

Total Undo Statistics since specified year

select 'TOTAL STATISTICS SINCE Jan 01, 2005 - STATSPACK' from dual;
set head on
set lines 152
column undotsn format 999 heading 'Undo|TS#';
column undob format 9,999,999,999 heading 'Undo|Blocks';
column txcnt format 9,999,999,999,999 heading 'Num|Trans';
column maxq format 999,999 heading 'Max Qry|Len (s)';
column maxc format 9,999,999 heading 'Max Tx|Concurcy';
column snol format 9,999 heading 'Snapshot|Too Old';
column nosp format 9,999 heading 'Out of|Space';
column blkst format a13 heading 'uS/uR/uU/|eS/eR/eU' wrap;
column unst format 9,999 heading 'Unexp|Stolen' newline;
column unrl format 9,999 heading 'Unexp|Relesd';
column unru format 9,999 heading 'Unexp|Reused';
column exst format 9,999 heading 'Exp|Stolen';
column exrl format 9,999 heading 'Exp|Releas';
column exru format 9,999 heading 'Exp|Reused';
select undotsn
, sum(undoblks) undob
, sum(txncount) txcnt
, max(maxquerylen) maxq
, max(maxconcurrency) maxc
, sum(ssolderrcnt) snol
, sum(nospaceerrcnt) nosp
, sum(unxpstealcnt)
||'/'|| sum(unxpblkrelcnt)
||'/'|| sum(unxpblkreucnt)
||'/'|| sum(expstealcnt)
||'/'|| sum(expblkrelcnt)
||'/'|| sum(expblkreucnt) blkst
from stats$undostat
where dbid in (select dbid from v$database)
and instance_number in (select instance_number from v$instance)
and end_time > to_date('01012005 00:00:00', 'DDMMYYYY HH24:MI:SS')
and begin_time < (select sysdate from dual)
group by undotsn;

*SELECT (SUM(undoblks))/ SUM ((end_time - begin_time) * 86400) FROM v$undostat;

Checking for Recent ORA-1555

show parameter background

cd <background dump destination>
ls -ltr|tail

view <alert log file name>

shift + G ---> to get the tail end...

?ORA-1555 ---- to search of the error...

shift + N ---- to step for next reported error...

Rollback segment queries

Wraps

select name,extents,rssize/1048576 rssizeMB ,xacts,writes/1024/1024,optsize/1048576 optsize,
shrinks,wraps,extends,aveshrink/1048576,waits,rs.status,rs.curext
from v$rollstat rs, v$rollname rn  where  rn.usn=rs.usn
order by wraps;

Wraps column as high values for the all segments size of rollback segments are small for long running queries and transactions by increasing the  rollback segments size we can avoid  the  ORA-01555 errors

Undo Contention

Rollback Segment Contention

prompt   If any ratio is > .01 then more rollback segments are needed

column "total_waits" format 999,999,999
column "total_timeouts" format 999,999,999
column "Ratio" format 99.99999
select name, waits, gets, waits/gets "Ratio"
from v$rollstat a, v$rollname b
where a.usn = b.usn;

Sample Output:
REM NAME                              WAITS             GETS     Ratio
REM ------------------------------ ----------         ---------- ---------
REM SYSTEM                                  0                269    .00000
REM R01                                     0                304    .00000
REM R02                                     0               2820    .00000
REM R03                                     0                629    .00000
REM R04                                     1                511    .00196
REM R05                                     0                513    .00000
REM R06                                     1                503    .00199
REM R07                                     0                301    .00000
REM R08                                     0                299    .00000

Looking at the tcl script to see what sql gets performed to determine rollback
segment contention

select count from v$waitstat where class = 'system undo header';
select count from v$waitstat where class = 'system undo block';
select count from v$waitstat where class = 'undo header';
select count from v$waitstat where class = 'undo block';               

Rollback Segment Information

set lines 152
col segment_type  for a10
col tablespace_name for a20
select owner,tablespace_name,extents,next_extent/1024 next_extnentKB,max_extents,pct_increase 
from dba_segments
where segment_type='ROLLBACK';

* set lines 152
col name for a15
select name,extents,rssize/1048576 rssizeMB ,xacts,writes/1024/1024,optsize/1048576 optsize,
shrinks,wraps,aveshrink/1048576,waits,rs.status,rs.curext
from v$rollstat rs, v$rollname rn  where  rn.usn=rs.usn and rs.xacts>0;

* select name,extents,rssize/1048576 rssizeMB ,xacts,writes/1024/1024,optsize/1048576 optsize,
shrinks,wraps,extends,aveshrink/1048576,waits,rs.status,rs.curext
from v$rollstat rs, v$rollname rn  where  rn.usn=rs.usn
order by wraps;

* select name,extents,optsize/1048576 optsize,
shrinks,wraps,aveshrink/1048576,aveactive,rs.status,rs.curext
from v$rollstat rs, v$rollname rn  where  rn.usn=rs.usn;

* select  sum(rssize)/1024/1024/1024 sizeGB from v$rollstat;

* select sum(xacts) from v$rollstat;
select  sum(rssize)/1024/1024/1024 sizeGB from v$rollstat where xacts=0;
select  sum(rssize)/1024/1024/1024 sizeGB from v$rollstat where xacts>0;
select sum(xacts) from v$rollstat;

* select tablespace_name,segment_name,initial_extent,next_extent,min_extents,max_extents,status
from dba_rollback_segs
where status='ONLINE';

* select tablespace_name,file_name,bytes/1024/1024,maxbytes/1024/1024,autoextensible
from dba_data_files where file_name like '%&filename%';

* select sum(bytes)/1024/1024 from dba_free_space where tablespace_name='&tbs';

Optimize Oracle UNDO Parameters

Actual Undo Size
SELECT SUM(a.bytes/1024/1024/1024) "UNDO_SIZE"
FROM v$datafile a,
v$tablespace b,
dba_tablespaces c
WHERE c.contents = 'UNDO'
AND c.status = 'ONLINE'
AND b.name = c.tablespace_name
AND a.ts# = b.ts#;

UNDO_SIZE
----------
209715200

Undo Blocks per Second

SELECT MAX(undoblks/((end_time-begin_time)*3600*24))
"UNDO_BLOCK_PER_SEC"
FROM v$undostat;

UNDO_BLOCK_PER_SEC
------------------
3.12166667

Undo Segment Summary for DB

Undo Segment Summary for DB: S901  Instance: S901  Snaps: 2 -3
-> Undo segment block stats:
-> uS - unexpired Stolen,   uR - unexpired Released,   uU - unexpired reUsed
-> eS - expired   Stolen,   eR - expired   Released,   eU - expired   reUsed

Undo           Undo        Num  Max Qry     Max Tx Snapshot Out of uS/uR/uU/
TS#         Blocks      Trans  Len (s)   Concurcy  Too Old  Space eS/eR/eU
---- -------------- ---------- -------- ---------- -------- ------ -------------
1         20,284      1,964        8         12        0      0 0/0/0/0/0/0

Undo Segment Stats for DB

Undo Segment Stats for DB: S901  Instance: S901  Snaps: 2 -3
-> ordered by Time desc

Undo      Num Max Qry   Max Tx  Snap   Out of uS/uR/uU/
End Time           Blocks    Trans Len (s)    Concy Too Old  Space eS/eR/eU
------------ ------------ -------- ------- -------- ------- ------ -------------
12-Mar 16:11       18,723    1,756       8       12       0      0 0/0/0/0/0/0
12-Mar 16:01        1,561      208       3       12       0      0 0/0/0/0/0/0

Undo Segment Space Required = (undo_retention_time * undo_blocks_per_seconds)

As an example, an UNDO_RETENTION of 5 minutes (default) with 50 undo blocks/second (8k blocksize)
will generate:
Undo Segment Space Required = (300 seconds * 50 blocks/ seconds * 8K/block) = 120 M


select tablespace_name,file_name,file_id,autoextensible,bytes/1048576
Mbytes, maxbytes/1048576 maxMbytes
from dba_data_files
where tablespace_name like '%UNDO%'
or tablespace_name like '%RBS%'
or tablespace_name like '%ROLLBACK%'
order by tablespace_name,file_name;

select a.owner,a.tablespace_name,b.status, a.extents,a.next_extent/1024 next_extnentKB,a.max_extents,a.pct_increase from dba_segments a,dba_tablespaces b
where segment_type='ROLLBACK' and a.tablespace_name=b.tablespace_name;

select tablespace_name,status from dba_tablespaces where tablespace_name='ROLLBACK';

Actual Undo Size

SELECT SUM(a.bytes/1024/1024) "UNDO_SIZE"
FROM v$datafile a,
v$tablespace b,
dba_tablespaces c
WHERE c.contents = 'UNDO'
AND c.status = 'ONLINE'
AND b.name = c.tablespace_name
AND a.ts# = b.ts#;

UNDO_SIZE
----------
209715200

Undo Blocks per Second

SELECT MAX(undoblks/((end_time-begin_time)*3600*24))
"UNDO_BLOCK_PER_SEC"
FROM v$undostat;

UNDO_BLOCK_PER_SEC
------------------
3.12166667

DB Block Size

SELECT TO_NUMBER(value) "DB_BLOCK_SIZE [KByte]"
FROM v$parameter
WHERE name = 'db_block_size';

DB_BLOCK_SIZE [Byte]
--------------------
4096

Optimal Undo Retention

209'715'200 / (3.12166667 * 4'096) = 16'401 [Sec]

Using Inline Views, you can do all in one query!

SELECT d.undo_size/(1024*1024) "ACTUAL UNDO SIZE [MByte]",
SUBSTR(e.value,1,25) "UNDO RETENTION [Sec]",
ROUND((d.undo_size / (to_number(f.value) *
g.undo_block_per_sec))) "OPTIMAL UNDO RETENTION [Sec]"
FROM (
SELECT SUM(a.bytes) undo_size
FROM v$datafile a,
v$tablespace b,
dba_tablespaces c
WHERE c.contents = 'UNDO'
AND c.status = 'ONLINE'
AND b.name = c.tablespace_name
AND a.ts# = b.ts#
) d,
v$parameter e,
v$parameter f,
(
SELECT MAX(undoblks/((end_time-begin_time)*3600*24))
undo_block_per_sec
FROM v$undostat
) g
WHERE e.name = 'undo_retention'
AND f.name = 'db_block_size'
/

ACTUAL UNDO SIZE [MByte]
------------------------
200

UNDO RETENTION [Sec]
--------------------
10800

OPTIMAL UNDO RETENTION [Sec]
----------------------------
16401

Calculate Needed UNDO Size for given Database Activity

If you are not limited by disk space, then it would be better to choose the UNDO_RETENTION time that is best for you (for FLASHBACK, etc.). Allocate the appropriate size to the UNDO tablespace according to the database activity:

Again, all in one query:

SELECT d.undo_size/(1024*1024) "ACTUAL UNDO SIZE [MByte]",
SUBSTR(e.value,1,25) "UNDO RETENTION [Sec]",
(TO_NUMBER(e.value) * TO_NUMBER(f.value) *
g.undo_block_per_sec) / (1024*1024)
"NEEDED UNDO SIZE [MByte]"
FROM (
SELECT SUM(a.bytes) undo_size
FROM v$datafile a,
v$tablespace b,
dba_tablespaces c
WHERE c.contents = 'UNDO'
AND c.status = 'ONLINE'
AND b.name = c.tablespace_name
AND a.ts# = b.ts#
) d,
v$parameter e,
v$parameter f,
(
SELECT MAX(undoblks/((end_time-begin_time)*3600*24))
undo_block_per_sec
FROM v$undostat
) g
WHERE e.name = 'undo_retention'
AND f.name = 'db_block_size'
/

ACTUAL UNDO SIZE [MByte]
------------------------
200
UNDO RETENTION [Sec]
--------------------
10800
NEEDED UNDO SIZE [MByte]
------------------------
131.695313

Checking when tables are last analyzed
select
OWNER,TABLE_NAME,TABLESPACE_NAME,STATUS,LAST_ANALYZED,PARTITIONED,DEPENDENCIES,DROPPED from
dba_tables where TABLE_NAME like 'MLC_END_USER_REGISTRATION';

DECLARE
v_table_space_name      VARCHAR2(30);
v_table_space_size_in_MB        NUMBER(9);
v_auto_extend      BOOLEAN;
v_undo_retention      NUMBER(9);
v_retention_guarantee    BOOLEAN;
v_undo_info_return    BOOLEAN;
BEGIN
v_undo_info_return := dbms_undo_adv.undo_info(v_table_space_name, v_table_space_size_in_MB, v_auto_extend, v_undo_retention, v_retention_guarantee);
dbms_output.put_line(’UNDO Tablespace Name: ‘ || v_table_space_name);
dbms_output.put_line(’UNDO Tablespace size (MB) : ‘ || TO_CHAR(v_table_space_size_in_MB));
dbms_output.put_line(’If UNDO tablespace is auto extensible above size indicates max possible size of the undo tablespace’);
dbms_output.put_line(’UNDO tablespace auto extensiable is : ‘|| CASE WHEN v_auto_extend THEN  ‘ON’ ELSE ‘OFF’ END);
dbms_output.put_line(’Undo Retention (Sec): ‘ || v_undo_retention);
dbms_output.put_line(’Retention : ‘||CASE WHEN v_retention_guarantee THEN ‘Guaranteed ‘ ELSE ‘NOT Guaranteed’ END);
END;

undo_autotune

This function is used to find auto tuning of undo retention is ENABLED or NOT.

Set serverout on
declare
v_autotune_return Boolean := null;
v_autotune_enabled boolean := null;
begin
v_autotune_return:= dbms_undo_adv.undo_autotune(v_autotune_enabled);
dbms_output.put_line(CASE WHEN v_autotune_return THEN 'Information is available :' ELSE 'Information is NOT available :' END||
CASE WHEN v_autotune_enabled THEN 'Auto tuning of undo retention is ENABLED' ELSE 'Auto tuning of undo retention is NOT enabled' END);
end;
/

select dbms_undo_adv.longest_query from dual

select dbms_undo_adv.required_retention from dual


select dbms_undo_adv.best_possible_retention from dual

select  dbms_undo_adv.required_undo_size(1800) from dual

DECLARE
v_undo_health_return number;
v_retention number;
v_utbsize number;
v_problem VARCHAR2(1024);
v_recommendation VARCHAR2(1024);
v_rationale VARCHAR2(1024);
BEGIN
v_undo_health_return :=  dbms_undo_adv.undo_health(problem => v_problem,
recommendation => v_recommendation,
rationale => v_rationale,
retention => v_retention,
utbsize => v_utbsize);
dbms_output.put_line(’Problem : ‘||v_problem);
dbms_output.put_line(’Recommendation= : ‘||v_recommendation);
dbms_output.put_line(’Rationale : ‘||v_retention);
dbms_output.put_line(’Retention : ‘||v_retention);
dbms_output.put_line(’UNDO tablespace size : ‘||v_utbsize);
END;

undo_advisor

It uses oracle’s advisor framework to find out problem and provide recommendations.

DECLARE
v_undo_advisor_return VARCHAR2(100);
BEGIN
v_undo_advisor_return := dbms_undo_adv.undo_advisor(instance => 1);
dbms_output.put_line(v_undo_advisor_return);
END;
