在C#程序中实现插件架构 - Sunmast翻译
原文链接:
http://www.cuj.com/documents/s=8209/cujweb0301walcheske/
原文作者:
Shawn Patrick Walcheske
译者:
电子科技大学 夏桅
[引言]
在.NET框架下的C#语言,和其他.NET语言一样提供了很多强大的特性和机制.其中一些是全新的,而有些则是从以前的语言和平台上照搬过来的. 然而,这种巧妙的结合产生了一些有趣的方法可以用来解决我们的问题.这篇文章将讲述如何利用这些奇妙的特性,用插件(plug-ins)机制建立可扩展的 解决方案.后面也将提供一个简要的例子,你甚至可以用这个东西来替换那些已经在很多系统中广泛使用的独立的程序.在一个系统中,可能有很多程序经常需要进 行数据处理.可能其中有一个程序用于处理雇员的信息,而另一个用来管理客户关系.在大多数情况下,系统总是被设计为很多个独立的程序,他们之间很少有交 互,经常使用复制代码的办法来共享.而实际上这样的情况可以把那些程序设计为插件,再用一个单一的程序来管理这些插件.这种设计可以让我们更好的在不同的 解决方案中共享公用的方法,提供统一的感观.
图片一是一个例子程序的截图.用户界面和其他常见的程序没有什么不同.整个窗体被垂直的分割为两块.左边的窗格是个树形菜单,用于显示插件列表,在 每个插件的分支下面,列出了这个插件所管理的数据.而右边的窗格则用于编辑左边被选中的插件的数据.各个插件提供各自的编辑数据的界面.图片一展示了一个 精巧的工作区.
[开始]
那么,主程序必须能够加载插件,然后和这些插件进行通信,这样才能实现我们的设计.所有这些的实现可以有很多不同的方法,仅取决于开发者选择的语言 和平台.如果选择的是C#和.NET,那么反射(reflection)机制可以用来加载插件,并且其接口和抽象类可以用于和插件通信.
为了更好的理解主程序和插件之间的通信,可以先了解一下设计模式.设计模式最早由Erich Gamma提出[1],它利用架构和对象思想来实现通用的通信模型.不管组件是否具有不同的输入和输出,只要他们有相似的结构.设计模式可以帮助开发者利 用广受证明的面向对象理论来解决问题.事实上它就是描述解决方案的语言,而不用管问题的具体细节或者编程语言的细节.设计模式策略的关键点在于如何把整个 解决方案根据功能来分解,这种分解是通过把主程序的不同功能分开执行而完成的.这样主程序和子程序之间的通信可以通过设计良好的接口来完成.通过这种分解 我们立即可以得到这两个好处:第一,软件项目被分成较小的不相干的单位,工作流程的设计可以更容易,而较小的代码片断意味着代码更容易建立和维护.第二个 好处在于改变程序行为的时候并不会关系到主程序的运行,主程序不用关心子程序如何,他们之间只要有通用的通讯机制就足够了.
[建立接口]
在C#程序中,接口是用来定义一个类的功能的.接口定义了预期的方法,属性,事件信息.为了使用接口,每个具体的函数必须严格按照接口的定义完成所 描述的功能.列表一展示了上面例子程序的接口:IPlug.这个接口定义了四个方法:GetData,GetEditControl,Save和 Print.这四个定义并没有描述具体是怎么完成的,但是他们保证了这个类支持IPlug接口,也就是保证支持这些方法的调用.
[定制属性]
在查看代码之前,讨论总是先得转移到属性定制上面.属性定制是.NET提供的一个非常棒的新特性之一,属性对于所有的编程语言都是一种通用的结构. 举个例子,一个函数用于标识可访问权限的public,private,或者protect标志就是这个函数的一个属性.属性定制之所以如此让人兴奋,那 是因为编程人员将不再只能从语言本身提供的有限的属性集中选择.一个定制的属性其实也是一个类,它从System.Attribute继承,它的代码被允 许是自我描述的.属性定制可以应用于绝大多数结构中,包括C#里面的类,方法,事件,域和属性等等.示例代码片断定义了两个定制的属 性:PlugDisplayNameAttribute和PlugDescriptionAttribute,所有的插件内部的类必须支持这两个属性.列 表二是用于定义PlugDisplayNameAttribute的类.这个属性用于显示插件节点的内容.在程序运行的时候,主程序将可以利用反射 (reflection)来取得属性值.
[插件(Plug-Ins)]
上面的示例程序包括了两个插件的执行.这些插件在EmployeePlug.cs和CustomerPlug.cs中定义.列表三展示了EmployeePlug类的部分定义.下面是一些关键点.
1.这个类实现了IPlug接口.由于主程序根本不会知道插件内部的类是如何定义的,这非常重要,主程序需要使用IPlug接口和各个插件通信.这种设计利用了面向对象概念里面的"多态性".多态性允许运行时,可以通过指向基类的引用,来调用实现派生类中的方法.
2.这个类被两个属性标识,这样主程序可以判断这个插件是不是有效的.在C#中,要给一个类标识一个属性,你得在类的定义之前声明属性,内容附在括号内.
3. 简明起见,例子只是使用了直接写入代码的数据.而如果这个插件是个正式的产品,那么数据总是应该放在数据库中或者文件中,各自所有的数据都应该仅仅由插件 本身来管理.EmployeePlug类的数据在这里用EmployeeData对象来存储,那也是一个类型并且实现了IPlugData接 口.IPlugData接口在IPlugData.cs中定义,它提供了最基础的数据交换功能,用于主程序和插件之间的通讯.所有支持IPlugData 接口的对象在下层数据变化的时候将提供一个通知.这个通知实际上就是DataChanged事件的发生.
4.当主程序需要显示某个插件所含数据列 表的时候,它会调用GetData方法.这个方法返回IPlugData对象的一个数组.这样主程序就可以对数组中的每个对象使用ToString方法得 到数据以建立树的各个节点.ToString方法是EmployeeData类的一个重载,用于显示雇员的名字.
5.IPlug接口也定义了 Save和Print方法.定义这两个方法的目的在于当有需要打印或者保存数据的时候,要通知一个插件.EmployeePlug类就是用于实现打印和保 存数据的功能的.在使用Save方法的时候,需要保存数据的位置将会在方法调用的时候提供.这里假设主程序会向用户查询路径等信息.路径信息的查询是主程 序提供给各个插件的服务.对于Print方法,主程序将把选项和内容传递到System.Drawing.Printing.PrintDocument 类的实例.这两种情况下,和用户的交互操作都是一致的由主程序提供的.
[反射(Reflection)]
在一个插件定义好之后,下一步要做的就是查看主程序是怎么加载插件的.为了实现这个目标,主程序使用了反射机制.反射是.NET中用于运行时查看类 型信息的.在反射机制的帮助下,类型信息将被加载和查看.这样就可以通过检查这个类型以判断插件是否有效.如果类型通过了检查,那么插件就可以被添加到主 程序的界面中,就可以被用户操作.
示例程序使用了.NET框架的三个内置类来使用反射:System.Reflection.Assembly,System.Type,和System.Activator.
System.Reflection.Assembly类描述了.NET的程序集.在.NET中,程序集是配置单元.对于一个典型的Windows 程序,程序集被配置为单一的Win32可执行文件,并且带有特定的附加信息,使之适应.NET运行环境.程序集也可以配置为Win32的DLL(动态链接 库),同样需要带有.NET需要的附加信息.System.Reflection.Assembly类可以在运行的时候取得程序集的信息.这些信息包括程 序集包含的类型信息.
System.Type类描述了类型定义.一个类型声明可以是一个类,接口,数组,结构体,或者枚举.在加载了一个类之后,System.Type类可以被用于枚举该类支持的方法,属性,事件和接口.
System.Activator类用于创建一个类的实例.
[加载插件]
列表四展示了LoadPlugs方法.LoadPlugs方法在HostForm.cs中定义,是HostForm类的一个private的非静态 方法.LoadPlugs方法使用.NET的反射机制来加载可用的插件文件,并且验证它们是否符合被主程序使用的要求,然后把它们添加到主程序的树形显示 区中.这个方法包含了下面几个步骤:
1.通过使用System.IO.Directory类,我们的代码可以用通配符来查找所有的以.plug为扩展名的文件.而Directory类的静态方法GetFiles能够返回一个System.String类型的数组,以得到每个符合要求的文件的物理路径.
2. 在得到路径字符串数组之后,就可以开始把文件加载到System.Reflection.Assembly实例中了.建立Asdsembly对象的代码使 用了try/catch代码块,这样如果某个文件并不是一个有效地.NET程序集,就会抛出异常,程序此时将弹出一个MessageBox对话框,告诉用 户无法加载该文件.循环一直进行直到所有文件都已遍历完成.
3.在一个程序集加载之后,代码将遍历所有可访问到的类型信息,检查是否支持了HostCommon.IPlug接口.
4. 如果所有类型都支持HostCommon.IPlug接口,那么代码继续验证这些类型,检查是否支持那些已预先为插件定义好的属性.如果没有支持,那么一 个HostCommon.PlugNotValidException类型的异常将会被抛出,同样,主程序将会弹出一个MessageBox,告诉用户出 错的具体信息.循环一直进行直到所有文件都已遍历完成.
5.最后,如果这些类型支持HostCommon.IPlug接口,也已定义了所有需要定义的属性,那么它将被包装为一个PlugTreeNode实例.这个实例就会被添加到主程序的树形显示区.
[实现]
主程序框架被设计为两个程序集.第一个程序集是Host.exe,它提供了主程序的Windows窗体界面.第二个程序集是 HostCommon.dll,它提供了主程序和插件之间进行通信所需的所有类型定义.比如,IPlug接口就是在HostCommon.dll里面配置 的,这样它可以被主程序和插件等价的访问.这两个程序集在一个文件夹内,同样的,附加的作为插件的程序集也需要被配置在一起.那些程序集被配置在 plugs文件夹内(主程序目录的一个子文件夹).EmployeePlug类在Employee.plug程序集中定义,而CustomerPlug类 在Customer.plug程序集中定义.这个例子指定插件文件以.plug为扩展名.事实上这些插件就是个普通的.NET类库文件,只是通常库文件使 用.dll扩展名,这里用.plug罢了.特殊的扩展名对于程序运行是完全没有影响的,但是它可以让用户更明确的知道这是个插件文件.
[设计的比较]
并不是一定要像例子程序这样设计才算正确的.比如,在开发一个带有插件的C#程序时,并不一定需要使用属性.例子里使用了两个自定义的属性,其实也 可以新定义两个IPlug接口的参数来实现.这里选择用属性,是因为插件的名字和它的描述在本质上确实就是一个事物的属性,符合规范.当然了,使用属性会 造成主程序需要更多的关于反射的代码.对于不同的需求,设计者总是需要做出合理的决定.
[总结]
示例程序被设计为尽量的简单,以帮助理解主程序和插件之间的通信.在实际做产品的时候,可以做很多的改进以满足实用要求.比如:
1.通过对IPlug接口增加更多的方法,属性,事件,可以增加主程序和插件之间的通信点.两者间的更多的交互操作使得插件可以做更多的事情.
2.可以允许用户主动选择需要加载的插件.
[源代码]
示例程序的完整的源代码可以在这里下载.
ftp://ftp.cuj.com/pub/2003/2101/walchesk.zip
[备注]
[1] Erich Gamma et al. Design Patterns (Addison-Wesley, 1995).
图片一:

