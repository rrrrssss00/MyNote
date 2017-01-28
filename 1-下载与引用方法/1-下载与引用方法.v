下载：
这里不介绍编译方法，只下载和使用已经编译好的版本：
GDAL主页：http://www.gdal.org/，里面有下载、API、支持格式列表及说明等信息，
另外还有一个比较好的API网页http://geoinformatics.tkk.fi/doc/Geo-GDAL/html/class_geo_1_1_g_d_a_l.html#92b259b91236580e33369984929f33d5
 
在主页中，有Download链接，http://trac.osgeo.org/gdal/wiki/DownloadingGdalBinaries，里面包含各平台的库文件下载，
这里介绍C#下的使用方法，所以进入http://www.gisinternals.com/sdk/进行下载，页面中有4种下载类型，其中第三种包含源代码，其它均只包含DLL及可执行文件，主要是版本不同
在该页面中，根据自己使用的Windows版本及VS版本下载相应的库文件
 
 
使用：
由于本人使用C#进行开发，这里用C#为例：
下载Release版本的包（不包含源代码），将解压后bin目录下所有DLL以及bin\gdal\csharp目录下的8个DLL文件（gdal_csharp,gdal_wrap,gdalconst_csharp,gdalconst_wrap,ogr_csharp,ogr_warp,osr_csharp,osr_wrap）拷贝到VS项目的程序文件夹bin中
 
注：解压目录中bin\gdal-data文件夹包含了一些库定义的信息以及坐标信息等，也可以拷贝到VS项目的程序文件夹bin（要启用gdal-data文件夹，还需要在程序中进行注明，使用 Gdal.SetConfigOption("GDAL_DATA", Application.StartupPath + "\\gdaldata"); 该语句中的路径根据实际情况变动）
 
在VS中，添加对gdal_csharp，gdalconst_csharp,ogr_csharp,osr_csharp四个DLL的引用
 
这样，就可以在程序中使用GDAL库了
