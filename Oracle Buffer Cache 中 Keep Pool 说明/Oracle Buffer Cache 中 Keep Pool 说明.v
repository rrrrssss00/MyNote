注：附件里还有一个文档，介绍得稍微简单一些

一. Keep Pool 说明
在我之前的Blog里对DB buffer 进行了一个说明，参考：
            Oracle Buffer Cache 原理
            http://blog.csdn.net/tianlesoftware/article/details/6573438
 
            Oracle的buffer cache 由三个部分组成： default pool，keep pool 和Recycle pool.  每个Pool 都有自己的LRU来管理.
            （1）The default pool is for everything else.
            （2）The recycle pool is for larger objects.
            （3）The keep pool's purpose is to take small objects that shouldalways be cached, for example Look Up Tables.
 
在这篇文章里我们重点看一下KeepPool的说明。
 
1.1 相关理论知识
1.1.1 BUFFER_POOL
            The BUFFER_POOL clause letsyou specify a default buffer pool (cache) for aschema object. All blocks for the object are stored in the specified cache.
            -- 缓冲池子句可指定一个数据库对象的默认缓冲池。这个对象的所有数据块存储在指定的缓存中。

            If you define a buffer poolfor a partitioned table or index, then the partitions inherit the buffer poolfrom the table or index definition, unless overridden by a partition-leveldefinition. 
            --如果给一个分区表或索引指定了缓冲池，那么该表或索引的分区也同样使用指定的缓冲池，除非在分区的定义中指定分区使用的缓冲池。

            For an index-organized table,you can specify a buffer pool separately for the index segment and the overflowsegment. 
            --对于一个索引组织表，可以为索引段和溢出段分别指定缓冲池。

（1）Restrictionson BUFFER_POOL 
            You cannot specify this clausefor a cluster table. However, you can specify it for a cluster. 
            --不能在聚集表上指定缓冲池，但是，可以在一个聚集上指定缓冲池。

            You cannot specify this clausefor a tablespace or for a rollback segment. 
            --不能在表空间或回滚段上指定缓冲池。

（2）KEEP
            Specify KEEP to put blocksfrom the segment into the KEEP buffer pool. Maintaining an appropriately sizedKEEP buffer pool lets Oracle retain the schema object in memory to avoid I/Ooperations. KEEP takes precedence over any NOCACHEclause you specify for a table, cluster, materialized view, ormaterialized view log.
            --指定KEEP将把数据块放入KEEP缓冲池中。维护一个适当尺寸的KEEP缓冲池可以使Oracle在内存中保留数据库对象而避免I/O操作。在表、聚集、实体化视图或实体化视图日志上，KEEP子句的优先权大于NOCACHE子句。

（3）RECYCLE
            Specify RECYCLE to put blocksfrom the segment into the RECYCLE pool. An appropriately sized RECYCLE poolreduces the number of objects whose default pool is the RECYCLE pool fromtaking up unnecessary cache space.
            --指定RECYCLE将把数据块放入RECYCLE缓冲池中。一个适当尺寸的RECYCLE缓冲池可以减少默认缓冲池为RECYCLE缓冲池的数据库对象的数量，以避免它们占用不必要的缓冲空间。

（4） DEFAULT
            Specify DEFAULT to indicatethe default buffer pool. This is the default for objects not assigned to KEEPor RECYCLE.
            --指定DEFAULT将适用默认的缓冲池。这个选项适用于没有分配给KEEP缓冲池和RECYCLE缓冲池的其它数据库对象。

（5）buffer pool 说明
            在没有多个缓冲池的数据库中，所有的数据库对象使用同样的缓冲池，这样就会形成一种情况:
            当希望某个频繁使用的数据库对象一直保留在缓冲池中时，一个大的、不经常使用的数据库对象会把它“挤”出缓冲池。这样就会降低缓冲池的效率，增加额外的I/O操作。
            使用多个缓冲池后，可以更精确的调整缓冲池的使用，频繁使用数据库对象的缓冲池放在KEEP缓冲池中，大的、不经常使用的数据库对象放在RECYCLE缓冲池中，其它的数据库对象放在DEFAULT缓冲池中。
 
1.1.2 CACHE | NOCACHE | CACHE READS
            Use the CACHE clauses toindicate how Oracle should store blocks in the buffer cache. If you specifyneither CACHE nor NOCACHE:
            --使用CACHE子句可制定Oracle在缓冲中如何存贮数据块。如果没有指定CACHE或NOCACHE：
 
