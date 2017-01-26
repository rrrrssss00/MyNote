如果不借助ODAC的自定义数据类型，那么也可以使用Oracle Spatial的几个内置SQL函数来实现SDO_Geometry对象的操作
这种方法需要在数据库端对所有数据进行一次转换（不管是在select 还是insert时），有些情况下会对性能和执行时间有比较大的影响，需要注意


***.get_wkb() :***为SDO_Geometry列的列名，该函数可将SDO_Geometry对象转为wkb二进制，读取和写入时即可按照Blob类型（C#中对应byte[]）来读取和写入，示例见下文
***.get_wkt():***为SDO_Geometry列的列名，该函数可将SDO_Geometry对象转为wkt文本，读取和写入时即可按照Clob类型（C#中对应string）来读取和写入，示例见下文
注：wkt(OGC well-known text)和wkb(OGC well-known binary)是OGC制定的空间数据的组织规范，wkt是以文本形式描述，wkb是以二进制形式描述。参考http://blog.sina.com.cn/s/blog_00ccd2400101c2x8.html

sdo_geometry(wkb,srid)与sdo_geometry(wkt,srid)：sdo_geometry构造函数，可以通过传入一个blob格式的wkb对象或clob格式的wkt对象，以及一个srid,生成数据库中的sdo_geometry对象,srid可以通过 select ***.srid from 语句查询得到

示例1：按wkb格式查询（geoinfo表中只有两列，id列为number类型,geo列为SDO_GEOMTRY类型）
OracleCommand cmd = new OracleCommand(@"SELECT geo.get_wkb()  FROM geoinfo WHERE id= '12' ", con);       
con.Open();           
byte[] wkb = (byte[])cmd.ExecuteScalar();

示例2：按wkt格式查询
OracleCommand cmd = new OracleCommand(@"SELECT geo.get_wkt()  FROM geoinfo WHERE id= '12' ", con);       
con.Open();           
string wkt = (string)cmd.ExecuteScalar();

示例3：按wkb插入
OracleCommand cmdGeom = new OracleCommand(@"insert into geoinfo values (13,sdo_geometry(:geom,31297))", con);                //31297为srid，实际使用时应替换成自己的srid
OracleParameter p1 = new OracleParameter(":geom",OracleDbType.Blob);
p1.Value = wkb;                                //wkb为byte[]
cmdGeom.Parameters.Add(p1);             
 
con.Open();
int i = cmdGeom.ExecuteNonQuery();
con.Close();

示例4：按wkt插入
OracleCommand cmdGeom = new OracleCommand(@"insert into geoinfo values (13,sdo_geometry(:geom,31297))", con);
OracleParameter p1 = new OracleParameter(":geom",OracleDbType.Clob);
p1.Value = wkt;                                //wkt为string
cmdGeom.Parameters.Add(p1);             
 
con.Open();
int i = cmdGeom.ExecuteNonQuery();
con.Close();

