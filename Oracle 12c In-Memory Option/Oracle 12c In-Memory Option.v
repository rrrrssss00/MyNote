  Oracle 12c In-Memory中，客户可以自主选择将一部分数据表安置在内存当中、其它表则保存
在闪存或者磁盘里，这取决于不同列表的具体查询优先级。  相比之下，SAP HANA将全部数据
都运行在内存当中，但这也意味着某些需求量较低的数据也必须接受高成本DRAM存储体系的管理。
微软公司也奋力推出了自家In-Memory功能，其SQL Server Hekaton版本目前已经处于社区技术
预览阶段。
In-Memory Option引入了一套新型双存储方案，其主要特征在于将数据同时保存在行与列之中。

Lesson 1: Enabling the In-Memory Column Store
1. In-Memory Column Store
In-Memory Column Store 是在SGA中的一个静态pool，大小不能动态更改，不能通过
自动SGA来管理。“内存内的列存储” 。

2.  各个参数理解  
show parameter  inmemory 
INMEMORY_SIZE 
In-Memory Column Store 是在SGA中的一个静态pool，不能动态更改，不能通过
自动SGA来管理。
Inmemory_clause_default  
默认为空字符串，表示只有在语法中明确指出In-Memory Column Store才生效。
如果想所有新的tables都in memory, 可以设置 INMEORY_CLAUSE_DEFAULT =“INMEMORY”.
Inmemory_force 
默认值为 DEFAULT, 表示只有明确指定INMEMORY属性的表才是In-Memory Column Store
如果设置为OFF, 即使设置inmemory属性，那么没有tables会被放入memory中。
如果设置为ON , 表示所有没有明确设置 NO INMEMORY 属性的表会强制放入memory中。
but this change will only be honored as long as this parameter is set and will not be reflected in the dictionary
Inmemory_query 
设置ENABLE, 允许在session或system级别 enabled 或 disable in-memory 查询。后面将介绍
这个参数的优点，通过对比 In-Memory Column Store 和 buffer cache 查询。

  3.  in-memory 相关的视图   
v$im_segments , v$im_user_segments 
SELECT v.owner, v.segment_name name, v.populate_status status FROM v$im_segments;
4.  如何将objects设置 In-Memory Column Store
我们熟悉的 *_TABLES 视图(比如dba_tables)增加了三个字段： 
INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, and INMEMORY_COMPRESSION 
SELECT table_name, cache, inmemory_priority,
inmemory_distribute,inmemory_compression FROM user_tables;
如果查询出来cache字段的值为Y, 那么表示他们被cache在buffer cache中了，但是还没有
被标识为 In-Memory Column Store , 我们可以用如下语句更改：
ALTER TABLE lineorder INMEMORY;

5.  INMEMORY_PRIORITY 参数
默认情况下值为NONE, 表示第一次访问这个table的时候，oracle会将这个表放入内存。当然也可以
设置优先级，设置后，数据库开启时，就会按照优先级从HIGH到LOW队列立刻populates the In-Memory 
Column Store 。
如果使用alter命令修改这个参数为非默认值，那么DDL操作直到 population 完成才会返回结束。
Alternatively, the priority level can be set, which queues the population of the table 
into the In-Memory Column Store immediately. The queue is drained from HIGH to LOW 
priority. This is also referred to as “at startup” as Oracle populates the In-Memory 
Column Store using this priority queue each time the database starts. If the priority 
is set to a non-default value during an alter command then the DDL won’t return until 
the population has completed. 
  6. RAC数据库中的in-memory设置
在RAC环境，每个数据库节点有它自己的 In-Memory Column Store, 同样的object可以存在于每个
column stores中， 这被称为"DUPLICATE", 如果一个objects太大而不合适放在一个节点的In-Memory 
Column Store中，那么有可能object的各部分分布在每个RAC节点中，这被称为"DISTRIBUTE", 每个
object应该如何populate在column store中， 这个是在*_TABLES 视图中的 INMEMORY_DISTRIBUTE字段
标识的。默认值为 AUTO-DISTRIBUTE, 这个值表示在RAC环境Oracle自动决定objects应该如何分布在
In-Memory Column Store, 在单节点的实例数据库中，这个属性没有意义。

