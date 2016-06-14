SELECT userhost,userid, action#,returncode, To_Char (ntimestamp#, 'dd-mm-yyyy hh24:mi:ss')
FROM sys.aud$ where userid='TIVOLI' ORDER BY ntimestamp# asc;
