//resFile:目标图层名称
//srcLyr:源图层（Layer对象）
//创建目标图层,使用和原图层相同的坐标参考以及要素类型
DataSource destDs = Ogr.GetDriverByName("ESRI Shapefile").CreateDataSource(resFile, new string[] { });
Layer destLyr = destDs.CreateLayer(srcLyr.GetName(), srcLyr.GetSpatialRef(), srcLyr.GetGeomType(), new string[] { });

//为目标图层添加字段（使用和原图层相同的字段）
int fieldCount = srcLyr.GetLayerDefn().GetFieldCount();
for (int i = 0; i < fieldCount; i++)
{
    destLyr.CreateField(srcLyr.GetLayerDefn().GetFieldDefn(i), 1);                    
}

 //将空间对象及要素属性写入目标图层
for (int i = 0; i < geos.Count; i++)
{
    Feature newFea = new Feature(correctFeas[i].GetDefnRef());
    newFea.SetGeometry(geos[i]);
    for (int j = 0; j < correctFeas[i].GetFieldCount(); j++)
    {
	FieldType ftype = correctFeas[i].GetFieldDefnRef(j).GetFieldType();
	if (ftype == FieldType.OFTInteger)
	    newFea.SetField(j, correctFeas[i].GetFieldAsInteger(j));
	else if (ftype == FieldType.OFTReal)
	    newFea.SetField(j, correctFeas[i].GetFieldAsDouble(j));
	else if (ftype == FieldType.OFTString || ftype == FieldType.OFTWideString)
	    newFea.SetField(j, correctFeas[i].GetFieldAsString(j));
	//else if(ftype == FieldType.OFTDate)
	//    newFea.SetField(j, correctFeas[i].GetFieldAsDateTime(

    }
    destLyr.CreateFeature(newFea);
} 

destLyr.SyncToDisk();
destDs.SyncToDisk();
destLyr.Dispose();
destDs.Dispose();
