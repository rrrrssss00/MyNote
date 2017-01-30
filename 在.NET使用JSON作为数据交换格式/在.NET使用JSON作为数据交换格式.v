         在.NET使用JSON作为数据交换格式
分类： C#基础 asp.net 2011-03-16 21:04 29308人阅读 评论(55) 收藏 举报
json.netuserlinqstreamstring
我们知道在.NET中我们有多种对象序列化的方式，如XML方式序列化、Binary序列化，其中XML序列化是一种比较通用的在各语言之间传递数据的方式。除了这两种序列化方式之外，在.NET中还可以使用JSON序列化。
JSON（JavaScript Object Notation）是一种轻量级轻量级的数据交换格式，并且它独立于编程语言，与XML序列化相比，JSON序列化后产生的数据一般要比XML序列化后数 据体积小，所以在Facebook等知名网站中都采用了JSON作为数据交换方式。在.NET中有三种常用的JSON序列化的类，分别是 System.Web.Script.Serialization.JavaScriptSerializer类、 System.Runtime.Serialization.Json.DataContractJsonSerializer类和 Newtonsoft.Json.JsonConvert类。
为了便于下面的演示，下面提供一个类的代码：
[c-sharp] view plaincopy
[DataContract]  
public class User  
{  
    /// <summary>  
    /// 编号  
    /// </summary>  
    [DataMember]  
    public int UserId { get; set; }  
    /// <summary>  
    /// 用户名  
    /// </summary>  
    [DataMember]  
    public string UserName { get; set; }  
    /// <summary>  
    /// 创建时间  
    /// </summary>  
    [DataMember]  
    [JsonConverter(typeof(IsoDateTimeConverter))]  
    public DateTime CreateDate { get; set; }  
    /// <summary>  
    /// 生日  
    /// </summary>  
    [DataMember]  
    [JsonConverter(typeof(JavaScriptDateTimeConverter))]  
    public DateTime Birthday { get; set; }  
    /// <summary>  
    /// 相关URL  
    /// </summary>  
    [DataMember]  
    public List<string> Urls { get; set; }  
    /// <summary>  
    /// 薪水  
    /// </summary>  
    //[ScriptIgnore]//使用JavaScriptSerializer序列化时不序列化此字段  
    //[IgnoreDataMember]//使用DataContractJsonSerializer序列化时不序列化此字段  
    //[JsonIgnore]//使用JsonConvert序列化时不序列化此字段  
    public int Salary { get; set; }  
    /// <summary>  
    /// 权利级别  
    /// </summary>  
    [DataMember]  
    public Priority Priority { get; set; }  
  
    public User()  
    {  
        Urls = new List<string>();  
    }  
}  
/// <summary>  
/// 权利级别  
/// </summary>  
public enum Priority:byte  
{  
    Lowest=0x1,  
    BelowNormal=0x2,  
    Normal=0x4,  
    AboveNormal=0x8,  
    Highest=0x16  
}  

使用System.Web.Script.Serialization.JavaScriptSerializer类
System.Web.Script.Serialization.JavaScriptSerializer 类是.NET类库中自带的一种JSON序列化实现，在.NET Framework3.5及以后版本中可以使用这个类，这个类位于System.Web.Extensions.dll中，使用这个类是必须添加对这个 dll的引用。
下面的代码是使用JavaScriptSerializer进行序列化和反序列化的例子：
[c-sharp] view plaincopy
public static void JavaScriptSerializerDemo()  
{  
    User user = new User { UserId = 1, UserName = "李刚", CreateDate = DateTime.Now.AddYears(-30),Birthday=DateTime.Now.AddYears(-50), Priority = Priority.Highest, Salary = 500000 };  
    //JavaScriptSerializer类在System.Web.Extensions.dll中，注意添加这个引用  
    JavaScriptSerializer serializer = new JavaScriptSerializer();  
    //JSON序列化  
    string result=serializer.Serialize(user);  
    Console.WriteLine("使用JavaScriptSerializer序列化后的结果：{0},长度：{1}", result, result.Length);  
    //JSON反序列化  
    user = serializer.Deserialize<User>(result);  
    Console.WriteLine("使用JavaScriptSerializer反序列化后的结果：UserId:{0},UserName:{1},CreateDate:{2},Priority:{3}", user.UserId, user.UserName, user.CreateDate, user.Priority);  
  
}  

说明：如果不想序列化某个字段，可以在字段前面加[JsonIgnore]标记。

