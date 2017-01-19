SELECT sum(bytes/1024/1024)
FROM dba_segments
WHERE owner = '&&username';
