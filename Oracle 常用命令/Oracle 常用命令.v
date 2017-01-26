开始|运行：sqlplus /nolog
conn system/system@orcl_172.16.0.166 as sysdba
 
conn system/oracle as sysdba
 
 
创建数据表空间：
create (bigfile) tablespace rsimgdb
logging
datafile 'C:\app\zhouwei\oradata\orcl\rsimgdb.dbf'
size 50m
autoextend on
next 50m maxsize 20480m(unlimited)
extent management local;
 
create tablespace rsimgdb
logging
datafile '\\.\RAWRAC_RSIMGDB'
size 50m
autoextend on
next 50m maxsize 10000m
extent management local;
 
 
创建临时表空间：
create temporary tablespace user_temp
tempfile 'C:\app\zhouwei\oradata\orcl\user_temp.dbf'
size 50m
autoextend on
next 50m maxsize 20480m
extent management local;
 
create temporary tablespace user_temp
tempfile '\\.\RAWRAC_USER_TEMP'
size 50m
autoextend on
next 50m maxsize 10000m
extent management local;
 
删除表空间：
drop tablespace rsimgdb including contents and datafiles cascade onstraints;
 
如果删除表空间之前删除了表空间文件，解决办法: 
 
如果在清除表空间之前，先删除了表空间对应的数据文件，会造成数据库无法正常启动和关闭。 
可使用如下方法恢复（此方法已经在oracle9i中验证通过）： 
下面的过程中，filename是已经被删除的数据文件，如果有多个，则需要多次执行；tablespace_name是相应的表空间的名称。 
$ sqlplus /nolog 
SQL> conn / as sysdba; 
如果数据库已经启动，则需要先执行下面这行： 
SQL> shutdown abort 
SQL> startup mount 
SQL> alter database datafile 'filename' offline drop; 
SQL> alter database open; 
SQL> drop tablespace tablespace_name including contents; 
 
 
创建用户并指定表空间
create user rsimgdb identified by rsimgdb
default tablespace rsimgdb
temporary tablespace user_temp;
 
授权、撤权
grant connect,resource,dba to rsimgdb;
revoke dba from rsimgdb;
 
删除用户
drop user rsimgdb cascade;
 
ORA-01940:无法删除当前已链接的用户
(1)查看用户的连接状况
select username,sid,serial# from v$session
 
username sid serial#
----------------------------------------
NETBNEW 513 22974
NETBNEW 514 18183
NETBNEW 516 21573
NETBNEW 531 9
WUZHQ 532 4562
 
(2)找到要删除用户的sid,和serial，并删除
-------------------------------------------
如：你要删除用户'WUZHQ',可以这样做：
alter system kill session'532,4562'
 
(3)删除用户
--------------------------------------------
drop user username cascade 
 
(**)如果在drop 后还提示ORA-01940:无法删除当前已链接的用户，说明还有连接的session，可以通过查看session的状态来确定该session是否被kill 了，用如下语句查看：
 
-------------------------------------
 
select saddr,sid,serial#,paddr,username,status from v$session where username is not null
 
结果如下(以我的库为例)：
 
 saddr sid serial# paddr username status 
--------------------------------------------------------------------------------------------------------
564A1E28 513 22974 569638F4 NETBNEW ACTIVE
564A30DC 514 18183 569688CC NETBNEW INACTIVE
564A5644 516 21573 56963340 NETBNEW INACTIVE
564B6ED0 531 9 56962D8C NETBNEW INACTIVE
564B8184 532 4562 56A1075C WUZHQ KILLED 
 
status 为要删除用户的session状态，如果还为inactive，说明没有被kill掉，如果状态为killed，说明已kill。
由此可见，WUZHQ这个用户的session已经被杀死。此时可以安全删除用户。
 
 
Oracle导出表结构
set pagesize 0 
set long 90000 
set feedback off 
set echo off 
spool get_allddl.sql 
connect USERNAME/PASSWORD@SID;
SELECT DBMS_METADATA.GET_DDL('TABLE',u.table_name) 
FROM USER_TABLES u; 
SELECT DBMS_METADATA.GET_DDL('INDEX',u.index_name) 
FROM USER_INDEXES u; 
spool off;
 
查看表空间的名称及大小: 
SQL> SELECT T.TABLESPACE_NAME, ROUND(SUM(BYTES/(1024 * 1024)), 0) TS_SIZE
FROM DBA_TABLESPACES T, DBA_DATA_FILES D
WHERE T.TABLESPACE_NAME = D.TABLESPACE_NAME
GROUP BY T.TABLESPACE_NAME;
 
查看表空间物理文件的名称及大小:
 
SQL> SELECT TABLESPACE_NAME,FILE_ID,FILE_NAME,ROUND(BYTES / (1024 * 1024), 0) TOTAL_SPACE
FROM DBA_DATA_FILES
ORDER BY TABLESPACE_NAME;
 
