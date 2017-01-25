在现代的多用户多任务系统中，必然会出现多个用户同时访问共享的某个对象，这个对象可能是表，行，或者内存结构，为了解决多个用户并发性访问带来的 数据的安全性，完整性及一致性问题，必须要有一种机制，来使对这些共享资源的并发性访问串行化，oracle中的锁就可以提供这样的功能，当事务在对某个对象进行操作前，先向系统发出请求，对其加相应的锁，加锁后该事务就对该数据对象有了一定的控制权限，在该事务释放锁之前，其他的事务不能对此数据对象进行更新操作（可以做select动作，但select 利用的是undo中的前镜像数据了）.
Oracle锁的分类
Oracle锁基本上可以分为二类
a：共享锁（share locks）  也称读锁，s锁
b：排它锁 (exclusive locks) 也称写锁，x锁
在数据库中 有两种基本的锁类型：排它锁（Exclusive Locks，即X锁）和共享锁（Share Locks，即S锁）。当数据对象被加上排它锁时，其他的事务不能对它读取和修改。加了共享锁的数据对象可以被其他事务读取，但不能修改。数据库利用这两 种基本的锁类型来对数据库的事务进行并发控制。
按锁保护的内容分类
oracle提供多粒度封锁机制，按保护对象来分，据此又可以分为
a：dml锁， data locks 数据锁，用来保护数据的完整性和一致性
b：ddl锁， dictionary locks 字典锁，用来保护数据对象的结构，如table，index的定义
c：内部锁和闩 internal locks and latchs 用来保护数据库内部结构，如sga内存结构
dml锁
DML锁主要包括TM锁和TX锁，其中TM锁称为表级锁，TM锁的种类有S,X,SR,SX,SRX五种，TX锁称为事务锁或行级 锁。当Oracle执行delete,update,insert,select for update  DML语句时，oracle首先自动在所要操作的表上申请TM类型的锁。当TM锁获得后，再自动申请TX类型的锁，并将实际锁定的数据行的锁标志位(lb 即lock bytes)进行置位。在记录被某一会话锁定后，其他需要访问被锁定对象的会话会按先进先出的方式等待锁的释放，对于select操作而言，并不需要任何 锁，所以即使记录被锁定，select语句依然可以执行，实际上，在此情况下，oracle是用到undo的内容进行一致性读来实现的。
在 Oracle数据库中，当一个事务首次发起一个DML语句时就获得一个TX锁，该锁保持到事务被提交或回滚。在数据行上只有X锁（排他锁），就是说TX锁 只能是排他锁，在记录行上设置共享锁没有意义。当两个或多个会话在表的同一条记录上执行DML语句时，第一个会话在该条记录上加锁，其他的会话处于等待状 态。当第一个会话提交后，TX锁被释放，其他会话才可以加锁。
在数据表上，oracle默认是共享锁，在执行dml语句的时候，oracle会先申请对象上的共享锁，防止其他会话在这个对象上做ddl语句，成功申请表上的共享锁后，再在受影响的记录上加排它所，防止其他会话对这些做修改动作。
这样在事务加锁前检查TX锁相容性时就不用再逐行检查锁标志，而只需检查TM锁模式的相容性即可，大大提高了系统的效率。TM锁包括了SS、SX、S、X等多种模式，在数据库中用0－6来表示。不同的SQL操作产生不同类型的TM锁。如表1所示。
和锁相关的性能视图介绍
v$lock
SID          会话的sid，可以和v$session 关联   
TYPE         区分该锁保护对象的类型，如tm，tx，rt，mr等
ID1          锁表示1，详细见下说明                
ID2          锁表示2，详细见下说明           
LMODE        锁模式，见下面说明             
REQUEST      申请的锁模式，同lmode                 
CTIME        已持有或者等待锁的时间                
BLOCK        是否阻塞其他会话锁申请 1:阻塞 0:不阻塞  
LMODE取值0,1,2,3,4,5,6, 数字越大锁级别越高, 影响的操作越多。
1级锁：
Select，有时会在v$locked_object出现。
2级锁即RS锁
相应的sql有：Select for update ,Lock xxx in  Row Share mode，select for update当对
话使用for update子串打开一个游标时，所有返回集中的数据行都将处于行级(Row-X)独
占式锁定，其他对象只能查询这些数据行，不能进行update、delete或select for update
操作。
3级锁即RX锁
相应的sql有：Insert, Update, Delete, Lock xxx in Row Exclusive mode，没有commit
之前插入同样的一条记录会没有反应, 因为后一个3的锁会一直等待上一个3的锁, 我们
必须释放掉上一个才能继续工作。
4级锁即S锁
相应的sql有：Create Index, Lock xxx in Share mode
5级锁即SRX锁
相应的sql有：Lock xxx in Share Row Exclusive mode，当有主外键约束时update
/delete ... ; 可能会产生4,5的锁。
6级锁即X锁
相应的sql有：Alter table, Drop table, Drop Index, Truncate table, Lock xxx in Exclusive
mode
ID1,ID2的取值含义根据type的取值而有所不同
对于TM 锁
ID1表示被锁定表的object_id 可以和dba_objects视图关联取得具体表信息，ID2 值为0
对于TX 锁
 ID1以十进制数值表示该事务所占用的回滚段号和事务槽slot number号,其组形式:
 0xRRRRSSSS,RRRR=RBS/UNDO NUMBER,SSSS=SLOT NUMBER
ID2 以十进制数值表示环绕wrap的次数，即事务槽被重用的次数
                                             
v$locked_object
XIDUSN               undo segment number ， 可以和v$transaction关联    
XIDSLOT              undo slot number      
XIDSQN               序列号                         
OBJECT_ID            被锁定对象的object_id ，   可以和dba_objects关联
SESSION_ID           持有该锁的session_id，     可以和v$session关联
ORACLE_USERNAME   持有该锁的oracle帐号                     
OS_USER_NAME       持有该锁的操作系统帐号                      
PROCESS              操作系统的进程号，可以和v$process关联      
LOCKED_MODE        锁模式，含义同v$lock.lmode
Dba_locks 和v$lock 内容差不多,略
V$session 如果某个session被因为某些行被其他会话锁定而阻塞，则该视图中的下面四个字段列出了这些行所属对象的相关信息
ROW_WAIT_FILE# 等待的行所在的文件号
ROW_WAIT_OBJ#  等待的行所属的object_id
ROW_WAIT_BLOCK# 等待的行所属的block
ROW_WAIT_ROW#   等待的行在blcok中的位置
手工释放锁
alter system kill session 'sid,serial#';

来源： <http://blog.csdn.net/tangyangbuaa/article/details/4526146>
 

