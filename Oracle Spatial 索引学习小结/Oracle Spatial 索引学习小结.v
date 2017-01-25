Oracle Spatial 索引学习小结

1、空间索引的创建 
1）创建索引之前总是要为空间层插入元数据
2）如果之前创建的索引失败了，必须先删除才能创建
Drop index customers_sidx;
创建索引：
Create index customers_sidx on customers(location)
Indextype is mdsys.spatial_index
在索引创建过程中，Oracle检查索引列的sdo_srid和user_sdo_geom_metadata中的srid是否匹配，如果不匹配，Oracle会产生ora-13365错误。
空间索引信息可查看user_sdo_index_metadata或者较简单的user_sdo_index_info视图。
空间索引表存储在这个SDO_INDEX_TABLE字段中，总是以MDRT开头。不能将一个空间索引表和普通的表一样对待-即不能将它从一个表空间移到另一个表空间，也不能将它删除、复制等。否则，会出现无效的空间索引并导致后续的空间查询操作符或空间索引重建失败。

2、空间索引的参数 
create INDEX <INDEX_NAME> ON <TABLE_NAME>(<COLUMNNAME>)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('PARAMETER_STRING');
1)TABLESPACE参数
通过该参数，可以指定哪个表空间来存储空间索引表。除了TABLESPACE参数外，还可以指定另外两个参数INITIAL和NEXT
create index cola_markets_spatial_geo_idx on cola_markets(LOCATION)
indextype is mdsys.spatial_index
parameters ('TABLESPACE=gmapdata next=5 INITIAL=10k');
如果表空间是本地管理的，那么INITIAL和NEXT参数就是多余的，即即使指定了他们，Oracle也会忽略它们。
注：表空间是否是本地管理的，可以通过user_tablespaces视图的segment_space_management字段是否为auto来验证。
2）work_tablespace参数
在索引创建过程中，R-tree索引会在整个的数据集上执行排序操作，因此会产生一些工作表。不过这些工作表在索引创建过程结束时会被删除。创建和删除大量不同大小的表会使表空间产生很多碎片。为避免这种情况，可以通过使用work_tablespace参数来为这些工作表指定一个单独的表空间。
create index cola_markets_spatial_geo_idx on cola_markets(LOCATION)
indextype is mdsys.spatial_index
parameters ('work_tablespace=gmapdata');
指定了工作表空间后，索引和数据就不会再索引创建过程中产生碎片。如果没有指定工作表空间，则默认工作表和索引被创建在同一个表空间。
3）layer_gtype
该参数指定了索引列的几何数据为特定类型几何体。这有助于完整性检查，有时还可加快查询操作符的执行速度。
create index cola_markets_spatial_geo_idx on cola_markets(LOCATION)
indextype is mdsys.spatial_index
parameters ('layer_gtype =point');
4）sdo_index_dims参数
该参数指定了空间索引的维数，默认为2.
create index cola_markets_spatial_geo_idx on cola_markets(LOCATION)
indextype is mdsys.spatial_index
parameters ('sdo_index_dims=3');
5）sdo_dml_batch_size参数
该参数用于指定一个事务中批量插入/删除/更新时得批量大小（对有大量插入的事务，该参数应设为5000或10000）。默认为1000.
create index cola_markets_spatial_geo_idx on cola_markets(LOCATION)
indextype is mdsys.spatial_index
parameters ('sdo_dml_batch_size=5000');
注：如果预计会对一个含有空间索引的表执行含有大量插入（或删除、更新）操作的事务，就应在create index语句或随后的alter_index rebuild语句中将sdo_dml_batch_size的值设为5000或10000.
6）sdo_level参数
指定sdo_level参数的值来创建一个四叉树索引。四叉树需要显式地进行性能调优，因此不被推荐使用。
create index cola_markets_spatial_geo_idx on cola_markets(LOCATION)
indextype is mdsys.spatial_index
parameters ('sdo_level=8');

