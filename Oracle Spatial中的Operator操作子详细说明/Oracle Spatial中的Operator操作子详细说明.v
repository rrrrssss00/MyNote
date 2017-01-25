Oracle Spatial中的Operator操作子 详细说明
关于Sdo_Geometry的相关内容，请参考： http://www.cnblogs.com/upDOoGIS/archive/2009/05/20/1469871.html 
 
SDO_FILTER
格式：
    SDO_FILTER(geometry1, geometry2, params);
描述：
    通过空间索引，根据给定的几何要素检索出具有空间相互关系的空间对象。这里的空间关系是指两个几何不分离，即Non-disjoint。【disjoint：表示两个几何的边和内部都不相交】
    这个Sdo_Filter执行只是初始的空间过滤操作；二次的过滤操作将由SDO_RELATE操作子完成，它能确定空间对象的相交关系。
参数：
geometry1： 指需要查询表中几何列，该几何列务必已经建立空间索引。该列的数据类型为：MDSYS.SDO_GEOMETRY。
geometry2： 它值的可以是表中的几何，也可以是具体的几何对象（包括关联的几何对象变量、通过SDO_GEOMETRY构造函数的几何对象）。该列的数据类型也为：MDSYS.SDO_GEOMETRY。
params：  决定操作子的行为。数据类型为VARCHAR2。
该params具体有以下几种：
querytype: 有效的查询类型有：WINDOW和JOIN.。这是个必须的参数。
          querytype =’ WINDOW’建议大部分情况下是使用该参数的。WINDOW’表明查询将执行表中所有候选geometry1，与geometry2进行比较。也就是说WINDOW将单个geometry1和所有的geometry2进行空间关系操作，并比较是否满足空间关系。
          querytype =’ JOIN’很少用到。当你想比较该geometry1几何列和另外geometry2表中的几何列的话可使用JOIN。使用JOIN表明该geometry2必须建立的几何索引（具体参考使用说明）。
          idxtab1【可选】：如果存在多个空间索引表，它指的是geometry1空间索引表对应的表名。
idxtab2【可选】：如果存在多个空间索引表，它指的是geometry1空间索引表对应的表名。只有当querytype =’ JOIN’才可以使用该参数。
返回值：
表达式SDO_FILTER(arg1, arg2, arg3) = ‘TRUE’中的True表明两个几何空间关系为：不相离；否则为False。
使用说明
这个SDO_FILTER操作子必须用在Where子句中，在sql语句中使用该格式：SDO_FILTER(arg1, arg2,arg3) = ‘TRUE’.。
如果querytype =’ WINDOW’。 geometry2可以来自一个表，也可以来自具体的几何对象（包括关联的几何对象变量、通过SDO_GEOMETRY构造函数的几何对象）。
1、如果2个或大于2的geometry2几何将在SDO_FILTER中使用的话，geometry2将在from语句的第一个参数。
如果querytype =’ JOIN’。
1、geometry2必须来自于表；
2、为了更好的执行SQL语句，geometry1和geometry2应该使用相同的空间索引类型（R树或者二叉树）；如果是二叉树他们应该有相同的sdo_level值。geometry1和geometry2不是相同的索引类型，geometry2将按照geometry1索引类型重新构建索引，这样SQL语句的性能就大打折扣。
如果geometry1和geometry2是基于不同的坐标参考系统的话，为了   执行操作geometry2将被临时的转换为geometry1的坐标系统。
举例：
1、从Polygons表中选择出满足一定条件的GID。该条件为：选择出的GID对应的几何与query_polys表中GID=1的几何不相离。
SELECT A.gid
FROM Polygons A, query_polys B
WHERE B.gid = 1
AND SDO_FILTER(A.Geometry, B.Geometry, ’querytype = WINDOW’) = ’TRUE’;
///其中A.Geometry为Polygons表几何列的列名
2、也是从Polygons表中选择出满足一定条件的GID。不过查询几何被存储到aGeom变量中。
Select A.Gid
FROM Polygons A
WHERE SDO_FILTER(A.Geometry, :aGeom, ’querytype=WINDOW’) = ’TRUE’;
3、也是从Polygons表中选择出满足一定条件的GID。查询几何为sdo_geometry构造函数构造的几何。
Select A.Gid
FROM Polygons A
WHERE SDO_FILTER(A.Geometry, mdsys.sdo_geometry(2003,NULL,NULL,
mdsys.sdo_elem_info_array(1,1003,3),
mdsys.sdo_ordinate_array(x1,y1,x2,y2)),
’querytype=WINDOW’) = ’TRUE’;
4、从Polygons表中选择出满足一定条件的GID，当Polygons表的候选几何与任意一个query_polys的几何对象不相离都将GID选择出。因为多个query_polys中的几何将涉及到（参考使用说明）geometry2将被放到from的第一个参数。
SELECT /*+ ORDERED */
A.gid
FROM query_polys B, polygons A
WHERE SDO_FILTER(A.Geometry, B.Geometry, ’querytype = WINDOW’) = ’TRUE’;
5、从Polygons表中选择出满足一定条件的GID，当Polygons表的候选几何与任意一个query_polys的几何对象不相离都将GID选择出。在这个例子中QUERY_POLYS.GEOMETRY几何列务必建立了空间索引。
SELECT A.gid
FROM Polygons A, query_polys B
WHERE
SDO_FILTER(A.Geometry, B.Geometry, ’querytype = JOIN’) = ’TRUE’;
 