查看回滚段名称及大小:
SQL> SELECT SEGMENT_NAME,
       TABLESPACE_NAME,
       R.STATUS,
       (INITIAL_EXTENT / 1024) INITIALEXTENT,
       (NEXT_EXTENT / 1024) NEXTEXTENT,
       MAX_EXTENTS,
       V.CUREXT CUREXTENT
FROM DBA_ROLLBACK_SEGS R, V$ROLLSTAT V
WHERE R.SEGMENT_ID = V.USN(+)
ORDER BY SEGMENT_NAME;
 
如何查看某个回滚段里面，跑的什么事物或者正在执行什么sql语句:
SQL> SELECT D.SQL_TEXT, A.NAME
FROM V$ROLLNAME A, V$TRANSACTION B, V$SESSION C, V$SQLTEXT D
WHERE A.USN = B.XIDUSN
   AND B.ADDR = C.TADDR
   AND C.SQL_ADDRESS = D.ADDRESS
   AND C.SQL_HASH_VALUE = D.HASH_VALUE
   AND A.USN = 1;
(备注：你要看哪个，就把usn=?写成几就行了)
 
查看控制文件:
SQL> SELECT * FROM V$CONTROLFILE;
 
查看日志文件:
SQL> COL MEMBER FORMAT A50
SQL>SELECT * FROM V$LOGFILE;
 
如何查看当前SQL*PLUS用户的sid和serial#:
SQL>SELECT SID, SERIAL#, STATUS FROM V$SESSION WHERE AUDSID=USERENV('SESSIONID');
 
如何查看当前数据库的字符集: 
SQL>SELECT USERENV('LANGUAGE') FROM DUAL; 
SQL>SELECT USERENV('LANG') FROM DUAL;
 
 
怎么判断当前正在使用何种SQL优化方式:
用EXPLAIN PLAN產生EXPLAIN PLAN?檢查PLAN_TABLE中ID=0的POSITION列的值
SQL>SELECT DECODE(NVL(POSITION,-1),-1,'RBO',1,'CBO') FROM PLAN_TABLE WHERE ID=0;
 
如何查看系统当前最新的SCN号：
SQL>SELECT MAX(KTUXESCNW * POWER(2,32) + KTUXESCNB) FROM X$KTUXE;
 
在ORACLE中查找TRACE文件的脚本:
 
SQL>SELECT U_DUMP.VALUE || '/' || INSTANCE.VALUE || '_ORA_' || 
V$PROCESS.SPID || NVL2(V$PROCESS.TRACEID, '_' || V$PROCESS.TRACEID, NULL ) || '.TRC'"TRACE FILE" FROM V$PARAMETER U_DUMP CROSS JOIN V$PARAMETER INSTANCE CROSS JOIN V$PROCESS JOIN V$SESSION ON V$PROCESS.ADDR = V$SESSION.PADDR WHERE U_DUMP.NAME = 'USER_DUMP_DEST' AND 
INSTANCE.NAME = 'INSTANCE_NAME' AND V$SESSION.AUDSID=SYS_CONTEXT('USERENV','SESSIONID');
 
SQL>SELECT D.VALUE || '/ORA_' || P.SPID || '.TRC' TRACE_FILE_NAME
FROM (SELECT P.SPID FROM SYS.V_$MYSTAT M,SYS.V_$SESSION S,
SYS.V_$PROCESS P WHERE M.STATISTIC# = 1 AND
S.SID = M.SID AND P.ADDR = S.PADDR) P,(SELECT VALUE FROM SYS.V_$PARAMETER WHERE NAME ='USER_DUMP_DEST') D;
 
如何查看客户端登陆的IP地址:
SQL>SELECT SYS_CONTEXT('USERENV','IP_ADDRESS') FROM DUAL;
 
如何在生产数据库中创建一个追踪客户端IP地址的触发器：
SQL>CREATE OR REPLACE TRIGGER ON_LOGON_TRIGGER AFTER LOGON ON DATABASE
BEGIN
DBMS_APPLICATION_INFO.SET_CLIENT_INFO(SYS_CONTEXT('USERENV', 'IP_ADDRESS'));
END;
 
REM 记录登陆信息的触发器
CREATE OR REPLACE TRIGGER LOGON_HISTORY 
AFTER LOGON ON DATABASE --WHEN (USER='WACOS') --ONLY FOR USER 'WACOS' 
BEGIN 
INSERT INTO SESSION_HISTORY SELECT USERNAME,SID,SERIAL#,AUDSID,OSUSER,ACTION,SYSDATE,NULL,SYS_CONTEXT('USERENV','IP_ADDRESS'),TERMINAL,MACHINE,PROGRAM FROM V$SESSION WHERE AUDSID = USERENV('SESSIONID'); 
END;
 
查询当前日期: 
SQL> SELECT TO_CHAR(SYSDATE,'YYYY-MM-DD,HH24:MI:SS') FROM DUAL;
 
