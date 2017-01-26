.net(C#)编程过程中，使用到了以下三种免安装的Oracle访问组件，能够不安装Oracle客户端，通过这些组件访问Oracle数据库

1:Oracle Data Provider for  .NET, Managed Driver:
Oracle官方的托管数据库访问组件，单DLL，Oracle.ManagedDataAccess.dll，直接引用即可，用法及相关文档：http://www.oracle.com/technetwork/issue-archive/2014/14-mar/o24odp-2147205.html

2:Oracle Data Access Components
同样是Oracle官方提供的数据库访问组件，为非托管的，但Oracle提供了.net的Wrap Dll，也就是Oracle.DataAccess.dll，这个组件本来是需要安装的，但也可以通过
一定处理，弄成免安装直接使用的，方法见：http://blog.csdn.net/rrrrssss00/article/details/7178515

3:DataDirect ODBC drivers from Oracle
第三方的托管数据库访问组件，也就是大名鼎鼎的DDTek.Oracle.dll，免安装，直接使用，非常方便，使用方法：http://blog.csdn.net/rrrrssss00/article/details/5757301




对比1：获取方便性
前两种为Oracle官方提供，均为免费下载，网址为http://www.oracle.com/technetwork/topics/dotnet/utilsoft-086879.html，ODAC的包里既有托管，也有非托管
第三种，DDTek为商业软件，需要购买，也可以免费试用（网上也有破解）

总结：1等于2优于3  （使用破解的话就都一样了。。。）

对比2：使用便利性
第一种：单DLL，直接引用即可
第二种：参考上面的用法文章，需要从ODAC包里不同子压缩包中找到多个依赖的DLL文件，放在一起方可使用，略有不便，而且不同版本的ODAC，依赖DLL的数量和各DLL文件的位置还不一样。。。。
第三种：单DLL文件加许可文件，也是直接引用

总结：1等于3优于2（ODAC找起DLL来确实麻烦）


对比3：功能性
第一种，ODP Managed Driver，有一部分功能在这个托管版本里并没有实现，详细参考：http://www.oracle.com/technetwork/database/windows/downloads/odpmbetainstall-1696475.html#Known%20Issues  这个网页的最后两个表格，比如BulkCopy和CustomType之类的都是不支持的
第二种，ODAC，这个功能是最多的
第三种，DDTek，这个也是全托管，有一部分功能限制，但是比第一种的功能略多一些，比如BulkCopy这个是支持的

总结：2优于3优于1