In a CREATE TABLE statement, NOCACHE is thedefault 
In an ALTER TABLE statement, the existing value is not changed. 
            --在CREATETABLE语句中，默认为NOCACHE。
            --在ALTER TABLE语句中，不会改变当前表的CACHE/NOCACHE值。

（1）CACHE Clause
            For data that is accessedfrequently, this clause indicates that the blocks retrieved for this table are placedat the most recently used end of the least recentlyused (LRU) list in the buffer cache when a full table scan is performed.This attribute is useful for small lookup tables.
            --对于那些访问频繁的数据，这个子句可以指定当执行一个全表扫描时，将从表中获取的数据块放在缓冲中LRU列表的"最新使用"的一端。这个属性对小的查找表有用。

            As a parameter in theLOB_storage_clause, CACHE specifies that Oracle places LOB data values in thebuffer cache for faster access.
            --作为LOB存储子句的一个参数，CACHE可指定Oracle将LOB数据放在缓冲中，以便访问得更快。

（2）Restriction on CACHE
            You cannot specify CACHE foran index-organized table. However, index-organized tables implicitly provideCACHE behavior.
            --不能在索引组织表上使用CACHE。但是，索引组织表隐式的提供了CACHE的效果。

（3）NOCACHE Clause
            For data that is not accessedfrequently, this clause indicates that the blocks retrieved for this table areplaced at the least recently used end of the LRU listin the buffer cache when a full table scan is performed.
            --对于那些访问不频繁的数据，这个子句可以指定当执行一个全表扫描时，将从表中获取的数据块放在缓冲中LRU列表的“最久使用”的一端。

            As a parameter in theLOB_storage_clause, NOCACHE specifies that the LOB value is either not broughtinto the buffer cache or brought into the buffer cache and placed at the leastrecently used end of the LRU list. (The latter is the default behavior.)
            --作为LOB存储子句的一个参数，NOCACHE可指定Oracle将LOB数据不放在缓冲中或者放在缓冲中LRU列表的“最久使用”的一端。（后者是默认的做法。）

（4）Restriction on NOCACHE
            You cannot specify NOCACHE forindex-organized tables.
            --不能在索引组织表上使用CACHE。

（5）CACHE READS
            CACHE READS applies only toLOB storage. It specifies that LOB values are brought into the buffer cacheonly during read operations, but not during write operations.
            --CACHEREADS只适用于LOB存储。它指定当进行读操作时，将LOB放在缓冲中，而写操作时不这样做。

（6）说明
            当BUFFER_POOL和CACHE同时使用时，KEEP比NOCACHE有优先权。
BUFFER_POOL用来指定存贮的缓冲池，而CACHE/NOCACHE指定存储的方式。
 
1.2 官网说明
            Ifthere are certain segments in your application that are referenced frequently,then store the blocks from those segments in a separate cache called the KEEPbuffer pool. Memory is allocated to the KEEP buffer pool by setting theparameter DB_KEEP_CACHE_SIZE to the required size. Thememory for the KEEP pool is not a subset of the default pool. Typical segmentsthat can be kept are small reference tables that are used frequently.Application developers and DBAs can determine which tables are candidates.
            Youcan check the number of blocks from candidate tables by querying V$BH, asdescribed in "DeterminingWhich Segments Have Many Buffers in the Pool".
 
Note:
            The NOCACHE clause has no effect on a table inthe KEEP cache.
            --对象放到Keep Pool中，必需将这个对象缓存，因此Oracle对所有KEEP池中的对象采用了默认CACHE的方式。而忽略对象本身的CACHE和NOCACHE选项。
 
            Thegoal of the KEEP buffer pool is toretain objects in memory, thus avoiding I/O operations. The size of the KEEPbuffer pool, therefore, depends on the objects to be kept in the buffer cache.You can compute an approximate size for the KEEP buffer pool by adding theblocks used by all objects assigned to this pool. Ifyou gather statistics on the segments, you can query DBA_TABLES.BLOCKS and DBA_TABLES.EMPTY_BLOCKSto determine the number of blocks used.
            Calculatethe hit ratio by taking two snapshots of system performance at different times,using the previous query. Subtract the more recent values for physical reads, blockgets, and consistent gets from the older values, and use the results to computethe hit ratio.
            Abuffer pool hit ratio of 100% might not be optimal. Often, you can decrease thesize of your KEEP buffer pool and still maintain a sufficiently high hit ratio.Allocate blocks removed from the KEEP buffer pool to other buffer pools.
 
