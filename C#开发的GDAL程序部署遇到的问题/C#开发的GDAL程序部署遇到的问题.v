说明:
若C#版本的程序部署失败:一般来说,如果相应的.netframework部署正常,GDAL库出现以下问题:
        gdal_swap.dll或gdalXX.dll(xx为版本号)加载不上的问题;
        “OSGeo.GDAL.GdalPINVOKE”的类型初始值设定项引发异常;
        无法加载 DLL“gdal_wrap”;
        等...
应使用Dependency Walker进行检查,检查调用的库中缺失了哪些DLL文件,再进行补全,常见的错误里,有:
        MSVCP80.dll,MSVCR80.dll:这表示需要安装Microsoft Visual C++ 2008 Redistrbutable Package
        MSVCP100.dll,MSVCR100.dll:这表示需要安装Microsoft Visual C++ 2010 Redistrbutable Package
       ( 注:部分情况下,直接将这些文件拷贝到程序文件夹下也可以解决该问题)
        另有一些较少见的DLL缺失或版本错误,包括msjava.dll,mpr.dll等,解决起来较为复杂,有些可能需要自己对库文件进行编译才能解决,将出错而且不需要的DLL文件在编译时排除掉
