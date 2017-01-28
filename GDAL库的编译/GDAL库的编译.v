gdal库的编译相对简单,这里以在VS2005环境,应用到C#程序中为例进行编译:
首先,下载GDAL源码:
地址:http://www.gisinternals.com/sdk/   下载其中标识为:
GDAL and MapServer build SDK packages (provides to compile MapServer and GDAL by yourself):
的部分,注意下载与自己编译环境对应的版本,本例中下载VS2005对应的32位库
 
下载完成后,解压,例如,解压到D:\GDAL
使用VS2005提供的CMD工具,定位到该文件夹,调用nmake.exe来编译makefile.vc
 
D:\GDAL>nmake makefile.vc
 
等待其编译完成,一般情况下不会有错误
 
编译主DLL完成后,由于本例中需要在C#程序中引用GDAL库,所以需要再编译C#对应的DLL文件,
这些文件位于D:\GDAL\swig\csharp\文件夹下,同样用nmake.exe来编译:
 
D:\GDAL\swig\csharp>nmake makefile.vc
(注:以本例中编译的gdal18.dll为例,有一个AssemblyInfo.cs中SecurityRules的错误,直接将这一行注释掉即可)
 
编译完成后,生成八个DLL文件(gdal_csharp.dll,gdal_warp.dll,gdalconst_csharp.dll,gdalconst_warp.dll,ogr_csharp.dll,ogr_wrap.dll,osr_csharp.dll,osr_wrap.dll),将这八个DLL和生成的gdal**.dll(**为版本号,本例中为gdal18.dll)拷贝到C#工程的Debug或Release文件夹,引用那几个带csharp关键字的DLL文件即可.
 
注意,这样编译得到的只有最核心的GDAL**.dll文件,与http://www.gisinternals.com/sdk/  中下载到编译好的包相比,其它很多库文件没有包含在其中,如果需要这些库,还需要自己进行编译,以proj.dll为例,方法如下:
 
###以下为引用,引自http://blog.csdn.net/bnuhewei/article/details/5617729###
 
(注意,在编译其它基础库之前还要下载相应的库源码,如下面例子中的proj库,到http://dowload.osgeo.org/proj/proj-4.7.0.zip去下载最新的源码,编译完成后,再修改nmake.opt)
在编译GDAL时，你可以按需要添加其它支持，如ProJ，GeoTiff等等，添加方法只要在gdal库中与makefile.vc同目录下的nmake.opt文件里找到相关配置节，把前面的“#”去掉，即取消注释，然后修改相关的路径即可。如：
nmake.opt中的PROJ.4 stuff节
# PROJ.4 stuff
# Uncomment the following lines to link PROJ.4 library statically. Otherwise
# it will be linked dynamically during runtime.
# PROJ_FLAGS = -DPROJ_STATIC
# PROJ_INCLUDE = -ID:/GDAL/proj-4.5.0/src
# PROJ_LIBRARY = D:/GDAL/proj-4.5.0/src/proj_i.lib
注:编译后,如果对nmake.opt文件进行了任何改动(例如加入了对其它support库的引用),需要先调用nmake /f makefile.vc clean命令,将之前生成的文件清除,然后再重新生成,不然生成的结果可能不会变化
本节的作用是控制链接方式，默认是注释的，即采用动态链接方式。只需拷贝proj的动态库。若要采用静态链接方式，通过取消gdal的该节注释，并设置 proj源码的对应路径即可。静态链接的好处是，加载之初就会判断库的依赖关系，这可以避免采用动态链接库而又缺少依赖库而出现莫名其妙的现象。
 
 
