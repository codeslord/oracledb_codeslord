CREATE USER "CHANVIG" IDENTIFIED BY Welcome$111
      DEFAULT TABLESPACE "USERS"
      TEMPORARY TABLESPACE "TEMP";

GRANT CONNECT,RESOURCE TO "CHANVIG";

GRANT UNLIMITED TABLESPACE TO "CHANVIG";

=========================================SELECTIVE SCHEMAS==================================================================

Select 'GRANT INSERT,UPDATE,DELETE ON '||OWNER||'.'||OBJECT_NAME||' TO CHANVIG;'  From dba_objects Where OWNER IN ('OFSAA_OWNER','OFSAA_CONFIG');
select 'GRANT EXECUTE ON '||OWNER||'.'||OBJECT_NAME||' TO CHANVIG;'  From dba_objects Where OWNER IN ('OFSAA_OWNER','OFSAA_CONFIG') and object_type in ('PROCEDURE','PACKAGE');  

=========================================ALL SCHEMAS==================================================================
Select 'GRANT INSERT,UPDATE,DELETE ON '||OWNER||'.'||OBJECT_NAME||' TO CHANVIG;'  From dba_objects Where Owner NOT IN ('SYS','SYSTEM','WMSYS','PUBLIC','SYSMAN','OUTLN','AWR_STAGE','CSMIG','CTXSYS','DBSNMP','DIP','DMSYS','DSSYS','EXFSYS','LBACSYS','MDSYS','ORACLE_OCM','ORDPLUGINS','ORDSYS','PERFSTAT','TRACESVR','TSMSYS','XDB');

select 'GRANT EXECUTE ON '||OWNER||'.'||OBJECT_NAME||' TO CHANVIG;'  From dba_objects Where Owner NOT IN ('SYS','SYSTEM','WMSYS','PUBLIC','SYSMAN','OUTLN','AWR_STAGE','CSMIG','CTXSYS','DBSNMP','DIP','DMSYS','DSSYS','EXFSYS','LBACSYS','MDSYS','ORACLE_OCM','ORDPLUGINS','ORDSYS','PERFSTAT','TRACESVR','TSMSYS','XDB');

=========================================SINGLE SCHEMAS==================================================================

Select 'GRANT INSERT,UPDATE,DELETE ON APP_REF_DATA.'||OBJECT_NAME||' TO CHANVIG;'  From dba_objects Where Owner ='APP_REF_DATA';
select 'GRANT EXECUTE ON APP_REF_DATA.'||OBJECT_NAME||' TO CHANVIG;'  From dba_objects Where Owner='APP_REF_DATA' and object_type in ('PROCEDURE','PACKAGE');  
 
