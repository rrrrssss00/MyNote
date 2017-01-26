在ORACLE里如果遇到特别大的表，可以使用分区的表来改变其应用程序的性能。
 
同事的分区表总结，转载一下。
1.1 分区表PARTITION table
在ORACLE里如果遇到特别大的表，可以使用分区的表来改变其应用程序的性能。
1.1.1 分区表的建立： 
某公司的每年产生巨大的销售记录，DBA向公司建议每季度的数据放在一个分区内，以下示范的是该公司1999年的数据(假设每月产生30M的数据)，操作如下：
范围分区表：
CREATE TABLE sales
(invoice_no NUMBER,
...
sale_date DATE NOT NULL )
PARTITION BY RANGE (sale_date)
(PARTITION sales1999_q1
VALUES LESS THAN (TO_DATE(‘1999-04-01’,’YYYY-MM-DD’)
TABLESPACE ts_sale1999q1,
PARTITION sales1999_q2
VALUES LESS THAN (TO_DATE(‘1999-07-01’,’YYYY-MM-DD’)
TABLESPACE ts_sale1999q2,
PARTITION sales1999_q3
VALUES LESS THAN (TO_DATE(‘1999-10-01’,’YYYY-MM-DD’)
TABLESPACE ts_sale1999q3,
PARTITION sales1999_q4
VALUES LESS THAN (TO_DATE(‘2000-01-01’,’YYYY-MM-DD’)
TABLESPACE ts_sale1999q4 );
--values less than (maxvalue)
列表分区表：
create table emp (
empno number(4),
ename varchar2(30),
location varchar2(30))
partition by list (location)
(partition p1 values ('北京'),
partition p2 values ('上海','天津','重庆'),
partition p3 values ('广东','福建')
partition p0 values (default)
);
哈希分区：
create table emp (
empno number(4),
ename varchar2(30),
sal number)
partition by hash (empno)
partitions 8
store in (emp1,emp2,emp3,emp4,emp5,emp6,emp7,emp8);
组合分区：
范围哈希组合分区：
create table emp (
empno number(4),
ename varchar2(30),
hiredate date)
partition by range (hiredate)
subpartition by hash (empno)
subpartitions 2
(partition e1 values less than (to_date('20020501','YYYYMMDD')),
partition e2 values less than (to_date('20021001','YYYYMMDD')),
partition e3 values less than (maxvalue));
范围列表组合分区：
CREATE TABLE customers_part (
customer_id NUMBER(6),
cust_first_name VARCHAR2(20),
cust_last_name VARCHAR2(20),
nls_territory VARCHAR2(30),
credit_limit NUMBER(9,2))
PARTITION BY RANGE (credit_limit)
SUBPARTITION BY LIST (nls_territory)
SUBPARTITION TEMPLATE
(SUBPARTITION east VALUES ('CHINA', 'JAPAN', 'INDIA', 'THAILAND'),
SUBPARTITION west VALUES ('AMERICA', 'GERMANY', 'ITALY', 'SWITZERLAND'),
SUBPARTITION other VALUES (DEFAULT))
(PARTITION p1 VALUES LESS THAN (1000),
PARTITION p2 VALUES LESS THAN (2500),
PARTITION p3 VALUES LESS THAN (MAXVALUE));

create table t1 (id1 number,id2 number)
partition by range (id1) subpartition by list (id2)
(partition p11 values less than (11)
(subpartition subp1 values (1))
);
索引分区：
CREATE INDEX month_ix ON sales(sales_month)
GLOBAL PARTITION BY RANGE(sales_month)
(PARTITION pm1_ix VALUES LESS THAN (2)
PARTITION pm12_ix VALUES LESS THAN (MAXVALUE));
1.1.2 分区表的维护：
增加分区：
ALTER TABLE sales ADD PARTITION sales2000_q1
VALUES LESS THAN (TO_DATE(‘2000-04-01’,’YYYY-MM-DD’)
TABLESPACE ts_sale2000q1;
如果已有maxvalue分区，不能增加分区，可以采取分裂分区的办法增加分区！
删除分区：
ALTER TABLE sales DROP PARTION sales1999_q1;
截短分区:
alter table sales truncate partiton sales1999_q2;
合并分区：
alter table sales merge partitons sales1999_q2, sales1999_q3 into sales1999_q23;
alter index ind_t2 rebuild partition p123 parallel 2;
分裂分区：
ALTER TABLE sales
SPLIT PARTITON sales1999_q4
AT TO_DATE (‘1999-11-01’,’YYYY-MM-DD’)
INTO (partition sales1999_q4_p1, partition sales1999_q4_p2) ;
alter table t2 split partition p123 values (1,2) into (partition p12,partition p3);
交换分区:
alter table x exchange partition p0 with table bsvcbusrundatald ;
访问指定分区：
select * from sales partition(sales1999_q2)
EXPORT指定分区：
exp sales/sales_password tables=sales:sales1999_q1
file=sales1999_q1.dmp
IMPORT指定分区：
imp sales/sales_password FILE =sales1999_q1.dmp
TABLES = (sales:sales1999_q1) IGNORE=y
查看分区信息：
user_tab_partitions, user_segments

注：若分区表跨不同表空间，做导出、导入时目标数据库必须预建这些表空间。分表区各区所在表空间在做导入时目标数据库一定要预建这些表空间！这些表空间不一定是用户的默认表空间，只要存在即可。如果有一个不存在，就会报错！
默认时，对分区表的许多表维护操作会使全局索引不可用，标记成UNUSABLE。 那么就必须重建整个全局索引或其全部分区。如果已被分区，Oracle 允许在用于维护操作的ALTER TABLE 语句中指定UPDATE GLOBAL INDEXES 来重载这个默认特性，指定这个子句也就告诉Oracle 当它执行维护操作的DDL 语句时更新全局索引，这提供了如下好处：
1.在操作基础表的同时更新全局索引这就不需要后来单独地重建全局索引；
2.因为没有被标记成UNUSABLE， 所以全局索引的可用性更高了，甚至正在执行分区的DDL 语句时仍然可用索引来访问表中的其他分区,避免了查询所有失效的全局索引的名字以便重建它们；
另外在指定UPDATE GLOBAL INDEXES 之前还要考虑如下性能因素:
1.因为要更新事先被标记成UNUSABLE 的索引，所以分区的DDL 语句要执行更长时间，当然这要与先不更新索引而执行DDL 然后再重建索引所花的时间做个比较，一个适用的规则是如果分区的大小小于表的大小的5% ，则更新索引更快一点；
2.DROP TRUNCATE 和EXCHANGE 操作也不那么快了，同样这必须与先执行DDL 然后再重建所有全局索引所花的时间做个比较；
3.要登记对索引的更新并产生重做记录和撤消记录，重建整个索引时可选择NOLOGGING；
4.重建整个索引产生一个更有效的索引，因为这更利于使用空间，再者重建索引时允许修改存储选项。
注意分区索引结构表不支持UPDATE GLOBAL INDEXES 子句。
1.1.3 普通表变为分区表
将已存在数据的普通表转变为分区表，没有办法通过修改属性的方式直接转化为分区表，必须通过重建的方式进行转变，一般可以有三种方法，视不同场景使用：
用例：
方法一：利用原表重建分区表。
CREATE TABLE T (ID NUMBER PRIMARY KEY, TIME DATE); 
INSERT INTO T
SELECT ROWNUM, SYSDATE - ROWNUM FROM DBA_OBJECTS WHERE ROWNUM <= 5000;
COMMIT;
CREATE TABLE T_NEW (ID, TIME) PARTITION BY RANGE (TIME) 
(PARTITION P1 VALUES LESS THAN (TO_DATE('2000-1-1', 'YYYY-MM-DD')), 
PARTITION P2 VALUES LESS THAN (TO_DATE('2002-1-1', 'YYYY-MM-DD')), 
PARTITION P3 VALUES LESS THAN (TO_DATE('2005-1-1', 'YYYY-MM-DD')), 
PARTITION P4 VALUES LESS THAN (MAXVALUE))
AS SELECT ID, TIME FROM T;

RENAME T TO T_OLD;
RENAME T_NEW TO T;
SELECT COUNT(*) FROM T;
COUNT(*)
----------
5000
SELECT COUNT(*) FROM T PARTITION (P1);
COUNT(*)
----------
2946
SELECT COUNT(*) FROM T PARTITION (P2);
COUNT(*)
----------
731
SELECT COUNT(*) FROM T PARTITION (P3);
COUNT(*)
----------
1096
优点：方法简单易用，由于采用DDL语句，不会产生UNDO，且只产生少量REDO，效率相对较高，而且建表完成后数据已经在分布到各个分区中了。
不足：对于数据的一致性方面还需要额外的考虑。由于几乎没有办法通过手工锁定T表的方式保证一致性，在执行CREATE TABLE语句和RENAME T_NEW TO T语句直接的修改可能会丢失，如果要保证一致性，需要在执行完语句后对数据进行检查，而这个代价是比较大的。另外在执行两个RENAME语句之间执行的对 T的访问会失败。
适用于修改不频繁的表，在闲时进行操作，表的数据量不宜太大。

方法二：使用交换分区的方法。
Drop table t;
CREATE TABLE T (ID NUMBER PRIMARY KEY, TIME DATE); 
INSERT INTO T
SELECT ROWNUM, SYSDATE - ROWNUM FROM DBA_OBJECTS WHERE ROWNUM <= 5000;
COMMIT;
CREATE TABLE T_NEW (ID NUMBER PRIMARY KEY, TIME DATE) PARTITION BY RANGE (TIME) 
(PARTITION P1 VALUES LESS THAN (TO_DATE('2005-9-1', 'YYYY-MM-DD')), 
PARTITION P2 VALUES LESS THAN (MAXVALUE));

ALTER TABLE T_NEW EXCHANGE PARTITION P1 WITH TABLE T;
RENAME T TO T_OLD;
RENAME T_NEW TO T;

优点：只是对数据字典中分区和表的定义进行了修改，没有数据的修改或复制，效率最高。如果对数据在分区中的分布没有进一步要求的话，实现比较简单。在执行完RENAME操作后，可以检查T_OLD中是否存在数据，如果存在的话，直接将这些数据插入到T中，可以保证对T插入的操作不会丢失。
不足：仍然存在一致性问题，交换分区之后RENAME T_NEW TO T之前，查询、更新和删除会出现错误或访问不到数据。如果要求数据分布到多个分区中，则需要进行分区的SPLIT操作，会增加操作的复杂度，效率也会降低。
适用于包含大数据量的表转到分区表中的一个分区的操作。应尽量在闲时进行操作。

方法三：Oracle9i以上版本，利用在线重定义功能
Drop table t;
CREATE TABLE T (ID NUMBER PRIMARY KEY, TIME DATE); 
INSERT INTO T
SELECT ROWNUM, SYSDATE - ROWNUM FROM DBA_OBJECTS WHERE ROWNUM <= 5000;
COMMIT;

EXEC DBMS_REDEFINITION.CAN_REDEF_TABLE(USER, 'T');
PL/SQL 过程已成功完成。
CREATE TABLE T_NEW (ID NUMBER PRIMARY KEY, TIME DATE) PARTITION BY RANGE (TIME) 
(PARTITION P1 VALUES LESS THAN (TO_DATE('2004-7-1', 'YYYY-MM-DD')), 
PARTITION P2 VALUES LESS THAN (TO_DATE('2005-1-1', 'YYYY-MM-DD')), 
PARTITION P3 VALUES LESS THAN (TO_DATE('2005-7-1', 'YYYY-MM-DD')), 
PARTITION P4 VALUES LESS THAN (MAXVALUE));
表已创建。
EXEC DBMS_REDEFINITION.START_REDEF_TABLE(USER, 'T', 'T_NEW');
PL/SQL 过程已成功完成。
EXEC DBMS_REDEFINITION.FINISH_REDEF_TABLE(USER, 'T', 'T_NEW');
PL/SQL 过程已成功完成。
SELECT COUNT(*) FROM T;
COUNT(*)
----------
5000
SELECT COUNT(*) FROM T PARTITION (P3);
COUNT(*)
----------
1096
优点：保证数据的一致性，在大部分时间内，表T都可以正常进行DML操作。只在切换的瞬间锁表，具有很高的可用性。这种方法具有很强的灵活性，对各种不同的需要都能满足。而且，可以在切换前进行相应的授权并建立各种约束，可以做到切换完成后不再需要任何额外的管理操作。
不足：实现上比上面两种略显复杂。
适用于各种情况。
这里只给出了在线重定义表的一个最简单的例子，详细的描述和例子可以参考下面两篇文章。
Oracle的在线重定义表功能：http://blog.itpub.net/post/468/12855
Oracle的在线重定义表功能（二）：http://blog.itpub.net/post/468/12962

XSB:
把一个已存在数据的大表改成分区表：
第一种（表不是太大）：
1.把原表改名：
rename xsb1 to xsb2;
2.创建分区表：
CREATE TABLE xsb1
PARTITION BY LIST (c_test) 
(PARTITION xsb1_p1 VALUES (1),
PARTITION xsb1_p2 VALUES (2),
PARTITION xsb1_p0 VALUES (default))
nologging AS SELECT * FROM xsb2;
3.将原表上的触发器、主键、索引等应用到分区表上；
4.删除原表：
drop table xsb2;
第二种(表很大)：
1. 创建分区表：
CREATE TABLE x PARTITION BY LIST (c_test) [range ()]
(PARTITION p0 VALUES [less than ](1) tablespace tbs1,
PARTITION p2 VALUES (2) tablespace tbs1,
PARTITION xsb1_p0 VALUES ([maxvalue]default))
AS SELECT * FROM xsb2 [where 1=2];
2. 交换分区 alter table x exchange partition p0 with table bsvcbusrundatald ;
3. 原表改名alter table bsvcbusrundatald rename to x0;
4. 新表改名alter table x rename to bsvcbusrundatald ;
5. 删除原表drop table x0;
6. 创建新表触发器和索引create index ind_busrundata_lp on bsvcbusrundatald(。。。) local tablespace tbs_brd_ind ;

或者：
1. 规划原大表中数据分区的界限，原则上将原表中近期少量数据复制至另一表；
2. 暂停原大表中的相关触发器；
3. 删除原大表中近期数据；
4. 改名原大表名称；
5. 创建分区表；
6. 交换分区；
7. 重建相关索引及触发器（先删除之再重建）.
参考脚本：
select count(*) from t1 where recdate>sysdate-2
create table x2 nologging as select * from t1 where recdate>trunc(sysdate-2)
alter triger trg_t1 disable
delete t1 where recdate>sysdate-2
commit
rename t1 to x1
create table t1 [nologging] partition by range(recdate)
(partition pbefore values less than (trunc(sysdate-2)),
partition pmax values less than (maxvalue))
as select * from x1 where 1=2
alter table t1 exchange partition pbefore with table x1
alter table t1 exchange partition pmax with table x2
drop table x2
[重建触发器]
drop table x1
来源： <http://csevan.iteye.com/blog/284627>
 