Note:
            Ifan object grows in size, then it might no longer fit in the KEEP buffer pool.You will begin to lose blocks out of the cache.
            Each object kept in memory results in a trade-off. It is beneficial to keep frequently-accessed blocks in thecache, but retaining infrequently-used blocks results in less space forother, more active blocks.
 
From: http://download.oracle.com/docs/cd/E11882_01/server.112/e16638/memory.htm#PFGRF94285

1.3 Keep Buffer Pool 说明
            KeepBuffer Pool 的作用是缓存那些需要经常查询的对象但又容易被默认缓冲区置换出去的对象，按惯例，Keep pool设置为合理的大小，以使其中存储的对象不再age out，也就是查询这个对象的操作不会引起磁盘IO操作，可以极大地提高查询性能。
           
            注意一点，不是设置了keep pool 之后，热点表就一定能够缓存在 keep pool ，keep pool 同样也是由LRU 链表管理的，当keep pool 不够的时候，最先缓存到 keep pool 的对象会被挤出，不过与default pool 中的 LRU 的管理方式不同，在keep pool 中表永远是从MRU 移动到LRU，不会由于你做了FTS（全表扫描）而将表缓存到LRU端，在keep pool中对象永远是先进先出。
 
            因为这个原因，如果keep pool 空间比table 小，导致不能完全把table keep下，那么在keep pool 中最早使用的数据还是有可能被清洗出去的。还是会产生大量的逻辑读，这样就起不到作用，所以，如果采用keep，就必须全部keep下，要么就不用 keep。

            关于altertable cache, 全表扫描数据在正常情况下是放到LRU的冷端,使其尽快page out(这是default pool的默认策略), 而指定了alter table cache后,该表的全表扫描数据就不是放到LRU的冷端, 而是放到热端（MRU）了,从而使该得数据老化较慢,即保留的时间长. 
            但对于keep pool来说, 默认策略并不相同,所有数据总是放到热端的, 包括全表扫描数据。
 
            在Oracle 10g中SGA自动管理，ORACLE并不会管理keep pool，ORACLE只会管理default pool。
 
            默认的情况下db_keep_cache_size=0，未启用，如果想要启用，需要手工设置db_keep_cache_size的值，设置了这个值之后 db_cache_size 会减少。
 
说明：
            对以上理论这块也是拿捏的不是很准确，在官网没有找到这块的详细说明，也是网上搜的资料。暂且先这么理解。以后如果有其他的理解，在更新了。
 
 
二.  KeepPool 相关测试
2.1 keep基本测试
-- 查看SGA 信息
SYS@anqing2(rac2)> select * fromv$sgainfo;
NAME                                     BYTES RES
--------------------------------------------- ---
Fixed SGA Size                         1267068 No
Redo Buffers                           2924544 No
Buffer Cache Size                    150994944 Yes
Shared Pool Size                     113246208 Yes
Large Pool Size                        4194304 Yes
Java Pool Size                         4194304 Yes
Streams Pool Size                      8388608 Yes
Granule Size                           4194304 No
Maximum SGA Size                     285212672 No
Startup overhead in Shared Pool       46137344 No
Free SGA Memory Available                    0
 
11 rows selected.
--查看 keeppool 大小
SYS@anqing2(rac2)> show parameterdb_keep_cache_size
 
NAME                    TYPE       VALUE
----------------------------------------------- ------------------------------
db_keep_cache_size          big integer  0
 
--查看db_cache_size大小
SYS@anqing2(rac2)> SELECT x.ksppinm NAME,y.ksppstvl VALUE, x.ksppdesc describ FROM SYS.x$ksppi x, SYS.x$ksppcv y WHEREx.indx = y.indx AND x.ksppinm LIKE '%__db_cache_size%';
 
NAME            VALUE           DESCRIB
--------------- --------------- ------------------------------------------------
__db_cache_size 150994944   Actual size of DEFAULT buffer pool forstandard
 
--手动指定keeppool
SYS@anqing2(rac2)> alter system set db_keep_cache_size=50Mscope=both sid='anqing2';
System altered.
 
-- 查看db_keep_cache_size和 db_cache_size 大小
 
SYS@anqing2(rac2)> show parameterdb_keep_cache_size
 
NAME                                 TYPE        VALUE
----------------------------------------------- ------------------------------
db_keep_cache_size                   big integer 52M
 
