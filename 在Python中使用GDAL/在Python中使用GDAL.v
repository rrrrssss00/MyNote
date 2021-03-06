一、安装
两种方式
1. 可以选择编译后直接安装，在GDAL编译后，swig\python下有setup.py，执行以下语句即可进行安装
python setup.py build
python setup.py install
如果没有错误，那么在python的site-packages目录会多出gdal.py,ogr.py以及osgeo文件夹，需要将data,gdalxxxx.dll,geo_c.dll等编译结果拷贝到osgeo文件夹下
在本机测试过程中，由于执行安装语句时，需要用到vs2015环境，因此未采用这种方法
2. 直接下载编译好的文件
从http://www.lfd.uci.edu/~gohlke/pythonlibs/#gdal直接下载，在命令行中用如下语句安装
pip install GDAL-xxxx.whl
这个版本里边已经包含了geos库，大部分功能都可以使用
##########################################################################################################################################################

二、使用
使用方法与在C#中差不多，由于Python中代码提示功能较弱，使用时可参考
https://pcjericks.github.io/py-gdalogr-cookbook/index.html

另外还准备了几个示例代码，见附件

##########################################################################################################################################################

三、遇到的问题
1.如果选择编译后安装，会遇到比较多的问题，其中一个就是上面说到的编译环境问题，这里没有测试，
2.在使用示例代码的过程中，发现在使用OGR库打开Shp文件时，如果使用Layer.GetFeature(i).GetGeomtryRef()函数，会报错，而需要先获取feature = Layer.GetFeature(i)，再feature.GetGeometryRef()