使用System.Runtime.Serialization.Json.DataContractJsonSerializer类
System.Runtime.Serialization.Json.DataContractJsonSerializer 类位于System.ServiceModel.Web.dll中，使用这个类时除了需要添加对System.ServiceModel.Web.dll 的引用之外，还需要添加System.Runtime.Serialization.dll的引用，注意这个类也是在.NET Framework3.5及以后版本中可以使用。
下面是使用DataContractJsonSerializer类的例子：
[c-sharp] view plaincopy
public static void DataContractJsonSerializerDemo()  
{  
    User user = new User { UserId = 1, UserName = "李刚", CreateDate = DateTime.Now.AddYears(-30), Birthday = DateTime.Now.AddYears(-50), Priority = Priority.AboveNormal, Salary = 50000 };  
    string result = string.Empty;  
    //DataContractJsonSerializer类在System.ServiceModel.Web.dll中，注意添加这个引用  
    DataContractJsonSerializer serializer = new DataContractJsonSerializer(typeof(User));  
      
    using (MemoryStream stream = new MemoryStream())  
    {  
        //JSON序列化  
        serializer.WriteObject(stream, user);  
        result = Encoding.UTF8.GetString(stream.ToArray());  
        Console.WriteLine("使用DataContractJsonSerializer序列化后的结果：{0},长度：{1}", result, result.Length);  
    }  
  
    //JSON反序列化  
    byte[] buffer = Encoding.UTF8.GetBytes(result);  
    using (MemoryStream stream = new MemoryStream(buffer))  
    {  
        user = serializer.ReadObject(stream) as User;  
        Console.WriteLine("使用DataContractJsonSerializer反序列化后的结果：UserId:{0},UserName:{1},CreateDate:{2},Priority:{3}", user.UserId, user.UserName, user.CreateDate, user.Priority);  
    }  
}  

注 意：要使用DataContractJsonSerializer类进行序列化和反序列化，必须给类加上[DataContract]属性，对要序列化的 字段加上[DataMember]属性，如果不想序列化某个字段或者属性，可以加上[IgnoreDataMember]属性。

使用Newtonsoft.Json.JsonConvert类
Newtonsoft.Json.JsonConvert类是非微软提供的一个JSON序列化和反序列的开源免费的类库（下载网址是：http://www.codeplex.com/json/）， 它提供了更灵活的序列化和反序列化控制，并且如果你的开发环境使用的是.NET Framework3.5及以后版本的话，你就可以使用Linq to JSON，这样一来面对一大段的数据不必一一解析，你可以使用Linq to JSON解析出你关心的那部分即可，非常方便。
下面是使用Newtonsoft.Json.JsonConvert类的例子：
[c-sharp] view plaincopy
public static void JsonConvertDemo()  
{  
    User user = new User { UserId = 1, UserName = "李刚", CreateDate = DateTime.Now.AddYears(-30), Birthday = DateTime.Now.AddYears(-50), Priority = Priority.BelowNormal, Salary = 5000 };  
    //JsonConvert类在Newtonsoft.Json.Net35.dll中，注意到http://www.codeplex.com/json/下载这个dll并添加这个引用  
    //JSON序列化  
    string result = JsonConvert.SerializeObject(user);  
    Console.WriteLine("使用JsonConvert序列化后的结果：{0},长度：{1}", result, result.Length);  
    //JSON反序列化  
    user = JsonConvert.DeserializeObject<User>(result);  
    Console.WriteLine("使用JsonConvert反序列化后的结果：UserId:{0},UserName:{1},CreateDate:{2},Priority:{3}", user.UserId, user.UserName, user.CreateDate, user.Priority);  
}  
  
public static void JsonConvertLinqDemo()  
{  
    User user = new User { UserId = 1, UserName = "周公", CreateDate = DateTime.Now.AddYears(-8), Birthday = DateTime.Now.AddYears(-32), Priority = Priority.Lowest, Salary = 500, Urls = new List<string> { "http://zhoufoxcn.blog.51cto.com", "http://blog.csdn.net/zhoufoxcn" } };  
    //JsonConvert类在Newtonsoft.Json.Net35.dll中，注意到http://www.codeplex.com/json/下载这个dll并添加这个引用  
    //JSON序列化  
    string result = JsonConvert.SerializeObject(user);  
    Console.WriteLine("使用JsonConvert序列化后的结果：{0},长度：{1}", result, result.Length);  
    //使用Linq to JSON  
    JObject jobject = JObject.Parse(result);  
    JToken token = jobject["Urls"];  
    List<string> urlList = new List<string>();  
    foreach (JToken t in token)  
    {  
        urlList.Add(t.ToString());  
    }  
    Console.Write("使用Linq to JSON反序列化后的结果：[");  
    for (int i = 0; i < urlList.Count - 1;i++ )  
    {  
        Console.Write(urlList[i] + ",");  
    }  
    Console.WriteLine(urlList[urlList.Count - 1] + "]");  
}  

