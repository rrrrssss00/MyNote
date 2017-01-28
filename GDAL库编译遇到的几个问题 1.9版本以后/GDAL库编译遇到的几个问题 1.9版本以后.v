1.9版本的GDAL库在编译时，可能遇到的新问题：
一、
使用VS2010编译时，在安装了VS2012后，可能会遇到这个问题：
LINK : fatal error LNK1123: failure during conversion to COFF
参考另外一篇文章：解决安装vs2012后vs2010 LINK : fatal error LNK1123: failure during conversion to COFF
 
二、
接口重定义
osr\OsrPINVOKE.cs(192,10): error CS0111:
类型“OSGeo.OSR.OsrPINVOKE”已定义了一个名为“OsrPINVOKE”的具有相同参数类型的成员
osr\OsrPINVOKE.cs(188,10): (与前一个错误相关的符号位置)
NMAKE : fatal error U1077: “C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.EXE”: 返回代码“0x1”
解决办法比较简单，只需要进入到..\gdal-1.9.2\swig\csharp\gdal|ogr|osr三个文件夹下，找到 GdalPINVOKE.cs、OgrPINVOKE.cs、OsrPINVOKE.cs三个文件大约都是第188~192行，将下述重复的声明注释掉其中一个。
static GdalPINVOKE() {
  }
//
static GdalPINVOKE() {
//}
 
三、
SWIG生成的接口成员名称错误，如：
gdal\Band.cs(17,79): error CS0117:        “OSGeo.GDAL.GdalPINVOKE”并不包含“BandUpcast”的定义
gdal\Dataset.cs(17,82): error CS0117:       “OSGeo.GDAL.GdalPINVOKE”并不包含“DatasetUpcast”的定义
gdal\Driver.cs(17,81): error CS0117:“OSGeo.GDAL.GdalPINVOKE”并不包含“DriverUpcast”的定义
NMAKE : fatal error U1077: “C:\Windows\Microsoft.NET\Framework\v4.
0.30319\csc.EXE”: 返回代码“0x1”
上述3个错误比较难定位，只能根据名称去相关类的文件里面搜索，经过反复查找发现SWIG-2.0.6/9均犯了同样的一个错误：在GdalPINVOKE.cs声明为下述三个名称的接口：
  [DllImport("gdal_wrap", EntryPoint="CSharp_Driver_SWIGUpcast")]
public static extern
IntPtr Driver_SWIGUpcast(IntPtr jarg1);
 
 [DllImport("gdal_wrap", EntryPoint="CSharp_Dataset_SWIGUpcast")]
public static extern
IntPtr Dataset_SWIGUpcast(IntPtr jarg1);
 
 [DllImport("gdal_wrap", EntryPoint="CSharp_Band_SWIGUpcast")]
public static extern IntPtr Band_SWIGUpcast(IntPtr jarg1);
在Driver、Dataset、Band类中调用时竟然搞错了名字，写成了DriverUpcast、DatasetUpcast、BandUpcast，分别修改为下列名称即可。
public Driver(IntPtr cPtr, bool cMemoryOwn, object parent) : base(GdalPINVOKE.Driver_SWIGUpcast(cPtr), cMemoryOwn, parent) {
    swigCPtr = new HandleRef(this, cPtr);
 
public Dataset(IntPtr cPtr, bool cMemoryOwn, object parent) : base(GdalPINVOKE.Dataset_SWIGUpcast(cPtr), cMemoryOwn, parent) {
    swigCPtr = new HandleRef(this, cPtr);
 
public Band(IntPtr cPtr, bool cMemoryOwn, object parent) : base(GdalPINVOKE.Band_SWIGUpcast(cPtr), cMemoryOwn, parent) {
    swigCPtr = new HandleRef(this, cPtr);
四、
安全透明代码无法调用本机C++代码的问题
（这个问题貌似只有在用2010编译时才会遇到，使用2005编译时没有发现这个问题）
System.MethodAccessException”类型的未经处理的异常出现在 gdal_csharp.dll 中。
其他信息: 安全透明方法“OSGeo.GDAL.Gdal.AllRegister()”尝试通过方法“OSGeo.GDAL.GdalPINVOKE.AllRegister()”调用本机代码失败。方法必须是安全关键的或安全可靠关键的，才能调用本机代码。
往往在执行到第一句：Gdal.AllRegister();时就会报出上述错误。
上述错误应该是由.NET平台的安全机制所导致，swig在自动封装GDAL的.NET库时，默认采用下述安全描述（在D:\GDAL\gdal-1.9.2\swig\csharp\AssemblyInfo.cs中）：
// The AllowPartiallyTrustedCallersAttribute requires the assembly to be signed with a strong name key.// This attribute is necessary since the control is called by either an intranet or Internet// Web page that should be running under restricted permissions.
[assembly: AllowPartiallyTrustedCallers]
 
// Use the .NET Framework 2.0 transparency rules (level 1 transparency) as default
#if (CLR4)
[assembly: SecurityRules(SecurityRuleSet.Level1)]
#endif
要解决该问题，只需要将调用该库的代码变为所要求的安全关键代码或者安全可靠关键代码即可，但是我搞了半天也不清楚该怎么修改，此路没走通。
(可以这样，把
[assembly: AllowPartiallyTrustedCallers] 和后面的#if (CLR4) [assembly: SecurityRules(SecurityRuleSet.Level1)]#endif全部注释掉再编译，经尝试成功）
另外一种解决办法是修改swig生成的C#封装类代码，强制声明为可被安全透明代码调用即可，以D:\GDAL\gdal-1.9.2\swig \csharp\gdal\Gdal.cs类和D:\GDAL\gdal-1.9.2\swig\csharp\gdal\Dataset.cs类为例，在其类声明的开头添加下述两行代码：
namespace OSGeo.GDAL {using System;using System.Runtime.InteropServices;using System.Security;//新加
 
[SecuritySafeCritical]
//新加public class Gdal {//...}}
namespace OSGeo.GDAL {using System;using System.Runtime.InteropServices;using System.Security;//新加
 
[SecuritySafeCritical]
//新加public class Dataset : MajorObject {//...}}
同理，如果想在C#中调用哪个类，就为哪个类添加上述两行代码即可
 
 
