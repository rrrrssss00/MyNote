对于某个FeatureSet，如果其包含的要素数量非常大，那么在使用
FeatureSet.Features来获取要素列表时，会占用非常大的内存，并且消耗非常大的内存
可以使用替换的方法来获取要素总数和特定的要素

获取要素总数时可以使用FeatureSet.DataTable.Rows.Count来代替FeatureSet.Features.Count
获取指定要素时可以使用FeatureSet.GetFeature(i)来代替FeatureSet.Features[i]