查看所有表空间对应的数据文件名：
 
SQL>SELECT DISTINCT FILE_NAME,TABLESPACE_NAME,AUTOEXTENSIBLE FROM DBA_DATA_FILES;
 
查看表空间的使用情况:
SQL>SELECT SUM(BYTES)/(1024*1024) AS FREE_SPACE,TABLESPACE_NAME 
FROM DBA_FREE_SPACE GROUP BY TABLESPACE_NAME;
 
SQL>SELECT A.TABLESPACE_NAME,A.BYTES TOTAL,B.BYTES USED, C.BYTES FREE,
(B.BYTES*100)/A.BYTES "% USED",(C.BYTES*100)/A.BYTES "% FREE"
FROM SYS.SM$TS_AVAIL A,SYS.SM$TS_USED B,SYS.SM$TS_FREE C
WHERE A.TABLESPACE_NAME=B.TABLESPACE_NAME AND A.TABLESPACE_NAME=C.TABLESPACE_NAME; 
 
COLUMN TABLESPACE_NAME FORMAT A18; 
COLUMN SUM_M FORMAT A12; 
COLUMN USED_M FORMAT A12; 
COLUMN FREE_M FORMAT A12; 
COLUMN PTO_M FORMAT 9.99; 
 
SELECT S.TABLESPACE_NAME,CEIL(SUM(S.BYTES/1024/1024))||'M' SUM_M,CEIL(SUM(S.USEDSPACE/1024/1024))||'M' USED_M,CEIL(SUM(S.FREESPACE/1024/1024))||'M' FREE_M, SUM(S.USEDSPACE)/SUM(S.BYTES) PTUSED FROM (SELECT B.FILE_ID,B.TABLESPACE_NAME,B.BYTES, (B.BYTES-SUM(NVL(A.BYTES,0))) USEDSPACE, SUM(NVL(A.BYTES,0)) FREESPACE,(SUM(NVL(A.BYTES,0))/(B.BYTES)) * 100 FREEPERCENTRATIO FROM SYS.DBA_FREE_SPACE A,SYS.DBA_DATA_FILES B WHERE A.FILE_ID(+)=B.FILE_ID GROUP BY B.FILE_ID,B.TABLESPACE_NAME,B.BYTES ORDER BY B.TABLESPACE_NAME) S GROUP BY S.TABLESPACE_NAME ORDER BY SUM(S.FREESPACE)/SUM(S.BYTES) DESC;
 
查看数据文件的hwm（可以resize的最小空间）和文件头大小:
SELECT V1.FILE_NAME,V1.FILE_ID,NUM1 TOTLE_SPACE,NUM3 FREE_SPACE,
NUM1-NUM3 "USED_SPACE(HWM)",NVL(NUM2,0) DATA_SPACE,NUM1-NUM3-NVL(NUM2,0) FILE_HEAD 
FROM 
(SELECT FILE_NAME,FILE_ID,SUM(BYTES) NUM1 FROM DBA_DATA_FILES GROUP BY FILE_NAME,FILE_ID) V1,
(SELECT FILE_ID,SUM(BYTES) NUM2 FROM DBA_EXTENTS GROUP BY FILE_ID) V2,
(SELECT FILE_ID,SUM(BYTES) NUM3 FROM DBA_FREE_SPACE GROUP BY FILE_ID) V3
WHERE V1.FILE_ID=V2.FILE_ID(+) AND V1.FILE_ID=V3.FILE_ID(+);
数据文件大小及头大小:
SELECT V1.FILE_NAME,V1.FILE_ID, 
NUM1 TOTLE_SPACE, 
NUM3 FREE_SPACE, 
NUM1-NUM3 USED_SPACE, 
NVL(NUM2,0) DATA_SPACE, 
NUM1-NUM3-NVL(NUM2,0) FILE_HEAD 
FROM 
(SELECT FILE_NAME,FILE_ID,SUM(BYTES) NUM1 FROM DBA_DATA_FILES GROUP BY FILE_NAME,FILE_ID) V1, 
(SELECT FILE_ID,SUM(BYTES) NUM2 FROM DBA_EXTENTS GROUP BY FILE_ID) V2, 
(SELECT FILE_ID,SUM(BYTES) NUM3 FROM DBA_FREE_SPACE GROUP BY FILE_ID) V3 
WHERE V1.FILE_ID=V2.FILE_ID(+) 
AND V1.FILE_ID=V3.FILE_ID(+);
 
(运行以上查询，我们可以如下信息： 
Totle_pace:该数据文件的总大小，字节为单位 
Free_space:该数据文件的剩于大小，字节为单位 
Used_space:该数据文件的已用空间，字节为单位 
Data_space:该数据文件中段数据占用空间，也就是数据空间，字节为单位 
File_Head:该数据文件头部占用空间，字节为单位)

