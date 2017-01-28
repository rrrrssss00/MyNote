1:对于Geometry:
所有类型的Geometry都只有一个对应的类,就是Geometry,可以用GetGeometryType()来获取其类型;
常用的几种类型:wkbPolygon,wkbLineString,wkbPoint
其中wkbPoint和wkbLineString可以用AddPoint()函数向其中加点,可以通过GetPointCout()函数来获取包含点的数目,并可以根据序号来获取各个点的坐标,这两种类型的Geometry下是没有子Geometry的,调用GetGeometryCount()函数返回值为0
wkbPolygon类型,直接调用GetPointCount()函数返回值为0,它是通过包含LineString来构成多边形的,调用GetGeometryCount()可以得到其LineString的数量,也可以通过GetGeometryRef()来直接获取该LineString
详细的使用方法参考另一篇笔记 ：OGR CookBook
 
 
DataSource ds = Ogr.Open("shp\\test.shp", 0);
Layer lyr = ds.GetLayerByIndex(0);
Feature fea1 = lyr.GetFeature(0);
Geometry geo1 = fea1.GetGeometryRef();
Geometry geo3 = new Geometry(wkbGeometryType.wkbLineString);
geo3.AddPoint(10000000, 4000000, 0);
geo3.AddPoint(10000000, -1000000, 0);
if (geo1.Intersects(geo3))
{
      Geometry geo2 = geo1.Intersection(geo3);
}

//为了支持中文路径，请添加下面这句代码(大多数情况下不需要这句)  
//OSGeo.GDAL.Gdal.SetConfigOption("GDAL_FILENAME_IS_UTF8","NO");  
//为了使属性表字段支持中文，请添加下面这句  
OSGeo.GDAL.Gdal.SetConfigOption("SHAPE_ENCODING","");  
