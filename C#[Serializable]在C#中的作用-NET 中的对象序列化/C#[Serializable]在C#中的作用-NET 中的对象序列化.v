转:C#[Serializable]在C#中的作用-NET 中的对象序列化
 
 
为什么要使用序列化？最重要的两个原因是：将对象的状态保存在存储媒体中以便可以在以后重新创建出完全相同的副本；按值将 对象从一个应用程序域发送至另一个应用程序域。例如，序列化可用于在 ASP.NET 中保存会话状态，以及将对象复制到 Windows 窗体的剪贴板中。它还可用于按值将对象从一个应用程序域远程传递至另一个应用程序域。本文简要介绍了 Microsoft .NET 中使用的序列化。
一.简介
    序列化是指将对象实例的状态存储到存储媒体的过程。在此过程中，先将对象的公共字段和私有字段以及类的名称（包括类所在的程序集）转换为字节流，然后再把字节流写入数据流。在随后对对象进行反序列化时，将创建出与原对象完全相同的副本。
    在面向对象的环境中实现序列化机制时，必须在易用性和灵活性之间进行一些权衡。只要您对此过程有足够的控制能力，就可以使该过程在很大程度上自动进行。例 如，简单的二进制序列化不能满足需要，或者，由于特定原因需要确定类中那些字段需要序列化。以下各部分将探讨 .NET 框架提供的可靠的序列化机制，并着重介绍使您可以根据需要自定义序列化过程的一些重要功能。
二.持久存储
    我们经常需要将对象的字段值保存到磁盘中，并在以后检索此数据。尽管不使用序列化也能完成这项工作，但这种方法通常很繁琐而且容易出错，并且在需要跟踪对 象的层次结构时，会变得越来越复杂。可以想象一下编写包含大量对象的大型业务应用程序的情形，程序员不得不为每一个对象编写代码，以便将字段和属性保存至 磁盘以及从磁盘还原这些字段和属性。序列化提供了轻松实现这个目标的快捷方法。
    公共语言运行时 (CLR) 管理对象在内存中的分布，.NET 框架则通过使用反射提供自动的序列化机制。对象序列化后，类的名称、程序集以及类实例的所有数据成员均被写入存储媒体中。对象通常用成员变量来存储对其他 实例的引用。类序列化后，序列化引擎将跟踪所有已序列化的引用对象，以确保同一对象不被序列化多次。.NET 框架所提供的序列化体系结构可以自动正确处理对象图表和循环引用。对对象图表的唯一要求是，由正在进行序列化的对象所引用的所有对象都必须标记为 Serializable（请参阅基本序列化）。否则，当序列化程序试图序列化未标记的对象时将会出现异常。当反序列化已序列化的类时，将重新创建该类， 并自动还原所有数据成员的值。
三.按值封送
    对象仅在创建对象的应用程序域中有效。除非对象是从 MarshalByRefObject 派生得到或标记为 Serializable，否则，任何将对象作为参数传递或将其作为结果返回的尝试都将失败。如果对象标记为 Serializable，则该对象将被自动序列化，并从一个应用程序域传输至另一个应用程序域，然后进行反序列化，从而在第二个应用程序域中产生出该对 象的一个精确副本。此过程通常称为按值封送。
    如果对象是从 MarshalByRefObject 派生得到，则从一个应用程序域传递至另一个应用程序域的是对象引用，而不是对象本身。也可以将从 MarshalByRefObject 派生得到的对象标记为 Serializable。远程使用此对象时，负责进行序列化并已预先配置为 SurrogateSelector 的格式化程序将控制序列化过程，并用一个代理替换所有从 MarshalByRefObject 派生得到的对象。如果没有预先配置为 SurrogateSelector，序列化体系结构将遵从下面的标准序列化规则（请参阅序列化过程的步骤）。
四.基本序列化
使用二进制格式化程序执行序列化时，一个类的所有成员变量都将被序列化，即使是那些已被标记为私有的变量。在此方面，二进制序列化不同于 XMLSerializer 类，后者只序列化公共字段。
    要使一个类可序列化，最简单的方法是使用 Serializable 属性对它进行标记，如下所示：
[Serializable]
public class MyObject {
   public int n1 = 0;
   public int n2 = 0;
   public String str = null;
}
以下代码片段说明了如何将此类的一个实例序列化为一个文件：
MyObject obj = new MyObject();
obj.n1 = 1;
obj.n2 = 24;
obj.str = "一些字符串";
IFormatter formatter = new BinaryFormatter();
Stream stream = new FileStream("MyFile.bin", FileMode.Create, 
FileAccess.Write, FileShare.None);
formatter.Serialize(stream, obj);
stream.Close();
    本例使用二进制格式化程序进行序列化。您只需创建一个要使用的流和格式化程序的实例，然后调用格式化程序的 Serialize 方法。流和要序列化的对象实例作为参数提供给此调用。类中的所有成员变量（甚至标记为 private 的变量）都将被序列化，但这一点在本例中未明确体现出来。在这一点上，二进制序列化不同于只序列化公共字段的 XML 序列化程序。
