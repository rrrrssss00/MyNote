create database link ORACLELINK
  connect to SMKMAINV41 IDENTIFIED BY SMKMAINV41
  using '(DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.18.101)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = orcl101)
    )
    )';
 
CREATE [PUBLIC] DATABASE LINK link 
CONNECT TO username IDENTIFIED BY password
USING ‘connectstring’
 
SELECT * FROM camel.worker@zrhs_link ;

