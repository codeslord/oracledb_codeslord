-- Display retention period:
select dbms_stats.get_stats_history_retention from dual;

-- Manually purge after x days and before
exec dbms_stats_purge_stats(SYSDATE-30);

-- Set retention period to 90 days
exec dbms_stats.alter_stats_history_retention(90);