3、空间索引视图 
user_sdo_index_metadata和user_sdo_index_info（后一个较简单）
可以从user_sdo_index_metadata视图中查看索引设置的参数。
对于一张表中n行数据的一个集合，R-tree空间索引大致需要100*3*N字节作为空间索引表的存储空间。另外，在创建索引的过程中，r-tree索引还需要额外200*3*N到300*3*N字节作为临时工作表的存储空间。
--查看表索引大小
select sdo_tune.estimate_rtree_index_size('GWM', 'COLA_MARKETS', 'SHAPE') sz FROM dual;
SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(
schemaname IN VARCHAR2,
tabname IN VARCHAR2,
colname IN VARCHAR2,
partname IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER;
or
SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(
number_of_geoms IN INTEGER,
db_block_size IN INTEGER,
sdo_rtr_pctfree IN INTEGER DEFAULT 10,
num_dimensions IN INTEGER DEFAULT 2,
is_geodetic IN INTEGER DEFAULT 0
) RETURN NUMBER;

4、基于函数的空间索引 
create or replace function gcdr_geometry(street_number varchar2,
street_name   varchar2,
city          varchar2,
state         varchar2,
postal_code   varchar2)
return mdsys.sdo_geometry deterministic is
begin
return(sdo_gcdr.geocode_as_geometry('SPATIAL',
sdo_keywordarray(street_number || ' ' ||
street_name,
city || ' ' || state || ' ' ||
postal_code),
'US'));
end;
create index cola_markets_spatial_geo_idx on cola_markets
(
gcdr_geometry(street_number,street_name,city,state,postal_code)
)
indextype is mdsys.spatial_index
parameters ('LAYER_GTYPE=POINT');
如果在一个地理编码地址到sdo_geometry对象的函数上创建空间索引，就应该在create index语句中指定参数'LAYER_GTYPE=POINT'。如果不指定该参数，查询速度会很慢。

5、本地分区空间索引 
在分区表上创建本地索引
分区表创建本地索引的条件：
只能在range_partitioned表上创建本地空间索引，而不能在list-或hash-partitioned表上创建空间索引。
本地空间索引相对于创建一个全局索引的优点：
易管理性：重建指定分区上的本地索引不会影响其他分区。
易伸缩性：为提高性能，可只在指定分区上进行查询，空间索引可在每个分区上并行创建。
create index cola_markets_spatial_geo_idx on cola_markets(LOCATION)
indextype is mdsys.spatial_index
parameters ('TABLESPACE=gmapdata')
local
（
Partition ip1 parameters ('TABLESPACE=gmapdata'),
Partition ip2,
Partition ip3
）;

6、并行索引 
语法：
create index cola_markets_spatial_geo_idx on cola_markets(LOCATION)
indextype is mdsys.spatial_index
parameters【parallel_degree】;
--创建并行索引
create index cola_markets_spatial_geo_idx on cola_markets(LOCATION)
indextype is mdsys.spatial_index
parameters parallel;
--修改为并行索引
Alter table cola_markets parallel 2;
不管创建的索引是一个本地分区索引还是一个全局索引，如果parallel degree大于2，则索引的创建就会并行执行。

7、在线重建索引 
当对一个含有空间索引的表进行大量（典型值为30%）删除操作后，对相关空间索引进行重建将使得该索引相对紧凑，从而可以更有效地服务随后的查询。
Alter index cola_markets_spatial_geo_idx rebuild;
--也可以指定参数
Alter index cola_markets_spatial_geo_idx rebuild parameters ('layer_gtype =point');
Alter index是一个DDL语句，Alter index…rebuild是个阻塞语句。因此如果在索引上有任何一个并发执行的DML（可能在不同的会话中），那么该命令将被阻塞直到它获得索引上的互斥锁。同理，在重建开始后，任何一个在表或索引上并发执行的DML语句都会被阻塞。所以为保证查询在索引重建时不被阻塞，可在Alter index…rebuild语句中指定关键词ONLINE。
Alter index cola_markets_spatial_geo_idx rebuildonline parameters ('layer_gtype =point');
来源： <http://www.cnblogs.com/yuananyun/archive/2011/10/29/2228878.html>


 

