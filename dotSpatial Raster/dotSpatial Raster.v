当需要使用到GDAL库时,需要将GDAL文件全部拷贝到Data Extentions\GDAL文件夹下
并且在Form中添加AppManager
 
编译新代码时,其中的Rasters.GdalExtensions项目必须在X86下编译,最好是清除之前编译的结果,重新编译一次
 
Gdal中,新版本默认不支持中文路径及文件名,需要进行修改:
在DotSpatial.Data.Raster.GdalExtension.GdalHelper.cs的Gdal.AllRegister();之后,加一行 Gdal.SetConfigOption("GDAL_FILENAME_IS_UTF8", "NO");
 
加载影像后,显示时,需要将所有的8000*8000改为4000*4000,以防止new Bitmap时因为尺寸过大而出错
