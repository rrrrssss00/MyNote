在Pl/SQL中，一些列类型为Collection（或Array）的列，在整表查询时，会显示为<Collection>，可以使用下面的SQL语句查询出该字段内部的值（一次只能查一个Cell，也就是说必须指定一行一列），以Oracle Spatial的SDO_Geometry中的，SDO_ORDINATES为例

使用
select t.shape.SDO_ORDINATES from tmptab t where objectid=111;
查询到的结果为<Collection>，

可以用：
select * from table(select t.shape.SDO_ORDINATES from tmptab t where objectid=111)

来查询里面的值

