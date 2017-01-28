一、基础说明
新的GDAL版本里（据说是18以后，这个没有考证，但下文中就认为18版本以后都这样），GDAL添加了对UTF8路径的支持，新增了一个配置项，叫GDAL_FILENAME_IS_UTF8，可以在C#中使用下面的语句设为YES或NO,默认为YES
Gdal.SetConfigOption("GDAL_FILENAME_IS_UTF8", "YES");
Gdal.SetConfigOption("GDAL_FILENAME_IS_UTF8", "NO")
 
当这个值为YES（默认）时，GDAL会认为传入的路径字符串是按UTF8编码，它会试图将这个字符串转到UCS-2下，但我们一般使用的中文路径都不是UTF8的，就会产生路径乱码和无法打开的问题了，可以参考：
《关于GDAL180中文路径不能打开的问题分析与解决》 http://blog.csdn.net/liminlu0314/article/details/6610069
 
二、在C++下的解决办法
同样可以参考上面那篇文章，使用其中的前两个解决办法，将GDAL_FILENAME_IS_UTF8值设为NO即可正常读取中文路径
 
三、在C#下的问题（18版本以后）
实际上，在C#下的问题与C++下是不一样的
首先，成功地编译后，在C#下引用GDAL的相关DLL读取中文路径的文件时，不需要将GDAL_FILENAME_IS_UTF8设为NO（在C#下，将它设置为NO是会出错的，原因下文分析），在大多数情况下，读取都是正确的，
只有少数情况会出现问题，那就是：当中文路径中，出现奇数个中文字符连在一起，而且其后有除“\”之外的符号或字符时，会无法打开，比如说以下几个示例：
C:\测试路径\aa.img                        中文路径，中文字符个数为偶数，能够正常打开
C:\测试文件夹\aa.img                     中文路径，中文字符个数为奇数，但其后为"\"，能够正常打开
C:\测试文件夹1\aa.img                   中文路径，中文字符个数为奇数，其后不是"\"，无法打开，报错
C:\testPath\测试档.img                  中文路径，中文字符个数为奇数，其后不是"\"，无法打开，报错
 
四、大多数情况下能够正常读取的原因
上文中提到，在GDAL_FILENAME_IS_UTF8值为YES（也就是正常在C#里使用GDAL库的情况下），GDAL是会做编码转换的，那为什么这种情况下C#能够正常读取中文路径（大多数情况下）呢？
打开GDAL的源码，找到\swig\csharp这个文件夹，这个文件是gdal_csharp.dll等八个C#引用文件的源码，打开\swig\csharp\gdal\Gdal.cs，找到public static Dataset Open(string utf8_path, Access eAccess)这个函数，内容如下：
{
    IntPtr cPtr = GdalPINVOKE.Open(System.Text.Encoding.Default.GetString(System.Text.Encoding.UTF8.GetBytes(utf8_path)), (int)eAccess);
    Dataset ret = (cPtr == IntPtr.Zero) ? null : new Dataset(cPtr, true, ThisOwn_true());
    if (GdalPINVOKE.SWIGPendingException.Pending) throw GdalPINVOKE.SWIGPendingException.Retrieve();
    return ret;
  }
可以看到，在这个函数中，路径（字符串uft8_path）在传入后，首先将其进行了重新编码，即这一语句：System.Text.Encoding.Default.GetString(System.Text.Encoding.GetBytes(utf8_path)
再将其传给C++编写的实际处理函数，这样的转换在\swig\csharp还有很多处，正因为有了这个转换，C#中使用GDAL时才会能够正常读取出中文路径。
 
也就是说，在C#中调用GDAL时，GDAL中首先将路径字符串在C#中转到UTF-8下，再在C++在将这个UTF-8的代码转到UCS-2下，保证能够正常读取（晕了没。。。）
 
五、为什么奇数中文字符的情况下又会出现问题呢？
这个问题严格来说其实不是GDAL的错，而是C#在编码转换时出的问题，可以参考：
《浅析GDAL库C#版本支持中文路径问题》http://www.cfanz.cn/index.php?c=article&a=read&id=103228
这篇文章分析得十分细致，实验也非常严谨。
 
总结一下，就是GDAL在的C#代码中做的这个转换，
System.Text.Encoding.Default.GetString(System.Text.Encoding.GetBytes(utf8_path)
也就是先将字符串转到UTF-8编码的Byte[]，再解析为Default编码（在中文系统中，一般指的是GB2312）字符串的过程中，当遇到奇数中文字符的时候会丢失一个字节的信息，导致传给GDAL对应C++代码的路径参数是错的，那当然就无法打开了。
 
（注：其实再严格点说起来，这个问题也不是C#的错，由于不同编码的编码规则不同，这个转来转去的过程其实本身就是存在很大风险的，很多情况下都是转不过去的，不能怪人家C#）
 
六、寻找C#下的解决方案
上面提到的文章虽然分析得十分细致，但很遗憾，它没有给出比较简便的解决方案，所以只能靠自己来摸索。
 
首先，最简便的解决方案：每次打开之前分析一下路径，判断按照上面提到的规则是否会出错，如果会则提示用户。。。。。。。这种方法可以解决，但看起来挺不靠谱的
 
第二，能否找到一种方法，让其在C#下的编码转换过程中不丢字节呢？很遗憾，也没有能找到实现的方法
 
第三，既然C++都可以直接跳过这些转换，那么C#为什么不可以呢？于是有了如下的方案，经过简单测试，是有效的，暂没有发现连带问题：
 
七、最终的解决方案
修改\swig\csharp下的文件，将C#代码中的编码转换部分全部去掉，这部分代码主要集中在这几个文件中：
\swig\csharp\gdal\Gdal.cs
\swig\csharp\gdal\Driver.cs
\swig\csharp\ogr\Ogr.cs
\swig\csharp\ogr\Driver.cs
 
将这几个文件中的System.Text.Encoding.Default.GetString(System.Text.Encoding.UTF8.GetBytes(utf8_path))全部替换为utf8_path
 
重新编译（gdal1x.dll不需要重新编译，只需要重新编译csharp相关的DLL）即可，这样，路径字符串就会不经过转换直接进行传递，但和C++中一样，这时就需要在程序中将GDAL_FILENAME_IS_UTF8参数设为NO了，不然同样会读取出错
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