SYS@anqing2(rac2)> SELECT x.ksppinmNAME, y.ksppstvl VALUE, x.ksppdesc describ FROM SYS.x$ksppi x, SYS.x$ksppcv yWHERE x.indx = y.indx AND x.ksppinm LIKE '%__db_cache_size%';
 
NAME                 VALUE           DESCRIB
-------------------------------------------------- ----------------------------
__db_cache_size        96468992        Actual size of DEFAULT buffe
-- 这个验证增加db_keep_cache_size时，db_cache_size 就会减小。
 
--表keep 到keepbuffer
SYS@anqing2(rac2)> create table t1 asselect * from dba_objects;
Table created.
SYS@anqing2(rac2)> alter table t1storage(buffer_pool keep);
Table altered.
--或者
SYS@anqing2(rac2)> create table t1storage(buffer_pool keep) as select * from dba_objects;
Table created.
 
--查看放入Keep的对象
SYS@anqing2(rac2)>  select segment_name from dba_segments whereBUFFER_POOL = 'KEEP';
SEGMENT_NAME
----------------------------------------
T1
 
--查看表的大小
SYS@anqing2(rac2)> selectbytes/1024/1024||'M' from dba_segments where segment_name='T1';
 
BYTES/1024/1024||'M'
-----------------------------------------
6M
 
--select 全表，把数据加载到keep pool
SYS@anqing2(rac2)> set autot traceonlystat
SYS@anqing2(rac2)> select * from t1;
50261 rows selected.
 
Statistics
----------------------------------------------------------
         0  recursive calls
         0  db block gets
       705  consistent gets
       691  physical reads
          0 redo size
   2116604  bytes sent via SQL*Net toclient
       510  bytes received via SQL*Netfrom client
        12  SQL*Net roundtrips to/fromclient
         0  sorts (memory)
         0  sorts (disk)
     50261  rows processed
 
SYS@anqing2(rac2)> /
50261 rows selected.
Statistics
----------------------------------------------------------
         0  recursive calls
         0  db block gets
       705  consistent gets
         0  physical reads
         0  redo size
    2116604 bytes sent via SQL*Net to client
       510  bytes received via SQL*Netfrom client
        12  SQL*Net roundtrips to/fromclient
         0  sorts (memory)
         0  sorts (disk)
     50261  rows processed
--第二次查询没有了物理读，数据已经刷到了keep pool 里。
 
 
--查看db_keep_cache_size实际占用空间
/* Formatted on 2011/7/2 17:15:15(QP5 v5.163.1008.3004) */
SELECT SUBSTR (SUM (b.NUMBER_OF_BLOCKS) * 8129 / 1024 / 1024, 1, 5) || 'M'Total_Size
 FROM (  SELECT o.OBJECT_NAME, COUNT (*)NUMBER_OF_BLOCKS
            FROMDBA_OBJECTS o, V$BHbh,dba_segments dd
           WHERE     o.DATA_OBJECT_ID= bh.OBJD
                 AND o.OWNER = dd.owner
                 AND dd.segment_name= o.OBJECT_NAME
                 AND dd.buffer_pool != 'DEFAULT'
        GROUP BY o.OBJECT_NAME
        ORDER BY COUNT (*)) b;
 
TOTAL_SIZE
-----------
9.566M
 
-- 取消keep
            默认情况下数据是放到default pool的，所以，我们取消keep，只需要重新指定存储位置到default即可。
 
SYS@anqing2(rac2)> alter table t1 storage(buffer_pool default);
Table altered.
 
--查看keep
SYS@anqing2(rac2)> select segment_namefrom dba_segments where BUFFER_POOL = 'KEEP';
no rows selected
 
 
2.2  Cache 相关测试
            对于DefaultPool，默认情况下是nocache，这是后，如果采用的是全表扫描，因为这部分数据用的次数比较少，所以该数据是放在LRU段，即 会尽快的被ageout出buffer。 如果启用了cache，那么当全表扫描时，数据会放到MRU端，这样保存的时间就会长，即老化的慢。
           
            但是对于KeepPool，它的策略不一样，不管是否用全表扫描，数据都会放在MRU端，当keep Pool 空间不足时，会从LRU端age out。 并且如果采用Keep Pool，Data 都会cache到内存中，所以会忽略对象本身的Cache 和Nocache。
 
Keep Pool 和 Cache 的区别：
            KeepPool 改变的是存储位置，Cache改变的是存储方式。
--keep pool
SYS@anqing2(rac2)> alter table t1 storage(buffer_pool keep);
Table altered.
 
