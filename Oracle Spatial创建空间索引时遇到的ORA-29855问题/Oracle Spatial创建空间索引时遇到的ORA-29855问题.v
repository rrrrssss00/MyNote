Oracle Spatial创建空间索引时遇到的ORA-29855问题
Oracle Spatial创建空间索引时遇到的ORA-29855问题
过程描述:
　　执行的SQL语句:CREATE INDEX GC_ROAD_SEGMENT_CH_SIDX ON GC_ROAD_SEGMENT_CH(GEOMETRY) INDEXTYPE IS MDSYS.SPATIAL_INDEX;
　　抛出的异常: ORA-29855: error occurred in the execution of ODCIINDEXCREATE routine
创建索引：
 a:如果都是一个类型，可以使用如下创建索引，提高速度。
  CREATE INDEX geometry_index ON ix_poi(geometry)  INDEXTYPE IS MDSYS.SPATIAL_INDEX  
PARAMETERS ('LAYER_GTYPE=POINT');

b:重建索引
ALTER INDEX customers_sidx REBUILD ;

问题分析：
（1）使用以下语句查看创建索引结果：
select INDEX_NAME,TABLE_OWNER,TABLE_NAME,STATUS,ITYP_OWNER,ITYP_NAME,DOMIDX_STATUS,DOMIDX_OPSTATUS from user_indexes where ITYP_NAME is not null;
找到相应的记录，或者在上述查询中加入相应的条件（指定表名和索引类型）DOMIDX_OPSTATUS对应的为FAILED，说明创建空间索引失败。
oracle11g是有记录，但是无效，可以使用drop index GC_ROAD_SEGMENT_CH_SIDX; 删除索引

（2）使用以下语句查看相应元数据：
select * from user_sdo_geom_metadata
可以在查询条件中加入表名条件，缩小搜索范围，发现元数据表中无记录。

原　　因：
当时创建空间表时没有创建相应的空间元数据。

解决办法：
（1）先在user_sdo_geom_metadata中使用以下语句创建相应的元数据 （SDO_DIM_ELEMENT值是固定的）
insert into user_sdo_geom_metadata(table_name,COLUMN_NAME, DIMINFO, SRID)
values(
'GC_ROAD_SEGMENT_CH',
'GEOMETRY',
MDSYS.SDO_DIM_ARRAY(
MDSYS.SDO_DIM_ELEMENT('X',-180,180,0.005),
MDSYS.SDO_DIM_ELEMENT('Y',-90,90,0.005)
),
8307
)

（2）再执行空间索引创建语句：
CREATE INDEX GC_ROAD_SEGMENT_CH_SIDX ON GC_ROAD_SEGMENT_CH(GEOMETRY) INDEXTYPE IS MDSYS.SPATIAL_INDEX;
无错误提示，问题得到解决。

来源： <http://www.tqcto.com/article/db/8090.html>
 

