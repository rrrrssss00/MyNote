与新建Feature时添加属性表值的操作略有不同，当对已有Feature 的属性表值进行修改时，使用以下方法：

Feature tmpFea = lyr.GetFeature(0);
tmpFea.SetField(1,"new prop");
lyr.SetFeature(tmpFea);
lyr.SyncToDisk();