7. 压缩 
每个被放入In-Memory Column Store的object都会被压缩，oracle提供多种压缩方法，这些方法提供了
不同程度的压缩及性能 。默认情况下，数据库使用 FOR QUERY option压缩， 这种方式在压缩和性能
之间提供了最好的平衡。 *_TABLES 视图中的 INMEMORY_COMPRESSION 字段显示了压缩选项值。
SELECT table_name, cache, inmemory_priority,
inmemory_distribute,inmemory_compression FROM user_tables;
TABLE_NAME     CACHE     INMEMORY_COMPRESSION  
-------------   -------   ------------------  
CUSTOMER         Y        FOR QUERY 
虽然每个table都可以有 in-memory 属性的设置，但是它们不会驻留在
In-Memory Column Store中，记住，默认情况下，只有object被访问时，
才会放到In-Memory Column Store中。 (by default the In-Memory Column 
Store is only populated when the object is accessed.)
 
8. 查看population过程  
在LINUX下你可以通过top命令查看ora_w***_orcl进程来确认population过程是否
完成。如果后台进程 ora_w***_orcl 不在process之列了，那么表示population
过程结束。 
你也可以通过 v$im_segments 视图来观察population的进度。
SELECT v.owner, v.segment_name name,
v.populate_status status, v.bytes_not_populated FROM v$im_segments v;
BYTES_NOT_POPULATED 列显示0值，表示整个table已经被完成populate到column 
store中了。
  9. 压缩后的SIZE 
In-Memory Column Store中的压缩后的object的实际大小是多少 ？
SELECT   v.owner, v.segment_name, 
v.bytes      orig_size, 
v.inmemory_size    in_mem_size, 
v.bytes / v.inmemory_size   comp_ratio 
FROM    v$im_segments v;
NAME         ORIG_SIZE     IN_MEM_SIZE     COMP_RATIO  
-------      ---------  --------------   --------------
CUSTOMER      134217728      99811328       1.34471438  
DATE_DIM       67108864       1179648      56.8888889 
...
In-Memory Column Store中的压缩算法不是为了像磁盘压缩一样节省空间，而是提供
好的性能。 压缩比依赖于每行内部的数据分布。

10.  INMEMORY_SIZE
population speed 决定于系统CPU处理能力，因为数据压缩是CPU的主要任务，CPU越多越强大，
population 就会运行得越快 。 50G大小的数据可以在数分钟内populate到 In-Memory Coulmn store。

  Lesson 2: In-Memory Column Store Tables 
11. 对比In-Memory Column Store与buffer cache 
set timing ON
 
 -- 全表扫描一个3亿笔记录的大表。
SELECT Max(lo_ordtotalprice) most_expensive_order FROM lineorder;
 -- 在buffer cache中访问  
ALTER SESSION set inmemory_query = disable;
SELECT /* BUFFER CACHE */
Max(lo_ordtotalprice) most_expensive_order FROM lineorder;
 -- 不要忘记改回enable .
ALTER SESSION set inmemory_query = enable;
虽然两者都是内存扫描，但是可以得到结论，在In-Memory Column Store中查询比
在传统的 buffer cache中要快。
In-Memory Column Store仅仅需要扫描单一一个列lo_ordtotalprice，而row store
(行存储)不得不扫描每一行中的所有columns, 直到reaches lo_ordtotalprice列。 
我们也从出色的压缩比中受益，对于SIMD vector processing, 柱状格式不需要额外
的操作。
一般我们都是通过执行计划来查看SQL如何执行的。如果查询In-Memory Column Store Table，
那么执行计划中会显示 TABLE ACCESS IN MEMORY FULL 字样。 不过有很少的情况下，即使
object被标识为 IN MEMORY, 但是我们不能使用  In-Memory Column Store 。 这些就好比
在Exadata环境如何使用STORAGE 。
  12. 确认In-Memory Column Store是否被使用
为了确认In-Memory Column Store被使用，我们需要通过v$mystat和v$statname检查session 
level statistics。所有In-Memory Column Store相关的statistics都是以IMC开头的。
column format display_name a30
SELECT display_name FROM v$statname WHERE display_name LIKE 'IMC%';
查询会有很多值，我们目前只关系如下两个：
IMC Total Columns for Decompression: Total number of Compression Units (CU) that belong to the table
IMC Columns Decompressed:   Compression Units (CUs) actually accessed by this query

