ODP.net是Oracle提供的数据库访问类库，其功能和效率上都有所保证，它还有一个非常方便特性：在客户端上，可以不用安装Oracle客户端，直接拷贝即可使用。
 
以下内容转载自：http://blog.ywxyn.com/index.php/archives/326
 
由于微软在.net framework4中会将System.Data.OracleClient.dll deprecated，而且就访问效率和速度而言，System.Data.OracleClient.dll与Oracle.DataAccess.dll相比，微软的确实没有oracle提供的类库有优势，所以我放弃了使用多年的System.Data.OracleClient.dll，取而代之的是odp.net。然而odp.net的优点不止这些，还包括：
 
1、不在安装客户端也能访问服务器上的oracle（假设Application Server与DB Server 分开）
 
2、不需要配置TnsNames.Ora文件
 
当然，我选择odp.net的最主要的原因还是性能。这篇文章列举了两者之间的对比。Technical Comparison: ODP.NET Versus Microsoft OracleClient
 
下面我将介绍如何在一个在新的项目中使用odp.net。环境配置：A机器，运行C#程序，没有安装oracle数据库或者客户端等任何oracle的产品；B机器就运行着一个oracle9i数据库，再没安装过其它oracle产品
 
首先要下载odp.net文件，可以在这个页面下载Oracle Data Access Components (ODAC) Downloads，我下载的是Oracle 11g ODAC 11.1.0.7.20 with Oracle Developer Tools for Visual Studio这个版本。
 
下载完成之后不用安装，将Oracle.DataAccess.dll文件从 ODTwithODAC1110720.zip\stage\Components\oracle.ntoledb.odp_net_2\11.1.0.7.10\1\DataFiles\filegroup4.jar文件中解压出来就行，然后复制到项目中，再添加引用Oracle.DataAccess.dll。
编写如下代码：
 
using Oracle.DataAccess.Client;
...
string connstring =
  "Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.0.100)(PORT=1527))" +
  "(CONNECT_DATA=(SID=orcl)));User Id=sys;Password=sys;";//这个也可以放到Web.Config中。
using (OracleConnection conn = new OracleConnection(connstring))
{
  conn.Open();
  string sql = "select * from users";
  using (OracleCommand comm = new OracleCommand(sql, conn))
  {
    using (OracleDataReader rdr = comm.ExecuteReader())
    {
      while (rdr.Read())
      {
        Console.WriteLine(rdr.GetString(0));
      }
    }
  }
}
 
代码编写好以后，还要从下载的压缩包中取出几个dll文件。
1、oci.dll (在jar文件里面叫’oci.dll.dbl’，拿出来之后去掉.dbl in ODTwithODAC1110720.zip\stage\Components\ oracle.rdbms.rsf.ic\11.1.0.7.0\1\DataFiles\filegroup2.jar)
2、oraociicus11.dll (in ODTwithODAC1110720.zip\stage\Components\ oracle.rdbms.ic\11.1.0.7.0\1\DataFiles\filegroup3.jar)
3、OraOps11w.dll (in ODTwithODAC1110720.zip\stage\Components\ oracle.ntoledb.odp_net_2\11.1.0.7.10\1\DataFiles\filegroup3.jar)
 
下面这三个有人说需要，有人说不需要，反正也不差这三个，继续吧：
4、orannzsbb11.dll (in ODTwithODAC1110720.zip\stage\Components\oracle.ldap.rsf.ic\11.1.0.7.0\1\DataFiles\filegroup1.jar)
5、oraocci11.dll (in ODTwithODAC1110720.zip\stage\Components\ oracle.rdbms.rsf.ic\11.1.0.7.0\1\DataFiles\filegroup3.jar)
6、ociw32.dll (在jar文件里面叫’ociw32.dll.dbl’，拿出来之后去掉.dbl in ODTwithODAC1110720.zip\stage\Components\ oracle.rdbms.rsf.ic\11.1.0.7.0\1\DataFiles\filegroup2.jar)
最后把这个DLL复制到项目中，CS的要与exe一个文件夹，B/S的有专门的bin目录。
 