--启用cache
SYS@anqing2(rac2)> alter table t1 cache;
Table altered.
 
--查询
SYS@anqing2(rac2)> select table_name,cache,buffer_pool from dba_tables wheretable_name='T1';
TABLE_NAME        CACHE     BUFFER_
------------------------------ -----------------
T1                   Y      KEEP
 
--取消cache
SYS@anqing2(rac2)> alter table t1nocache;
Table altered.
 
--查看
SYS@anqing2(rac2)> selecttable_name,cache,buffer_pool from dba_tables where table_name='T1';
 
TABLE_NAME        CACHE     BUFFER_
------------------------------ -----------------
T1                   N     KEEP
 
 
2.3 flush buffer_cache会清空keep pool
 
SYS@anqing2(rac2)> select count(*) fromt1;
 
Elapsed: 00:00:00.01
 
Statistics
----------------------------------------------------------
       124  recursive calls
         0  db block gets
       705  consistent gets
         0  physical reads
         0  redo size
       413  bytes sent via SQL*Net toclient
       400  bytes received via SQL*Netfrom client
         2  SQL*Net roundtrips to/fromclient
          3 sorts (memory)
         0  sorts (disk)
         1  rows processed
 
SYS@anqing2(rac2)> alter system flush buffer_cache;
System altered.
 
Elapsed: 00:00:00.13
SYS@anqing2(rac2)> select count(*) fromt1;
 
Elapsed: 00:00:01.29
 
Statistics
----------------------------------------------------------
         0  recursive calls
         0  db block gets
       695  consistent gets
        691  physical reads
         0  redo size
       413  bytes sent via SQL*Net toclient
       400  bytes received via SQL*Netfrom client
         2  SQL*Net roundtrips to/fromclient
         0  sorts (memory)
         0  sorts (disk)
         1  rows processed
 
            从这个结果看，当flushbuffer_cache之后，产生了physical reads。并且查询的时间也增加了。
 
2.4 Keep Pool 与 非Keeppool 速度对比
            keepPool 即全部从内存里读数据，非keeppool 可以理解成从磁盘读。 通过这2者的比较，也可以体现出使用keep pool的价值。
 
SYS@anqing2(rac2)> select count(*) from rb_test;
 
 COUNT(*)
----------
  4000000
 
SYS@anqing2(rac2)> select bytes/1024/1204||'M' from dba_segments wheresegment_name='RB_TEST';
 
BYTES/1024/1204||'M'
-----------------------------------------
74.8438538205980066445182724252491694352M
 
 
-- 表有74M，我们设置keepPool 为100M，然后keep。
SYS@anqing2(rac2)> alter system set db_keep_cache_size=100M scope=bothsid='anqing2';
System altered.
 
--keep table
SYS@anqing2(rac2)> alter table rb_test storage(buffer_pool keep);
Table altered.
 
--查看物理读时间
SYS@anqing2(rac2)> alter system flush buffer_cache;
System altered.
Elapsed: 00:00:00.03
SYS@anqing2(rac2)> select * from rb_test where rownum<2000000;
1999999 rows selected.
Elapsed: 00:00:17.65 --18秒
 
Statistics
----------------------------------------------------------
         1  recursive calls
         0  db block gets
       5914 consistent gets
       5520  physical reads  --有大量的逻辑读
         0  redo size
  20010892  bytes sent via SQL*Netto client
      4789  bytes received via SQL*Netfrom client
       401 SQL*Net roundtrips to/from client
         0  sorts (memory)
          0 sorts (disk)
   1999999  rows processed
 
--查看keep 时间
SYS@anqing2(rac2)> select * from rb_testwhere rownum<2000000;
1999999 rows selected.
 
Elapsed: 00:00:03.09  -- 3秒
 
Statistics
----------------------------------------------------------
         0  recursive calls
         0  db block gets
      5914  consistent gets
         0  physical reads  --物理读为0
         0  redo size
  20010892  bytes sent via SQL*Netto client
      4789  bytes received via SQL*Netfrom client
       401 SQL*Net roundtrips to/from client
         0  sorts (memory)
         0  sorts (disk)
   1999999  rows processed
 
            注意这里的SQL*Net roundtripsto/from client。因为我已经将arraysize 参数修改成5000了。 如果没有修改，那么默认arraysize 只有15. 那么会产生大量的roundtrips。
 
SYS@anqing2(rac2)> show arraysize
arraysize 5000

来源： <http://blog.csdn.net/tianlesoftware/article/details/6581159>
 