SELECT display_name, value  
FROM v$mystat m, v$statname n 
WHERE m.statistic# = n.statistic#
AND display_name IN 
 ( 'IMC Total Columns for Decompression', 'IMC Columns Decompressed' );
你应该看到这两个statistics值都是0，我们从第一步开始再次执行表查询 :
SELECT Max(lo_ordtotalprice) most_expensive_order FROM lineorder; 
通过如下SQL再次检查 statistics :  
SELECT display_name, value FROM v$mystat m, v$statname n WHERE m.statistic# = n.statistic#
AND display_name IN ( 'IMC Total Columns for Decompression', 'IMC Columns Decompressed' );
结果显示， LINEORDER 表在In-Memory Column Store中占用了很多的CUs – ‘IMC Total Columns for Decompression’, 但是他们中
只有少部分在查询中被访问到 -  'IMC Columns Decompressed'.

现在同样的步骤测试在buffer cache中查询： 
SELECT Max(lo_ordtotalprice) most_expensive_order FROM lineorder;
SELECT display_name, value FROM v$mystat m, v$statname n WHERE m.statistic# = n.statistic#
AND display_name IN ( 'IMC Total Columns for Decompression', 'IMC Columns Decompressed' );
ALTER SESSION set inmemory_query = disable;
SELECT /* BUFFER CACHE */ Max(lo_ordtotalprice) most_expensive_order FROM lineorder;
ALTER SESSION set inmemory_query = enable;
SELECT display_name, value FROM v$mystat m, v$statname n WHERE m.statistic# = n.statistic#
AND display_name IN ( 'IMC Total Columns for Decompression', 'IMC Columns Decompressed' );

这次可以注意到，IMC statistics没有增加，因为query不使用In-Memory Column Store,而是使用的buffer
cache 。
13. storage index
习惯上，在一个表上查询时全表扫描是最没有效率的执行计划，但是存储在In-Memory Column Store
中的 tables 打破了这个老套的说法。
-- In-Memory Column Store 类型查询： 
SET TIMING ON 
SELECT lo_orderkey, lo_custkey, lo_revenue 
FROM lineorder 
WHERE lo_orderkey = 5000000;
-- 在buffer cache中的查询： 
ALTER SESSION set inmemory_query = disable;
SELECT /* BUFFER CACHE */ 
lo_orderkey, lo_custkey, lo_revenue 
FROM lineorder WHERE lo_orderkey = 5000000;
ALTER SESSION set inmemory_query = enable;
可以发现，In-Memory Column Store查询明显比buffer cache查询快。
In-Memory Column Store在每个column上访问storage index, storage index将column
值做 min/max pruning ，where子句谓词对比相应列在每个 in-memory segment 中的
min/max 范围，如果这个值没有落在指定的范围，那么这个in-memory segment直接跳过，
不用再扫描 。
你能通过查看三个IMC session statistics看出来min/max pruning的发生。
SELECT display_name, value 
FROM v$mystat m, v$statname n 
WHERE m.statistic# = n.statistic#  AND  display_name IN 
( 'IMC Preds all rows pass minmax', 
  'IMC Preds some rows pass minmax', 
  'IMC Preds no rows pass minmax' );
然后再次执行我们的查询 :
SELECT lo_orderkey, lo_custkey, lo_revenue FROM lineorder WHERE lo_orderkey = 5000000;
再次检查session statistics : 
SELECT display_name, value 
FROM v$mystat m, v$statname n 
WHERE m.statistic# = n.statistic#  AND  display_name IN 
( 'IMC Preds all rows pass minmax', 
  'IMC Preds some rows pass minmax', 
  'IMC Preds no rows pass minmax' );
从得出的结果可以看出min/max pruning的高效，statistics显示大量的segments被跳过，因为
没有行在这些segment 的min/max范围 (no rows pass minmax)，这意味着不会扫描这些segments, 
我们的值仅仅落在少量segments上(some rows pass minmax)。
这时你可能会想，如果在where后的列上加一个简单的索引，将可能会带来和In-Memory column store
访问一样的效率。我们可以通过设置 OPTIMIZER_USE_INVISIBLE_INDEXES 参数(默认值为FALSE)来对比
In-Memory Column Store和使用index的性能 。例子：
create index lo_orderkey_idx on  lineorder(lo_orderkey)  invisible;  
SET TIMING ON 
SELECT lo_orderkey, lo_custkey, lo_revenue FROM lineorder WHERE lo_orderkey = 5000000;
ALTER SESSION set inmemory_query = disable;
ALTER SESSION SETOPTIMIZER_USE_INVISIBLE_INDEXES=TRUE;
--- 在buffer cache中使用index 
SELECT lo_orderkey, lo_custkey, lo_revenue FROM lineorder WHERE lo_orderkey = 5000000;
ALTER SESSION set inmemory_query = enable;
  14 .  multiple storage indexes
