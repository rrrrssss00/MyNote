PostGIS中的图层(矢量)是由类似如下SQL语句创建的

SET CLIENT_ENCODING TO UTF8;
SET STANDARD_CONFORMING_STRINGS TO ON;
BEGIN;
CREATE TABLE "test11" (gid serial,
"id" int4,
"x" float8,
"y" float8);
ALTER TABLE "test11" ADD PRIMARY KEY (gid);
SELECT AddGeometryColumn('','test11','geom','4214','POINT',2);

其中,前面的语句都是平常的PostgreSql的创建表SQL语句,最后一句为添加矢量字段,其参数为:
text AddGeometryColumn(varchar table_name, varchar column_name, integer srid, varchar type, integer dimension);
text AddGeometryColumn(varchar schema_name, varchar table_name, varchar column_name, integer srid, varchar type, integer dimension);
text AddGeometryColumn(varchar catalog_name, varchar schema_name, varchar table_name, varchar column_name, integer srid, varchar type, integer dimension);
上例中:
test11为表名,
geom为矢量字段名
4124为SRID,对应当前schema下spatial_ref_sys表中ID为4124的空间参考,本例中为beijing54的地理坐标系
POINT为字段类型
2为维度

按该语句创建后,该字段的坐标系即固定为4124,即GCS_Beijing_1954

向图层中添加要素的语句为:
INSERT INTO "test11" ("id","x","y",geom) VALUES (NULL,'99.000','9.000',ST_GeomFromText('POINT(-126.4 45.32)', 4214));
其中geom对应的Value值可以是wkb,wkt,ewkb,ewkt几类,这几类的构造格式参考另一篇
<PostGIS中的矢量字段存储格式与转换&使用SQL语句读取和写入PostGIS表>
这几种构造格式都可以带要素的SRID,即坐标信息
在向图层中添加要素时,数据库会判断该要素的坐标信息与字段坐标信息是否一至,若不一致,则会报错,例如 :

错误: Geometry SRID (4213) does not match column SRID (4214)


 