将对象还原到它以前的状态也非常容易。首先，创建格式化程序和流以进行读取，然后让格式化程序对对象进行反序列化。以下代码片段说明了如何进行此操作。
IFormatter formatter = new BinaryFormatter();
Stream stream = new FileStream("MyFile.bin", FileMode.Open, 
FileAccess.Read, FileShare.Read);
MyObject obj = (MyObject) formatter.Deserialize(fromStream);
stream.Close();
// 下面是证明
Console.WriteLine("n1: {0}", obj.n1);
Console.WriteLine("n2: {0}", obj.n2);
Console.WriteLine("str: {0}", obj.str);
    上面所使用的 BinaryFormatter 效率很高，能生成非常紧凑的字节流。所有使用此格式化程序序列化的对象也可使用它进行反序列化，对于序列化将在 .NET 平台上进行反序列化的对象，此格式化程序无疑是一个理想工具。需要注意的是，对对象进行反序列化时并不调用构造函数。对反序列化添加这项约束，是出于性能 方面的考虑。但是，这违反了对象编写者通常采用的一些运行时约定，因此，开发人员在将对象标记为可序列化时，应确保考虑了这一特殊约定。
如果要求具有可移植性，请使用 SoapFormatter。所要做的更改只是将以上代码中的格式化程序换成 SoapFormatter，而 Serialize 和 Deserialize 调用不变。对于上面使用的示例，该格式化程序将生成以下结果。
<SOAP-ENV:Envelope
   xmlns:xsi=http://www.w3.org/2001/XMLSchema-instance
   xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
   xmlns:SOAP- ENC=http://schemas.xmlsoap.org/soap/encoding/
   xmlns:SOAP- ENV=http://schemas.xmlsoap.org/soap/envelope/
   SOAP-ENV:encodingStyle=
   "http://schemas.microsoft.com/soap/encoding/clr/1.0
http://schemas.xmlsoap.org/soap/encoding/"
   xmlns:a1="http://schemas.microsoft.com/clr/assem/ToFile">
   <SOAP-ENV:Body>
     <a1:MyObject id="ref-1">
       <n1>1</n1>
       <n2>24</n2>
       <str id="ref-3">一些字符串</str>
     </a1:MyObject>
   </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
    需要注意的是，无法继承 Serializable 属性。如果从 MyObject 派生出一个新的类，则这个新的类也必须使用该属性进行标记，否则将无法序列化。例如，如果试图序列化以下类实例，将会显示一个 SerializationException，说明 MyStuff 类型未标记为可序列化。
public class MyStuff : MyObject 
{
   public int n3;
}
    使用序列化属性非常方便，但是它存在上述的一些限制。有关何时标记类以进行序列化（因为类编译后就无法再序列化），请参考有关说明（请参阅下面的序列化规则）。
五.选择性序列化
    类通常包含不应被序列化的字段。例如，假设某个类用一个成员变量来存储线程 ID。当此类被反序列化时，序列化此类时所存储的 ID 对应的线程可能不再运行，所以对这个值进行序列化没有意义。可以通过使用 NonSerialized 属性标记成员变量来防止它们被序列化，如下所示：
[Serializable]
public class MyObject 
{
   public int n1;
   [NonSerialized] public int n2;
   public String str;
}
六.自定义序列化
    可以通过在对象上实现 ISerializable 接口来自定义序列化过程。这一功能在反序列化后成员变量的值失效时尤其有用，但是需要为变量提供值以重建对象的完整状态。要实现 ISerializable，需要实现 GetObjectData 方法以及一个特殊的构造函数，在反序列化对象时要用到此构造函数。以下代码示例说明了如何在前一部分中提到的 MyObject 类上实现 ISerializable。
[Serializable]
public class MyObject : ISerializable 
{
   public int n1;
   public int n2;
   public String str;
   public MyObject()
   {
   }
   protected MyObject(SerializationInfo info, StreamingContext context)
   {
     n1 = info.GetInt32("i");
     n2 = info.GetInt32("j");
     str = info.GetString("k");
   }
   public virtual void GetObjectData(SerializationInfo info, 
StreamingContext context)
   {
     info.AddValue("i", n1);
     info.AddValue("j", n2);
     info.AddValue("k", str);
   }
}
    在序列化过程中调用 GetObjectData 时，需要填充方法调用中提供的SerializationInfo 对象。只需按名称/值对的形式添加将要序列化的变量。其名称可以是任何文本。只要已序列化的数据足以在反序列化过程中还原对象，便可以自由选择添加至 SerializationInfo 的成员变量。如果基对象实现了 ISerializable，则派生类应调用其基对象的 GetObjectData 方法。 
    需要强调的是，将 ISerializable 添加至某个类时，需要同时实现 GetObjectData 以及特殊的构造函数。如果缺少 GetObjectData，编译器将发出警告。但是，由于无法强制实现构造函数，所以，缺少构造函数时不会发出警告。如果在没有构造函数的情况下尝试反 序列化某个类，将会出现异常。在消除潜在安全性和版本控制问题等方面，当前设计优于SetObjectData 方法。例如，如果将 SetObjectData 方法定义为某个接口的一部分，则此方法必须是公共方法，这使得用户不得不编写代码来防止多次调用 SetObjectData 方法。可以想象，如果某个对象正在执行某些操作，而某个恶意应用程序却调用此对象的 SetObjectData 方法，将会引起一些潜在的麻烦。
    在反序列化过程中，使用出于此目的而提供的构造函数将 SerializationInfo 传递给类。对象反序列化时，对构造函数的任何可见性约束都将被忽略，因此，可以将类标记为 public、protected、internal 或 private。一个不错的办法是，在类未封装的情况下，将构造函数标记为 protect。如果类已封装，则应标记为 private。要还原对象的状态，只需使用序列化时采用的名称，从 SerializationInfo 中检索变量的值。如果基类实现了 ISerializable，则应调用基类的构造函数，以使基础对象可以还原其变量。
    如果从实现了 ISerializable 的类派生出一个新的类，则只要新的类中含有任何需要序列化的变量，就必须同时实现构造函数以及 GetObjectData 方法。以下代码片段显示了如何使用上文所示的 MyObject 类来完成此操作。
