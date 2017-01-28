1:去http://trac.osgeo.org/gdal/wiki/DownloadSource下载源码,而不是http://www.gisinternals.com/sdk/ 
 
2:源码既能编译为32位,也能编译为64位,要编译为64位时,将nmake.opt文件中#WIN64=YES解注释即可
 
3:编译后,如果对nmake.opt文件进行了任何改动(例如加入了对其它support库的引用),需要先调用
nmake /f makefile.vc clean命令,将之前生成的文件清除,然后再重新生成,不然生成的结果可能不会变化
 
4:Dependency walker 有32位与64位版本,使用时不要弄混了

5:编译时不要带中文路径

6：其它类似编译错误，可参考另外一篇笔记 ：GDAL库编译遇到的几个问题：1.9版本以后
