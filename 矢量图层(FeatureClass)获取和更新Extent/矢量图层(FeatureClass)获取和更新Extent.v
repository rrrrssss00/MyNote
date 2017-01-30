在FeatureClass中编辑,删除,或添加要素后,可用如下的代码手动更新一下其Extent
 
((IFeatureClassManage)pFeatureClass).UpdateExtent();
 
获取图层Extent的方法为:
((IGeoDataset)pFeatureClass).Extent
 
或根据图层中的所有要素计算一下Extent:
 
IEnvelope env = null;
int feaCount = fc.FeatureCount(null);
for (int i = 0; i < feaCount; i++)
{
if (env == null) env = fc.GetFeature(i).Extent;
else env.Union(fc.GetFeature(i).Extent);
}
 
要注意的是,这两种方法获取到的Extent有时是不一样的