当然，使用一项新技术，必然会遇到一些错误：以下是我遇到的：
 
1、运行的时候遇到这个异常提示’The provider is not compatible with the version of Oracle client’,不要紧张，检查一下上面所用到的dll是否齐全就OK。
 
2、“找不到请求的 .Net Framework 数据提供程序。可能没有安装。”这个错误提示是因为在machine.config中找不到Oracle.DataAccess.dll,将下面的代码放到
 
<DbProviderFactories></DbProviderFactories&gt;
 
之间就OK。
 
<add name="Oracle Data Provider for .NET" invariant="Oracle.DataAccess.Client" description="Oracle Data Provider for .NET" type="Oracle.DataAccess.Client.OracleClientFactory, Oracle.DataAccess, Version=2.111.7.20, Culture=neutral, PublicKeyToken=89b483f429c47342" /&gt;
 
注：如果下载的不是ODTwithODAC1110720，有可能dll的位置不像是上面提到的那样，需要自己去挨个找了：（
 
以上为基本的使用方法，还有几点要注意的地方（部分内容转载自 http://alderprogs.blogspot.com/2009/04/deploying-odpnet-with-oracle-instant.html）：
 
1：在上面列出的DLL中，其中Oracle.DataAccess.dll和OraOps11w.dll才是ODP.net对应的文件，其余的DLL均为OracleInstantClient对应的文件，只要能保证版本正确，可以视需求另外下载OracleInstantClient（因为InstantClient分几个版本，BASIC，BASIC_LITE等），再将这几个DLL文件替换
 
2：各版本的ODTwithODAC包，其DLL位置都不相同，在新版本的包中，上面列出的DLL中，有些DLL已经去掉了（比如orannzsbb11.dll）,而且Oracle.DataAccess.dll也根据.net的版本分为多个（以ODTwithODAC112030为例，其中包含2.x和4.0两个版本，分别对应vs2005与2010，开发时需要取用对应的包），使用时注意所取的DLL文件是否正确
 
3：对于连接字符串，上文中使用的是：
 
Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.0.100)(PORT=1527))(CONNECT_DATA=(SID=orcl)))
这个是比较典型的tnsname写法，除了这种写法外，ODP.net还支持将数据源简单地写为：[//]host[:port][/service_name]
 
例如，上文中的例子即可写成Data Souce=192.168.0.100:1527/orcl
 
此外，在这里也同样可以引用tnsnames.ora中配置好的连接（在本机装有Oracle的前提下），有两个方法：直接在程序中设置环境变量TNS_ADMIN，将其指向network\admin，或设置环境变量ORACLE_HOME，程序会自动去 %ORACLE_HOME%\network\admin下查找tnsnames.ora
 
4：进行数据库连接和查询修改之前，有一些环境变量的设置可能会影响到程序的运行结果，同时，如果本机以前已经安装过Oracle，它的一些设置也会影响到程序的运行，所以，在程序打开连接之前，可以视情况适当选用下面的一些环境变量，来保证程序运行结果的正确（注意这部分是从英文资料中转载过来的，有部分变量值对于中文环境来说可能会出现问题，请酌情修改）
 
Environment.SetEnvironmentVariable("ORA_TZFILE", null);
Environment.SetEnvironmentVariable("NLS_LANG", "AMERICAN_AMERICA.AL32UTF8");
Environment.SetEnvironmentVariable("NLS_DATE_FORMAT", "DD-MON-RR");
Environment.SetEnvironmentVariable("NLS_TIME_FORMAT", "HH.MI.SSXFF AM");
Environment.SetEnvironmentVariable("NLS_TIMESTAMP_FORMAT", "DD-MON-RR HH.MI.SSXFF AM");
Environment.SetEnvironmentVariable("NLS_TIMESTAMP_TZ_FORMAT", "DD-MON-RR HH.MI.SSXFF AM TZR");

