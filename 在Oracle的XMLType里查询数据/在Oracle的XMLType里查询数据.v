XMLtype的查询操作:
查询对象样例：表名：etab，第一列为varchar2() 名称为id,第二列为xmltype 列名为xmlcol，
其中一行为，id字段的值为:aa
xmlcol字段的值为:
<ProductMetaData>
    <SatelliteID>ZY02C</SatelliteID>
    <ReceiveStationID>KAS</ReceiveStationID>
    <SensorID aa='ExAttr'>PMS</SensorID>
    <ReceiveTime>2012-06-09 22:12:24</ReceiveTime>
    <OrbitID>2448</OrbitID>
</ProductMetaData>
 
1:extract
作用:提取出XML串中指定节点的值(包含节点两端的标记),结果还是为clob的格式
可用column.extract('//xxx/xx'),或extract(column,'//xxx/xx')的语法
    例如:
    select t.id,t.xmlcol.extract('//ProductMetaData/SensorID') from etab t
    select t.id,extract(t.xmlcol,'//ProductMetaData/SensorID') from etab t
 
    提取出的内容为(仍为CLOB的格式): <SensorID>PMS</SensorID> 
 
还可以在之后加上/text()获取其内部文字(结果还是为clob的格式)
    例如: 
    select t.id,t.xmlcol.extract('//ProductMetaData/SensorID/text()') from etab t
    提取出的内容为（仍为CLOB的格式）：PMS
 
或在之后加上/@att获取节点的属性值
    例如：
    select t.id,t.xmlcol.extract('//ProductMetaData/SesorID/@aa') from etab t
    提取出的内容为（仍为CLOB的格式）：ExAttr
 
对于查找到的结果，可以使用getnumberval()或getstringval()函数将结果转化为需要的文字或数字
    例如： 
    select t.id,t.xmlcol.extract('//ProductMetaData/SensorID/text()').getstringval() from etab t
    提取出的内容为（文本格式）：PMS
 
    select t.id,t.xmlcol.extract('//ProductMetaData/OrbitID/text()').getnumberval() from etab t
    提取出的内容为（数字格式,可用于条件判断，例如大于小于）：2448
 
    提取内容作为条件判断：
    select t.id from etab t where t.xmlcol.extract('//ProductMetaData/OrbitID/text()').getnumberval() > 2440
 
2.extactrvalue
作用:提取出XML串中指定节点的值(不包含节点两端的标记),结果为文本格式（如果值是数字的话，好像也可以认为是数字格式，也能用于查询里的条件判断）
只能使用extractvalue(column,'//xxx/xx')的格式
    例如：
    select t.id,extractvalue(t.xmlcol,'//ProductMetaData/SensorID') from etab t
    提取出的内容为文本格式的PMS
    
    select t.id from etab t where t.xmlcol.extract('//ProductMetaData/OrbitID/text()').getnumberval() > 2440 

