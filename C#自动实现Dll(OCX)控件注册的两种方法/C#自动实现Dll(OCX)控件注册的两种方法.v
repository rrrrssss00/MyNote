C#自动实现Dll(OCX)控件注册的两种方法
尽管MS为我们提供了丰富的.net framework库，我们的程序C#开发带来了极大的便利，但是有时候，一些特定功能的控件库还是需要由第三方提供或是自己编写。当需要用到Dll引用的时候，我们通常会通过“添加引用”的方式将它们纳入到项目中，然后就可以像使用自己的类一样方便的使用它们了。但是，有些Dll库(OCX)文件是需要注册到Windows注册表后才能正常添加和使用的。本文介绍两种为Dll库(OCX)自动注册的方法，为大家提供参考。

首先，大家都知道在Windows的“运行”中，输入“Regsvr32.exe 路径”这样的方法来手动注册Dll控件(OCX)，显示这种方法对于程序的自动化部署等带来极大的不便，因此，今天我们着重介绍如何用C#实现自动注册。

方法一：调用Regsvr32法

既然可以在运行栏中输入“Regsvr32.exe 路径”的方法来注册，那么，一定可以在C#程序中采用同样的方法来调用Regsvr32，以实现注册：

Process p = new Process();
p.StartInfo.FileName = "Regsvr32.exe";
p.StartInfo.Arguments = "/s C:\\DllTest.dll";//路径中不能有空格
p.Start();
采用这种方法，注意要添加对命名空间System.Diagnostics的引用：

using System.Diagnostics;
另外，这种方法有一个不足之处，那就是注册工作是在本程序之外由Regsvr32.exe程序来完成的，系统内不方便知道注册的结果，也不方便对注册过程弹出的对话框进行自定义和控制。这里附Regsvr32的参数说明：(感谢网友伍华聪的提醒)

regsvr32.exe是32位系统下使用的DLL注册和反注册工具，使用它必须通过命令行的方式使用，格式是：

　　regsvr32 [/u] [/s] [/n] [/i[:cmdline]] DLL文件名

　　命令可以在“开始→运行”的文本框中，也可以事先在bat批处理文档中编写好命令。未带任何参数是注册DLL文件功能，其它参数对应功能如下：

　　/u：反注册DLL文件;

　　/s：安静模式(Silent)执行命令，即在成功注册/反注册DLL文件前提下不显示结果提示框。

　　/c：控制端口;

　　/i：在使用/u反注册时调用DllInstall;

　　/n：不调用DllRegisterServer，必须与/i连用。

方法二：调用DllRegisterServer函数法

既然方法一不大实用，那么我们就来寻找一种真正实用的方法来达到我们的目的吧。研究Regsvr32.exe和Dll文件，我们会发现，其实每个需要注册的文件都包括一个DllRegisterServer()方法，Regsvr32.exe就是通过调用该方法来完成Dll的注册的。呵呵，知道了这个，我们就可以自己调用DllRegisterServer()来完成注册过程啦。

首先，还得引入外部方法：

[DllImport("DllTest.dll")]
public static extern int DllRegisterServer();//注册时用
[DllImport("DllTest.dll")]
public static extern int DllUnregisterServer();//取消注册时用
接下来就不难啦：
int i = DllRegisterServer();
if (i >= 0)
{
    //注册成功!
}
else
{
    //注册失败
}
取消注册的过程就不应再贴代码啦。
两种方法介绍完啦，可是好像还缺点什么？对了，那就是对Dll是否已经注册过了的判断。一般情况下，我们可以将对Dll控件的注册过程放在系统启动的过程中来完成，但是，总不能每次启动都注册一次吧？这样做显然不合理。那么，我们就来判断一下，当前Dll是否已经注册过，如果已注册过，就跳过注册过程。

每一个Dll的注册都会在注册表里记录下有关它本身的资料，如注册路径，唯一ID等。我们这里就是利用它留下的唯一ID号来判断：

RegistryKey rkTest = Registry.ClassesRoot.OpenSubKey("CLSID\\{7713F78A-44DE-42BA-A1F6-3FB0BD6CA63B}\\");
if (rkTest == null)
{
    //Dll没有注册，在这里调用DllRegisterServer()吧
｝
注意要添加对命名空间Microsoft.Win32的引用：

using Microsoft.Win32;
其中的“{7713F78A-44DE-42BA-A1F6-3FB0BD6CA63B}”就是该Dll的唯一ID啦，每一个Dll文件都会不一样的。但是，问题又来了，怎么样知道它的唯一ID呢？其实很简单，那就是“逆向思维”。我们可先注册这个Dll文件，然后到注册表的“HKEY_CLASSES_ROOT\CLSID”分支下“查找”Dll的名称或路径，就可以看到这个ID啦。简单我就不多说啦。

写到这里，该说的问题总算说完啦。大家如果还有什么疑问的话可以回帖提出。
