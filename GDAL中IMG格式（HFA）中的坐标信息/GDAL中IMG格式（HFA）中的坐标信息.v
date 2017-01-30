GDAL库中，为了增强与ESRI软件的兼容性，在存储IMG格式文件（HFA）时，会保存两份投影信息
一份即是原有的projection，另一份叫projectionX(在GDAL库中也叫PEString)，（有时还会对projection进行一定的修改）
为避免这个机制的发生，只保存原有的Projection，可通过以下修改实现
在GDAL库中，\frmts\hfa\hfadataset.cpp文件中，将所有的HFASetPEString(hHFA,XXXXX);调用全部修改成
HFASetPEString(hHFA,"");
即可
