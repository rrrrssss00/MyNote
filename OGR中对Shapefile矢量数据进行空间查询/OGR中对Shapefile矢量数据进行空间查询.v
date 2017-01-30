OGR支持对矢量数据进行空间查询，具体流程为：

1：使用DataSource及Layer打开矢量文件
DataSource tmpDs = Ogr.Open(path,0);
Layer tmpLyr = tmpDs.GetLayerByIndex(0);

2:通过指定空间查询条件对象进行空间查询（SetSpatialFilter及SetSpatialFilterRec方法）
tmpLyr.SetSpatialFilter(tmpFea.GetGeometryRef());        //也可以自己构造待查询的Geometry
//SetSpatialFilterRec方法同理，输入浮点格式的四边界坐标即可

3：在设定了SpatialFilter后，Layer的GetFeatureCount方法返回的即为符合条件的要素数量
tmpLyr.GetFeatureCount();

4：获取结果要素，这里需要使用Layer的GetNextFeature方法，使用GetFeature方法是不可以的
Feature tmpResFea = tmpLyr.GetNextFeature();
while(tmpResFea != null)
{
        //todo:..............

        tmpResFea = = tmpLyr.GetNextFeature();
}

5：清空SpatialFilter
tmpLyr.SetSpatialFilter(null);