列表一:The IPlug interface
public interface IPlug
{
  IPlugData[] GetData();
  PlugDataEditControl GetEditControl(IPlugData Data);
  bool Save(string Path);
  bool Print(PrintDocument Document);
}
列表二:The PlugDisplayNameAttribute class definition
[AttributeUsage(AttributeTargets.Class)]
public class PlugDisplayNameAttribute : System.Attribute
{
  private string _displayName;
  public PlugDisplayNameAttribute(string DisplayName) : base()
  {
    _displayName=DisplayName;
    return;
  }
  public override string ToString()
  {
    return _displayName;
  }
列表三:A partial listing of the EmployeePlug class definition
[PlugDisplayName("Employees")]
[PlugDescription("This plug is for managing employee data")]
public class EmployeePlug : System.Object, IPlug
{
  public IPlugData[] GetData()
  {
     IPlugData[] data = new EmployeeData[]
      {
        new EmployeeData("Jerry", "Seinfeld")
        ,new EmployeeData("Bill", "Cosby")
        ,new EmployeeData("Martin", "Lawrence")
      };
    return data;
  }
  public PlugDataEditControl GetEditControl(IPlugData Data)
  {
    return new EmployeeControl((EmployeeData)Data);
  }
  public bool Save(string Path)
  {
    //implementation not shown
  }
  public bool Print(PrintDocument Document)
  {
    //implementation not shown
  }
}
列表四:The method LoadPlugs
private void LoadPlugs()
{
  string[] files = Directory.GetFiles("Plugs", "*.plug");
  foreach(string f in files)
  {
    try
    {
      Assembly a = Assembly.LoadFrom(f);
      System.Type[] types = a.GetTypes();
      foreach(System.Type type in types)
      {
        if(type.GetInterface("IPlug")!=null)
        {
          if(type.GetCustomAttributes(typeof(PlugDisplayNameAttribute),
  false).Length!=1)
            throw new PlugNotValidException(type,
              "PlugDisplayNameAttribute is not supported");
          if(type.GetCustomAttributes(typeof(PlugDescriptionAttribute),
  false).Length!=1)
            throw new PlugNotValidException(type, 
              "PlugDescriptionAttribute is not supported");
          _tree.Nodes.Add(new PlugTreeNode(type));
        }
      }
    }
    catch(Exception e)
    {
      MessageBox.Show(e.Message);
    }
  }
  return;
}