注 意：如果有不需要序列化的字段，可以给该字段添加[JsonIgnore]标记。在Newtonsoft这个类库中对于日期的序列化有多种方式，可以类的 DataTime成员添加上对应的标记，这样在进行序列化和反序列化时就会按照指定的方式进行，在本例中User类的CreateDate属性添加的属性 是[JsonConverter(typeof(IsoDateTimeConverter))]，而Birthday属性添加的属性是 [JsonConverter(typeof(JavaScriptDateTimeConverter))]，从序列化的结果可以看出来它们最终的表现 形式并不一样。
本文中所有的示例代码如下：
[c-sharp] view plaincopy
using System;  
using System.Collections.Generic;  
using System.Linq;  
using System.Text;  
using System.Web.Script.Serialization;  
using System.Runtime.Serialization.Json;  
using System.IO;  
using System.Runtime.Serialization;  
using Newtonsoft.Json;  
using Newtonsoft.Json.Linq;  
using Newtonsoft.Json.Converters;  
  
namespace JSONDemo  
{  
class Program  
{  
    static void Main(string[] args)  
    {  
        JavaScriptSerializerDemo();  
        DataContractJsonSerializerDemo();  
        JsonConvertDemo();  
        JsonConvertLinqDemo();  
        Console.ReadLine();  
    }  
  
    public static void JavaScriptSerializerDemo()  
    {  
        User user = new User { UserId = 1, UserName = "李刚", CreateDate = DateTime.Now.AddYears(-30),Birthday=DateTime.Now.AddYears(-50), Priority = Priority.Highest, Salary = 500000 };  
        //JavaScriptSerializer类在System.Web.Extensions.dll中，注意添加这个引用  
        JavaScriptSerializer serializer = new JavaScriptSerializer();  
        //JSON序列化  
        string result=serializer.Serialize(user);  
        Console.WriteLine("使用JavaScriptSerializer序列化后的结果：{0},长度：{1}", result, result.Length);  
        //JSON反序列化  
        user = serializer.Deserialize<User>(result);  
        Console.WriteLine("使用JavaScriptSerializer反序列化后的结果：UserId:{0},UserName:{1},CreateDate:{2},Priority:{3}", user.UserId, user.UserName, user.CreateDate, user.Priority);  
  
    }  
  
    public static void DataContractJsonSerializerDemo()  
    {  
        User user = new User { UserId = 1, UserName = "李刚", CreateDate = DateTime.Now.AddYears(-30), Birthday = DateTime.Now.AddYears(-50), Priority = Priority.AboveNormal, Salary = 50000 };  
        string result = string.Empty;  
        //DataContractJsonSerializer类在System.ServiceModel.Web.dll中，注意添加这个引用  
        DataContractJsonSerializer serializer = new DataContractJsonSerializer(typeof(User));  
          
        using (MemoryStream stream = new MemoryStream())  
        {  
            //JSON序列化  
            serializer.WriteObject(stream, user);  
            result = Encoding.UTF8.GetString(stream.ToArray());  
            Console.WriteLine("使用DataContractJsonSerializer序列化后的结果：{0},长度：{1}", result, result.Length);  
        }  
  
        //JSON反序列化  
        byte[] buffer = Encoding.UTF8.GetBytes(result);  
        using (MemoryStream stream = new MemoryStream(buffer))  
        {  
            user = serializer.ReadObject(stream) as User;  
            Console.WriteLine("使用DataContractJsonSerializer反序列化后的结果：UserId:{0},UserName:{1},CreateDate:{2},Priority:{3}", user.UserId, user.UserName, user.CreateDate, user.Priority);  
        }  
    }  
  
    public static void JsonConvertDemo()  
    {  
        User user = new User { UserId = 1, UserName = "李刚", CreateDate = DateTime.Now.AddYears(-30), Birthday = DateTime.Now.AddYears(-50), Priority = Priority.BelowNormal, Salary = 5000 };  
        //JsonConvert类在Newtonsoft.Json.Net35.dll中，注意到http://www.codeplex.com/json/下载这个dll并添加这个引用  
        //JSON序列化  
        string result = JsonConvert.SerializeObject(user);  
        Console.WriteLine("使用JsonConvert序列化后的结果：{0},长度：{1}", result, result.Length);  
        //JSON反序列化  
        user = JsonConvert.DeserializeObject<User>(result);  
        Console.WriteLine("使用JsonConvert反序列化后的结果：UserId:{0},UserName:{1},CreateDate:{2},Priority:{3}", user.UserId, user.UserName, user.CreateDate, user.Priority);  
    }  
  
