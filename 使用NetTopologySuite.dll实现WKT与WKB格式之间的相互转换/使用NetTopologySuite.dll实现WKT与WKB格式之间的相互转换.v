引用 NetTopologySuite.dll及GeoAPI.dll

代码如下：

   //先使用NetTopologySuite控件将WKT转成该控件格式下的Geometry对象
            NetTopologySuite.IO.WKTReader ntsWktReader = new NetTopologySuite.IO.WKTReader();
            GeoAPI.Geometries.IGeometry tmpNtsGeo = ntsWktReader.Read("LINESTRING(0 0,0 1,1 1)");
            //再使用NetTopologySuite控件将Geometry对象转成wkb二进制代码
            NetTopologySuite.IO.WKBWriter ntsWkbWriter = new NetTopologySuite.IO.WKBWriter(); 
            byte[] wkbBytes = ntsWkbWriter.Write(tmpNtsGeo);