SDO_RELATE
格式：
SDO_RELATE(geometry1, geometry2, params);
描述：
通过空间索引，根据给定的几何要素（如一个多边形）检索出与其有特殊空间关系的几何要素。这个空间关系包括九种：Touch, OVERLAPBDYDisjoint, OVERLAPBDYIntersect, Equal,Inside, CoveredBy, Contains, Covers, AnyInteract, On.。具体图形标识如下：
这个操作子相当于同时执行了第一步（SDO_FILTER的功能）和第二步过滤操作
参数和关键字：
geometry1： 指需要查询表中几何列，该几何列务必已经建立空间索引。该列的数据类型为：MDSYS.SDO_GEOMETRY。
geometry2： 它值的可以是表中的几何，也可以是具体的几何对象（包括关联的几何对象变量、通过SDO_GEOMETRY构造函数的几何对象）。该列的数据类型也为：MDSYS.SDO_GEOMETRY。
params： 决定操作子的行为。数据类型为VARCHAR2。
该params具体有以下几种：
Mask：指定了空间关系。这是个必须的参数。有九种关系如上图所示，多种空间关系可以组合：例如：’mask=inside+touch’;
Querytype：可以参考SDO_FILTER中的介绍，在此不累赘。
idxtab1和idxtab2 ：可以参考SDO_FILTER中的介绍，在此不累赘。
返回值：
表达式SDO_RELATE(geometry1,geometry2, ’mask = <some_mask_val> ,querytype = <some_querytype>’) = ’TRUE’中的True是指两个几何对象满足<some_mask_val>条件。否则为Flase。
举例：
这里的所有要求条件和SDO_FILTER例子一样
1、从Polygons表中选择出满足一定条件的GID。该条件为：选择出的GID对应的几何与query_polys表中GID=1的有任何相交关系。
SELECT A.gid
FROM Polygons A, query_polys B
WHERE B.gid = 1
AND SDO_RELATE(A.Geometry, B.Geometry,
’mask=ANYINTERACT querytype=WINDOW’) = ’TRUE’;
2、也是从Polygons表中选择出满足一定条件的GID。不过查询几何被存储到aGeom变量中。
Select A.Gid
FROM Polygons A
WHERE SDO_RELATE(A.Geometry, :aGeom, ’mask=ANYINTERACT querytype=WINDOW’)= ’TRUE’;
其他的例子里类似，这里也不累赘。
 
下面给出两个操作子结合的SQL语句
SELECT name boat_name //选择在定义矩形内的所有小船
FROM mylake t
WHERE feature_id = 12
AND SDO_FILTER(t.shape, mdsys.sdo_geometry(2003,NULL,NULL,
    mdsys.sdo_elem_info_array(1,1003,1),
    mdsys.sdo_ordinate_array(2,2, 5,2, 5,5, 2,5, 2,2)),
    'querytype=WINDOW') = 'TRUE'
AND SDO_RELATE(t.shape, mdsys.sdo_geometry(2003,NULL,NULL,
    mdsys.sdo_elem_info_array(1,1003,1),
    mdsys.sdo_ordinate_array(2,2, 5,2, 5,5, 2,5, 2,2)),
    'masktype=INSIDE querytype=WINDOW') = 'TRUE'
 
SDO_WITHIN_DISTANCE
格式：
SDO_WITHIN_DISTANCE(geometry1, aGeom, params);
描述：
通过空间索引，检索出距离给定几何对象（可以是具体的多边形、点等）的一定范围内的所有空间对象。
参数和关键字：
geometry1：一个表中几何列的列名。这列的几何对象如果是在给定对象aGeom的一定范围之内的话，将被检索出来。这个geometry1对应的几何列务必创建空间索引。
该列的数据类型为：MDSYS.SDO_GEOMETRY。
aGeom：值根据这个对象和一定距离去检索geometry1。它可以是一个表的几何列（包含对象的变量），也可以是一个具体的几何对象（如通过SDO_GEOMETRY构造函数的几何对象）。
该列的数据类型为：MDSYS.SDO_GEOMETRY。
PARAMS：决定操作子的行为。数据类型为VARCHAR2。
该params具体有以下几种：
         Distance：指距离长度，这是个必须的参数。如果指定过滤的几何有关联的参考坐标，这个距离的单位就是参考坐标的单位。数据类型为Number。
         idxtab1：可以参考SDO_FILTER中的介绍，在此不累赘。
         Querytype：设置为’querytype=FILTER’将执行第一步过滤操作。如果querytype没有指定第一步和第二步过滤操作将执行（默认为该种情况）。数据类型为VARCHAR2。
         Unit：指定距离单位。例如：unit=’KM’.具体的单位SDO_UNIT 值来之MDSYS.SDO_DIST_UNITS 表。数据类型为Number。默认的单位适合具体的数据关联的，例如数据是投影数据的话，单位为M.
返回值：
表达式SDO_WITHIN_DISTANCE(arg1, arg2, arg3) = ’TRUE’，为True将返回一定距离子内的所有要素。
举例：
1、得到距离矩形为10单位之内的所有POLYGONS几何的GID
SELECT A.GID
FROM POLYGONS A
WHERE
SDO_WITHIN_DISTANCE(A.Geometry, mdsys.sdo_geometry(2003,NULL,NULL,
mdsys.sdo_elem_info_array(1,1003,3),
mdsys.sdo_ordinate_array(x1,y1,x2,y2)),
’distance = 10’) = ’TRUE’;
2、得到距离 Query_Points中GID = 1对应的几何 为10单位之内的所有POLYGONS几何的GID
SELECT A.GID
FROM POLYGONS A, Query_Points B
WHERE B.GID = 1 AND
SDO_WITHIN_DISTANCE(A.Geometry, B.Geometry, ’distance = 10’) = ’TRUE’;

来源： <http://www.cnblogs.com/upDOoGIS/archive/2009/05/31/1493115.html>
 

