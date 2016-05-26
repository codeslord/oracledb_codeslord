set long 20000 longchunksize 20000 pagesize 0 linesize 1000 feedback off verify off trimspool on
column ddl format a1000
select dbms_metadata.get_ddl('USER', u.username) AS ddl
from   dba_users u
where  u.username = upper('&username');
