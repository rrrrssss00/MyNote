[数据库] Oracle 使用SQL 查看表结构和索引
oracle, 数据库, 甲骨文, 表结构, 索引
分享到： 新浪微博 腾讯微博 QQ空间 QQ好友 更多
select dbms_metadata.get_ddl('TABLE','表名','用户名') from dual;

select dbms_metadata.get_ddl('INDEX','表名','用户名') from dual;



DUAL 表详细说明

1、DUAL表的用途
Dual 是 Oracle中的一个实际存在的表，任何用户均可读取，常用在没有目标表的Select语句块中
--查看当前连接用户
SQL> select user from dual;
USER
------------------------------
SYSTEM
--查看当前日期、时间
SQL> select sysdate from dual;
SYSDATE
-----------
2007-1-24 1
SQL> select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') from dual;
TO_CHAR(SYSDATE,'YYYY-MM-DDHH2
------------------------------
2007-01-24 15:02:47
--当作计算器用
SQL> select 1+2 from dual;
1+2
----------
3
--查看序列值
SQL> create sequence aaa increment by 1 start with 1;
SQL> select aaa.nextval from dual;
NEXTVAL
----------
1
SQL> select aaa.currval from dual;
CURRVAL
----------
1

2、关于DUAL表的测试与分析
DUAL就是个一行一列的表，如果你往里执行insert、delete、truncate操作，就会导致很多程序出问题。结果也因sql*plus、pl/sql dev等工具而异。
--查看DUAL是什么OBJECT
--DUAL是属于SYS schema的一个表,然后以PUBLIC SYNONYM的方式供其他数据库USER使用.
SQL> select owner, object_name , object_type from dba_objects where object_name like '%DUAL%';
OWNER OBJECT_NAME OBJECT_TYPE
---------- ----------------- ------------------
SYS DUAL TABLE
PUBLIC DUAL SYNONYM

--查看表结构，只有一个字段DUMMY，为VARCHAR2(1)型
SQL> desc dual
Name Type Nullable Default Comments
----- ----------- -------- ------- --------
DUMMY VARCHAR2(1) Y

--DUAL表的结构：
create table SYS.DUAL
(
DUMMY VARCHAR2(1)
)
tablespace SYSTEM
pctfree 10
pctused 40
initrans 1
maxtrans 255
storage
(
initial 16K
next 16K
minextents 1
maxextents 505
pctincrease 50
);

/*
很是困惑，ORACLE为什么要用VARCHAR(1)型，用CHAR(1)难道不好么？从这样的表结构来看，DUAL表设计的目的就是要尽可能的简单，以减少检索的开销。
还有，DUAL表是建立在SYSTEM表空间的，第一是因为DUAL表是SYS这个用户建的，本来默认的表空间就是SYSTEM；第二，把这个可能经常被查询的表和用户表分开来存放，对于系统性能的是有好处的。
有了创建了表、创建了同义词还是不够的。DUAL在SYS这个Schema下面，因此用别的用户登录是无法查询这个表的，因此还需要授权：
grant select on SYS.DUAL to PUBLIC with grant option;
将Select 权限授予公众。
接下来看看DUAL表中的数据，事实上，DUAL表中的数据和ORACLE数据库环境有着十分重要的关系（ORACLE不会为此瘫痪，但是不少存储过程以及一些查询将无法被正确执行）。
*/

--查询行数
--在创建数据库之后，DUAL表中便已经被插入了一条记录。个人认为：DUMMY字段的值并没有什么关系，重要的是DUAL表中的记录数
SQL> select count(*) from dual;
COUNT(*)
----------
1

SQL> select * from dual;
DUMMY
-----
X

--插入数据，再查询记录，只返回一行记录
SQL> insert into dual values ('Y');
1 row created.
SQL> commit;
Commit complete.
SQL> insert into dual values ('X');
1 row created.
SQL> insert into dual values ('Z');
1 row created.
SQL> commit;
Commit complete.
SQL> select count(*) from dual;
COUNT(*)
----------
4
SQL> select * from dual;
DUMMY
-----
X

/*
--假我们插入一条数据，DUAL表不是返回一行，而是多行记录，那会是什么结果呢？
SQL> insert into dual values('Y');
1 行 已插入
SQL> commit;
提交完成
SQL> select * from dual;
DUMMY
-----
X
Y
SQL> select sysdate from dual;
SYSDATE
-----------
2004-12-15
2004-12-15

这个时候返回的是两条记录，这样同样会引起问题。在通过使用
select sysdate into v_sysdate from dual;
来获取时间或者其他信息的存储过程来说，ORACLE会抛出TOO_MANY_ROWS(ORA-01422)异常。
因此，需要保证在DUAL表内有且仅有一条记录。当然，也不能把DUAL表的UPDATE，INSERT，DELETE权限随意释放出去，这样对于系统是很危险的
*/

--把表截掉
SQL> truncate table dual;
Table truncated.
SQL> select count(*) from dual;
COUNT(*)
----------
0
SQL> select * from dual;
no rows selected
SQL> select sysdate from dual;
no rows selected

--试着把DUAL表中的数据删除，看看会出现什么结果：
SQL> delete from dual;
1 行 已删除
SQL> select * from dual;
DUMMY
-----
SQL> select sysdate from dual;
SYSDATE
-----------
/*
我们便取不到系统日期了。因为，sysdate是个函数，作用于每一个数据行。现在没有数据了，自然就不可能取出系统日期。
这个对于很多用
select sysdate into v_sysdate from dual;
这种方式取系统时间以及其他信息的存储过程来说是致命的，因为，ORACLE会马上抛出一个NO_DATA_FOUND（ORA-01403）的异常，即使异常被捕获，存储过程也将无法正确完成要求的动作。
*/

--对于DELETE操作来说，ORACLE对DUAL表的操作做了一些内部处理,尽量保证DUAL表中只返回一条记录.当然这写内部操作是不可见的
--不管表内有多少记录（没有记录除外）,ORACLE对于每次DELETE操作都只删除了一条数据。
SQL> select count(*) from dual;
COUNT(*)
----------
2
SQL> delete from dual;
1 行 已删除
SQL> commit;
提交完成
SQL> select count(*) from dual;
COUNT(*)
----------
1

/*
附: ORACLE关于DUAL表不同寻常特性的解释
There is internalized code that makes this happen. Code checks that ensurethat a table scan of SYS.DUAL only returns one row. Svrmgrl behaviour is incorrect but this is now an obsolete product.
The base issue you should always remember and keep is: DUAL table should always have 1 ROW. Dual is a normal table with one dummy column of varchar2(1).
This is basically used from several applications as a pseudo table for getting results from a select statement that use functions like sysdate or other
prebuilt or application functions. If DUAL has no rows at all some applications (that use DUAL) may fail with NO_DATA_FOUND exception. If DUAL has more than 1 row then applications (that use DUAL) may fail with TOO_MANY_ROWS exception.
So DUAL should ALWAYS have 1 and only 1 row
*/

DUAL表可以执行插入、更新、删除操作，还可以执行drop操作。但是不要去执行drop表的操作，否则会使系统不能用，数据库起不了，会报Database startup crashes with ORA-1092错误。

3、如果DUAL表被“不幸”删除后的恢复：
用sys用户登陆。
创建DUAL表。
授予公众SELECT权限（SQL如上述，但不要给UPDATE，INSERT，DELETE权限）。
向DUAL表插入一条记录（仅此一条）： insert into dual values('X');
提交修改。
--用sys用户登陆。
SQL> create pfile=’d:\pfile.bak’ from spfile
SQL> shutdown immediate
--在d:\pfile.bak文件中最后加入一条：replication_dependency_tracking = FALSE
--重新启动数据库：
SQL> startup pfile=’d:\pfile.bak’
SQL> create table “sys”.”DUAL”
( “DUMMY” varchar2(1) )
pctfree 10 pctused 4;
SQL> insert into dual values(‘X’);
SQL> commit;
SQL> Grant select on dual to Public;
授权成功。

SQL> select * from dual;
D
-
X

SQL> shutdown immediate
数据库已经关闭。
已经卸载数据库。
ORACLE 例程已经关闭。
SQL> startup
ORACLE 例程已经启动。

Total System Global Area 135338868 bytes
Fixed Size 453492 bytes
Variable Size 109051904 bytes
Database Buffers 25165824 bytes
Redo Buffers 667648 bytes
数据库装载完毕。
数据库已经打开。
SQL>

--OK， 下面就可以正常使用了。
来源： <http://www.aixchina.net/club/thread-76051-1-1.html>
 