[Serializable]
public class ObjectTwo : MyObject
{
   public int num;
   public ObjectTwo() : base()
   {
   }
   protected ObjectTwo(SerializationInfo si, StreamingContext context) : 
base(si,context)
   {
     num = si.GetInt32("num");
   }
   public override void GetObjectData(SerializationInfo si, 
StreamingContext context)
   {
     base.GetObjectData(si,context);
     si.AddValue("num", num);
   }
}
    切记要在反序列化构造函数中调用基类，否则，将永远不会调用基类上的构造函数，并且在反序列化后也无法构建完整的对象。对象被彻底重新构建，但是在反系列 化过程中调用方法可能会带来不良的副作用,因为被调用的方法可能引用了在调用时尚未反序列化的对象引用。如果正在进行反序列化的类实现了 IDeserializationCallback，则反序列化整个对象图表后，将自动调用 OnSerialization 方法。此时，引用的所有子对象均已完全还原。有些类不使用上述事件侦听器，很难对它们进行反序列化，散列表便是一个典型的例子。在反序列化过程中检索关键 字/值对非常容易，但是，由于无法保证从散列表派生出的类已反序列化，所以把这些对象添加回散列表时会出现一些问题。因此，建议目前不要在散列表上调用方 法。
七.序列化过程的步骤
    在格式化程序上调用 Serialize 方法时，对象序列化按照以下规则进行：
检查格式化程序是否有代理选取器。如果有，检查代理选取器是否处理指定类型的对象。如果选取器处理此对象类型，将在代理选取器上调用 ISerializable.GetObjectData。 
如果没有代理选取器或有却不处理此类型，将检查是否使用 Serializable 属性对对象进行标记。如果未标记，将会引发 SerializationException。 
如果对象已被正确标记，将检查对象是否实现了 ISerializable。如果已实现，将在对象上调用 GetObjectData。 
如果对象未实现 Serializable，将使用默认的序列化策略，对所有未标记为 NonSerialized 的字段都进行序列化。 八.版本控制
    .NET 框架支持版本控制和并排执行，并且，如果类的接口保持一致，所有类均可跨版本工作。由于序列化涉及的是成员变量而非接口，所以，在向要跨版本序列化的类中 添加成员变量，或从中删除变量时，应谨慎行事。特别是对于未实现 ISerializable 的类更应如此。若当前版本的状态发生了任何变化（例如添加成员变量、更改变量类型或更改变量名称），都意味着如果同一类型的现有对象是使用早期版本进行序 列化的，则无法成功对它们进行反序列化。
如果对象的状态需要在不同版本间发生改变，类的作者可以有两种选择：
实现 ISerializable。这使您可以精确地控制序列化和反序列化过程，在反序列化过程中正确地添加和解释未来状态。 
使用 NonSerialized 属性标记不重要的成员变量。仅当预计类在不同版本间的变化较小时，才可使用这个选项。例如，把一个新变量添加至类的较高版本后，可以将该变量标记为 NonSerialized，以确保该类与早期版本保持兼容。 
九.序列化规则
    由于类编译后便无法序列化，所以在设计新类时应考虑序列化。需要考虑的问题有：是否必须跨应用程序域来发送此类？是否要远程使用此类？用户将如何使用此 类？也许他们会从我的类中派生出一个需要序列化的新类。只要有这种可能性，就应将类标记为可序列化。除下列情况以外，最好将所有类都标记为可序列化：
    所有的类都永远也不会跨越应用程序域。如果某个类不要求序列化但需要跨越应用程序域，请从 MarshalByRefObject 派生此类。 
    类存储仅适用于其当前实例的特殊指针。例如，如果某个类包含非受控的内存或文件句柄，请确保将这些字段标记为 NonSerialized 或根本不序列化此类。 
某些数据成员包含敏感信息。在这种情况下，建议实现 ISerializable 并仅序列化所要求的字段。

来源： <http://www.cnblogs.com/winner/archive/2008/03/25/1120757.html>
 
