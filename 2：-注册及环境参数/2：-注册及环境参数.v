添加了对GDAL库的引用后，开始使用GDAL库函数前，需要进行注册，
 
使用using OSGeo.GDAL;来引用GDAL的命名空间，
在程序中使用 Gdal.AllRegister();语句进行注册
 
GDAL使用时有一些环境变量，可以通过设置这些变量来更改全局设置
使用Gdal.SetConfigOption(string key, string value);函数来进行设置
 
其中Key代表环境变量名，Value代表环境变量的值，可用变量名及取值范围可参考
http://trac.osgeo.org/gdal/wiki/ConfigOptions#GDALOptions 以及
http://geoinformatics.tkk.fi/doc/Geo-GDAL/html/class_geo_1_1_g_d_a_l.html#92b259b91236580e33369984929f33d5
（两个地方都好像不太全）
 
如果重复为某个变量赋值，那么以最后那一次为准
 
其中使用比较多的有：
GDAL_FILENAME_IS_UTF8     中文路径名
GDAL_DATA            DATA文件路径
GDAL_CACHEMAX        最大缓存区大小（IN BYTE），可以用Gdal.SetCacheMax函数代替
HFA_USE_RRD            IMG文件是否生成RRD格式的金字塔
……
