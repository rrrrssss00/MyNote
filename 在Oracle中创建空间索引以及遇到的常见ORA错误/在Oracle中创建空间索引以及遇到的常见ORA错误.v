在使用OracleSpatial提供的空间查询函数进行空间查询时，如果没有建立空间索引，则无法进行查询，建立空间索引以及建立过程中常见的问题如下： 
以下为转载

自己建了一个有空间坐标的表，然后为空间字段创建一个空间索引，不论用SQLPLUS，或者用OEM，结果总是出错。
sql语句很简单：
 
CREATE INDEX SCGRID.COOR_IDX 
    ON SCGRID.GRID(COOR) INDEXTYPE IS MDSYS.SPATIAL_INDEX;
 
错误信息如下：
ORA-29855: 执行 ODCIINDEXCREATE 例行程序时出错
ORA-13203: 无法读取 USER_SDO_GEOM_METADATA 视图
ORA-13203: 无法读取 USER_SDO_GEOM_METADATA 视图
ORA-06512: 在 "MDSYS.SDO_INDEX_METHOD_10I", line 10
 
在网上查了半天，有的说是权限的问题，可是我用sys、system都试过，一样的问题。我甚至把所有权限全部赋给scgrid这个用户来试，还是不行。
又有的文章说是O7_DICTIONARY_ACCESSIBILITY 这个参数的问题，要设置为true。照样修改参数，然后重启数据库，依旧出错。
在百度上搜了好几轮，没找到解决办法。头大了。
 
换google搜索，总算找到了问题所在。
（声明：俺不是给google做广告，平时俺都优先用百度的，但是百度的搜索范围好像只局限于中文网站，这个就不如google了）
 
原来在给自己的表建立空间索引之前，还要在MDSYS.SDO_GEOM_METADATA_TABLE这张表中添加自己的表和空间字段的范围信息。没错了，在建立空间索引之前，Oracle需要明确空间范围和数值精度。
只要插入一条记录就可以了：
insert   into   mdsys.sdo_geom_metadata_table
(sdo_owner,sdo_table_name,sdo_column_name,sdo_diminfo)
values
('SCGRID','GRID','COOR',
    mdsys.sdo_dim_array(  
       mdsys.sdo_dim_element('Longitude',-180,180,0.00000005),   
       mdsys.sdo_dim_element('Latitude',-90,90,0.00000005)
        )
); 
执行上面的SQL语句后，在创建空间索引，一切OK了！
mdsys.sdo_geom_metadata_table，顾名思义，是记录空间表/字段的元信息的，其字段分别为：
sdo_owner：空间表的schema owner名称；
sdo_table_name：空间表的名称；
sdo_column_name：空间字段的名称；
sdo_diminfo：这个是最重要的，空间维信息。它的类型是SDO_DIM_ARRAY,空间维数组，在这里是一个二维数组，也就是有两个 SDO_DIM_ELEMENT。SDO_DIM_ELEMENT有四个字段：SDONAME（维的名称）、SDO_LB（坐标下界）、SDO_UB（坐 标上界），SDO_TOLERANCE（坐标的精度）
sdo_srid：用于标示空间坐标系，可以为空。 
理解了mdsys.sdo_geom_metadata_table之后，前面的问题自然就明白了。这个表有一个相关视图USER_SDO_GEOM_METADATA ，Oracle在创建空间索引之前，要通过查询这个视图获取创建空间索引的基础信息，由于基础信息不存在，所以就出错了。
创建空间索引，只是Oracle Spatial的基础知识吧。很惭愧，没有学习过，新手上路，边学边记。

来源： <http://blog.sina.com.cn/s/blog_53f7ffc90100c22w.html>
 