    public static void JsonConvertLinqDemo()  
    {  
        User user = new User { UserId = 1, UserName = "周公", CreateDate = DateTime.Now.AddYears(-8), Birthday = DateTime.Now.AddYears(-32), Priority = Priority.Lowest, Salary = 500, Urls = new List<string> { "http://zhoufoxcn.blog.51cto.com", "http://blog.csdn.net/zhoufoxcn" } };  
        //JsonConvert类在Newtonsoft.Json.Net35.dll中，注意到http://www.codeplex.com/json/下载这个dll并添加这个引用  
        //JSON序列化  
        string result = JsonConvert.SerializeObject(user);  
        Console.WriteLine("使用JsonConvert序列化后的结果：{0},长度：{1}", result, result.Length);  
        //使用Linq to JSON  
        JObject jobject = JObject.Parse(result);  
        JToken token = jobject["Urls"];  
        List<string> urlList = new List<string>();  
        foreach (JToken t in token)  
        {  
            urlList.Add(t.ToString());  
        }  
        Console.Write("使用Linq to JSON反序列化后的结果：[");  
        for (int i = 0; i < urlList.Count - 1;i++ )  
        {  
            Console.Write(urlList[i] + ",");  
        }  
        Console.WriteLine(urlList[urlList.Count - 1] + "]");  
    }  
}  
  
[DataContract]  
public class User  
{  
    /// <summary>  
    /// 编号  
    /// </summary>  
    [DataMember]  
    public int UserId { get; set; }  
    /// <summary>  
    /// 用户名  
    /// </summary>  
    [DataMember]  
    public string UserName { get; set; }  
    /// <summary>  
    /// 创建时间  
    /// </summary>  
    [DataMember]  
    [JsonConverter(typeof(IsoDateTimeConverter))]  
    public DateTime CreateDate { get; set; }  
    /// <summary>  
    /// 生日  
    /// </summary>  
    [DataMember]  
    [JsonConverter(typeof(JavaScriptDateTimeConverter))]  
    public DateTime Birthday { get; set; }  
    /// <summary>  
    /// 相关URL  
    /// </summary>  
    [DataMember]  
    public List<string> Urls { get; set; }  
    /// <summary>  
    /// 薪水  
    /// </summary>  
    [ScriptIgnore]//使用JavaScriptSerializer序列化时不序列化此字段  
    [IgnoreDataMember]//使用DataContractJsonSerializer序列化时不序列化此字段  
    [JsonIgnore]//使用JsonConvert序列化时不序列化此字段  
    public int Salary { get; set; }  
    /// <summary>  
    /// 权利级别  
    /// </summary>  
    [DataMember]  
    public Priority Priority { get; set; }  
  
    public User()  
    {  
        Urls = new List<string>();  
    }  
}  
/// <summary>  
/// 权利级别  
/// </summary>  
public enum Priority:byte  
{  
    Lowest=0x1,  
    BelowNormal=0x2,  
    Normal=0x4,  
    AboveNormal=0x8,  
    Highest=0x16  
}  
}  

程序的运行结果如下：
[xhtml] view plaincopy
使 用JavaScriptSerializer序列化后的结果：{"UserId":1,"UserName":"李 刚","CreateDate":"//Date(353521211984)//","Birthday":" //Date(-277630788015)//","Urls":[],"Priority":22},长度：127  
使用JavaScriptSerializer反序列化后的结果：UserId:1,UserName:李刚,CreateDate:1981-3-15 16:20:11,Priority:Highest  
使 用DataContractJsonSerializer序列化后的结果： {"Birthday":"//Date(-277630787953+0800)//","CreateDate":" //Date(353521212046+0800)//","Priority":8,"Urls": [],"UserId":1,"UserName":"李刚"},长度：136  
使用DataContractJsonSerializer反序列化后的结果：UserId:1,UserName:李刚,CreateDate:1981-3-16 0:20:12,Priority:AboveNormal  
使 用JsonConvert序列化后的结果：{"UserId":1,"UserName":"李 刚","CreateDate":"1981-03-16T00:20:12.1875+08:00","Birthday":new Date(-277630787812),"Urls": [],"Priority":2},长度：132  
使用JsonConvert反序列化后的结果：UserId:1,UserName:李刚,CreateDate:1981-3-16 0:20:12,Priority:BelowNormal  
使 用JsonConvert序列化后的结果：{"UserId":1,"UserName":"周 公","CreateDate":"2003-03-16T00:20:12.40625+08:00","Birthday":new Date(290362812406),"Urls": ["http://zhoufoxcn.blog.51cto.com","http://blog.csdn.net /zhoufoxcn"],"Priority":1},长度：198  
使用Linq to JSON反序列化后的结果：["http://zhoufoxcn.blog.51cto.com","http://blog.csdn.net/zhoufoxcn"]  

总结：通过上面的例子大家可以看出Newtonsoft类库提供的JSON序列化和反序列的方式更加灵活，在实际开发中周公也一直使用Newtonsoft作为JSON序列化和反序列化的不二选择。
周公

来源： <http://blog.csdn.net/zhoufoxcn/article/details/6254657>
 
