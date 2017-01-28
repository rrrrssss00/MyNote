关于GDAL180中文路径不能打开的问题分析与解决

分类： GDAL C++编程技术 GIS RS 2011-07-16 09:29 3697人阅读 评论(23) 收藏 举报
工作
    GDAL1.8.0发布很久了，一直没有将自己的工程中的版本更新到1.80。今天将其更新到1.80发现含有中文路径的文件都不能打开了，影像和矢量文件都是。仔细对比了GDAL1.72和GDAL1.80的代码，终于发现了问题的所在之处，详细代码在GDAL_HOME\port \cpl_vsil_win32.cpp文件中的类VSIWin32FilesystemHandler中，以Stat()函数为例(435行)，其他函数类似。代码如下：
       GDAL1.8.0代码（部分）：
[cpp] view plaincopyprint? 
/************************************************************************/  
/*                                Stat()                                */  
/************************************************************************/  
int VSIWin32FilesystemHandler::Stat( const char * pszFilename,   
                                     VSIStatBufL * pStatBuf,  
                                     int nFlags )  
{  
    (void) nFlags;  
  
#if (defined(WIN32) && _MSC_VER >= 1310) || __MSVCRT_VERSION__ >= 0x0601  
    if( CSLTestBoolean(  
            CPLGetConfigOption( "GDAL_FILENAME_IS_UTF8", "YES" ) ) )  
    {  
        int nResult;  
        wchar_t *pwszFilename =   
            CPLRecodeToWChar( pszFilename, CPL_ENC_UTF8, CPL_ENC_UCS2 );  
  
        nResult = _wstat64( pwszFilename, pStatBuf );  
        CPLFree( pwszFilename );  
  
        return nResult;  
    }  
    else  
#endif  
    {  
        return( VSI_STAT64( pszFilename, pStatBuf ) );  
    }  
}  
GDAL1.7.2代码（部分）：
[cpp] view plaincopyprint? 
/************************************************************************/  
/*                                Stat()                                */  
/************************************************************************/  
int VSIWin32FilesystemHandler::Stat( const char * pszFilename,   
                                     VSIStatBufL * pStatBuf )  
{  
    return( VSI_STAT64( pszFilename, pStatBuf ) );  
}  
     通过上面的代码对比，就会看到，原来在函数中添加了一个CPLGetConfigOption( "GDAL_FILENAME_IS_UTF8", "YES" )判断，通过判断是否是UTF8的编码，而且指定的默认值还是UTF8编码，在含有中文路径的字符串大多数的编码应该是GBK的编码，这样，系统就将GBK的编码当做UTF8的编码来进行转换，结果就是汉字全部是乱码，导致的结果就是找不到文件，所以打不开。

     知道原因，那么解决的方式就知道了，大概有下面几种，各有优劣，供大家选择
     1：不改变GDAL源代码，在自己调用GDALRegisterAll()和OGRAllRegiser()函数后，加上下面一句即可。
    CPLSetConfigOption("GDAL_FILENAME_IS_UTF8","NO");
这样的优点是，不用改动GDAL的源代码，但是如果自己的工程中经常打开图像的话，每次都要加，比较麻烦。
    2：修改GDAL源代码，将下面一句
    CPLSetConfigOption("GDAL_FILENAME_IS_UTF8","NO");
分别添加到GDALAllRegister()函数【GDAL_HOME\frmts\gdalallregister.cpp73行左右】和OGRRegisterAll()函数【GDAL_HOME\ogr\ogrsf_frmts\generic\ogrregisterall.cpp38行左右】中，然后重新编译GDAL即可。这样的方式就和使用以前版本的GDAL一样了，不用改动自己的代码，推荐使用这种方式。
3：修改GDAL源代码，GDAL_HOME\port\cpl_vsil_win32.cpp文件中的全部去掉CPLGetConfigOption全部去掉，或者将后面的YES改为NO，但是该工作量巨大，而且有好多地方，这种方式不推荐。

      希望对那些还在为GDAL180中文路径乱码纠结的人们有所帮助。尤其是看到好多人在外面先把中文路径转成utf8的编码，然后再调用GDAL的函数。
来源： <http://blog.csdn.net/liminlu0314/article/details/6610069>
 