查询语句where条件中一般不止一个，当有多个"="条件的时候会发生什么情况，传统的做法
可能会创建一个联合索引(multi-column index)。
SELECT display_name, value 
FROM v$mystat m, v$statname n 
WHERE m.statistic# = n.statistic#  AND  display_name IN 
( 'IMC Preds all rows pass minmax', 
  'IMC Preds some rows pass minmax', 
  'IMC Preds no rows pass minmax' );
SELECT lo_orderkey, lo_custkey, lo_revenue 
FROM lineorder 
WHERE lo_custkey = 5641 
      AND lo_shipmode = 'REG AIR' 
      AND lo_orderpriority = '5-LOW';
SELECT display_name, value 
FROM v$mystat m, v$statname n 
WHERE m.statistic# = n.statistic#  AND  display_name IN 
( 'IMC Preds all rows pass minmax', 
  'IMC Preds some rows pass minmax', 
  'IMC Preds no rows pass minmax' );
可以看出In-Memory storage index还是会被使用，事实上，我们能多个storage indexes
一起使用。
  15.  非"="条件下会发生什么？
前面讲到的where条件中都是=条件，如果是一个范围，比如lo_custkey > 5641,是否可以从
min/max purning中获益呢 ？ 
set timing on 
SELECT display_name, value 
FROM v$mystat m, v$statname n 
WHERE m.statistic# = n.statistic#  AND  display_name IN 
( 'IMC Preds all rows pass minmax', 
  'IMC Preds some rows pass minmax', 
  'IMC Preds no rows pass minmax' );
SELECT Max(lo_supplycost) most_expensive_bluk_order 
FROM lineorder 
WHERE lo_quantity > 42;
SELECT display_name, value 
FROM v$mystat m, v$statname n 
WHERE m.statistic# = n.statistic#  AND  display_name IN 
( 'IMC Preds all rows pass minmax', 
  'IMC Preds some rows pass minmax', 
  'IMC Preds no rows pass minmax' );
取消In-Memory Column Store后，查询buffer cache得到查询结果。
ALTER SESSION set inmemory_query = disable;
SELECT /* BUFFER CACHE */
Max(lo_supplycost) most_expensive_bluk_order 
FROM lineorder 
WHERE lo_quantity > 42;
ALTER SESSION set inmemory_query = enable;
In-Memory Column Store仍然比buffer cache查询要来的高效，因为它仅仅只需扫描一个列lo_quantity,
尽管where 语句中不是“=”条件，我们还是能使用 In-Memory storage index。
16. 复杂条件(混合：子查询，LIKE,>,=,BETWEEN..AND..)
即使非常复杂的条件，In-Memory Column Store查询仍然运行较快，测试发现，对于large scan
操作，它是最高效的方式。
 
17. 总结
虽然都是在内存中操作，但是In-Memory Column Store中的查询还是比在buffer cache中
操作来的高效。这些性能提升可能是因为我们只需要扫描我们需要的字段，并充分利用
SIMD vector processing的优势，而不需要像buffer cache中查询，需要扫描整个行数据。
当然，我们还从new in-memory storage indexes中获取到一些帮助，它允许我们不扫描
我们不需要的数据，要知道，In-Memory Column Store中，每个column都有storage index，
且都是自动维护的。
SIMD vector processing ？？ 
我们还可以通过几个视图v$mystat m, v$statname查询监控in-memory workload。
   'IMC Total Columns for Decompression' 
   'IMC Columns Decompressed'
   'IMC Preds all rows pass minmax'
   'IMC Preds some rows pass minmax' 
   'IMC Preds no rows pass minmax'
 
Lesson 3: In-Memory Joins and Aggregation 

18. 多个表的join 
...待续   

来源： <http://blog.itpub.net/35489/viewspace-1081474/>
  

