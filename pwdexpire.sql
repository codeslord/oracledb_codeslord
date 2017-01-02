SQL> select 'alter user "'||d.username||'" identified by values '''||u.password||''';' c
from dba_users d, sys.user$ u
where d.username = upper('&&username')
and u.user# = d.user_id;  
Enter value for username: scott
old   3: where d.username = upper('&&username')
new   3: where d.username = upper('scott')

C
--------------------------------------------------------------------------------
alter user "SCOTT" identified by values 'F894844C34402B67';

SQL> alter user "SCOTT" identified by values 'F894844C34402B67';

To give a new Password:

sql> alter user [user_name] identified by [password];

6. Unlock user account using below command

sql> alter user [User_name] account unlock;

7. Crosscheck by value of accout_status field in dba_users view.

sql> select username,account_status from dba_users;

The value of account_status filed should by "OPEN" for corresponding user. 
