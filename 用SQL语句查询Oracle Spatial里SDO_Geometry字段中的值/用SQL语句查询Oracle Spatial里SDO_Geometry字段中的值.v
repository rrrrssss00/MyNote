从《Oracle Spatial基本操作》一文中可以看到，SDO_Geometry中包含五个基本字段，分别为：sdo_Gtype，sdo_Srid，sdo_Point， sdo_Elem_Info，sdo_Ordinates
其中前两个值是正常的Number值，可以直接用如下语句查询得到(假设在一个名为tab1的表中有一个名为geo的SDO_Geometry字段)：
select geo.sdo_Gtype,geo.sdo_Srid from tab1
 
第三个字段sdo_Point为自定义类型，可以用如下语句查询
select geo.sdo_Point.X,geo.sdo_Point.Y,geo.sdo_Point.Z from tab1
 
第四个和第五个字段都为可变长度的数组，可以用table函数来查询，SQL语句如下
select * from table(select t.geo.SDO_ORDINATES from tab1 t where rownum=1)
 
这里注意，用Table函数来转换的时候，参数只能是一行中的SDO_Geometry字段，而不能是多行，这也是为什么上面的语句里要指定where rownum=1,比如下面的语句是不行的
select * from table(select t.geo.SDO_ORDINATES from tab1 t )
会报“单行子查询返回多个行”的错误

