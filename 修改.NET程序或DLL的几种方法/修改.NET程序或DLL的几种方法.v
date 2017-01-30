本文目的是回答一个朋友关于修改程序集的留言，都是比较简单的修改方式，不涉及脱壳等。

1:    利用ILASM和ILDASM

我们先建立如下测试程序：
namespace Test
{
class Program
{
static void Main(string[] args)
{
string s = "hello world!";
Console.WriteLine(s);
Console.ReadKey();
}
}
}

编译之后得到Test.exe
打开Visual studio提供的命令行工具，它已经默认的设置好了相关的环境变量，输入如下命令：
ildasm test.exe /OUT=test.il
将得到两个文件：test.il和test.res，用记事本打开test.il，将看到如下IL代码:
IL_0000: ldstr      "hello world!"
IL_0005: stloc.0
IL_0006: ldloc.0
IL_0007: call       void [mscorlib]System.Console::WriteLine(string)
IL_000c: call       valuetype [mscorlib]System.ConsoleKeyInfo [mscorlib]System.Console::ReadKey()
IL_0011: pop
IL_0012: ret
我们将第一行修改为：
IL_0000: ldstr      "hello world! --has been modified"
当然也可以增加一些函数的调用和删除我们不想要的函数，如果对IL不熟悉，可以先在VS中写好想要的代码，反编译为IL，然后直接拷贝过来。修改完后，点保存，在命令行运行如下命令：
ilasm /OUT=test2.exe test.il
如果语法没有错误，将看到如下提示
Source file is ANSI

Assembled method Test.Program::Ma
Assembled method Test.Program::.c
Creating PE file

Emitting classes:
Class 1:        Test.Program

Emitting fields and methods:
Global
Class 1 Methods: 2;

Emitting events and properties:
Global
Class 1
Writing PE file
Operation completed successfully
证明已经修改成功，我们可以直接运行test2.exe，发现程序已经按我们修改的输出了：
hello world! -- has been modified.

2.利用Reflector的插件Reflexil

直接用IL修改比较麻烦，不小心很容易出错，幸好我们有Jb Evain编写的Reflexil。
Reflexil基于Mono.Cecil，是一个强大的程序集编辑器。
下载完后打开Reflector --> View --> Add-Ins --> Add --> 选择Reflexil.dll，
以后就可以直接用Reflector的Tools打开了。

开 始正式的修改，用Reflector打开test.exe，打开Reflexil，选择Main函数，可以发现IL代码显示在下方了，可以点击右键 Edit，Delete，Create等操作，没错，你还发现了Replace all with code，通过这个可以直接用C#代码直接修改。其它的功能多试试就明白了，另外点击类的时候，还可以修改类的访问权限等，比如将private改成 public。我们选中第0行，直接选择Edit，将Operand后面的文本修改为：hello world! -- modified by reflexil.点击Update，在Reflector中选中Test.exe module，Save as test3.exe。执行test3.exe，就看到我们的修改生效了
来源： <http://hi.baidu.com/expertsearch/item/f309a548e5343bf1dc0f6c99>
 
