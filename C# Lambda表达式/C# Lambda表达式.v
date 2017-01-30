C# Lambda表达式

Lambda表达式
"Lambda表达式"是一个匿名函数，是一种高效的类似于函数式编程的表达式，Lambda简化了开发中需要编写的代码量。它可以包含表达式和语 句，并且可用于创建委托或表达式目录树类型，支持带有可绑定到委托或表达式树的输入参数的内联表达式。所有Lambda表达式都使用Lambda运算 符=>，该运算符读作"goes to"。Lambda运算符的左边是输入参数(如果有)，右边是表达式或语句块。Lambda表达式x => x * x读作"x goes to x times x"。可以将此表达式分配给委托类型，如下所示：
delegate int del(int i);  
del myDelegate = x => x * x;  
int j = myDelegate(5); //j = 25 
Lambda表达式Lambda表达式是由.NET 2.0演化而来的，也是LINQ的基础，熟练地掌握Lambda表达式能够快速地上手LINQ应用开发。
Lambda表达式在一定程度上就是匿名方法的另一种表现形式。为了方便对Lambda表达式的解释，首先需要创建一个People类，示例代码如下。
public class People  
{  
    public int age { get; set; }                //设置属性  
    public string name { get; set; }            //设置属性  
    public People(int age,string name)      //设置属性(构造函数构造)  
    {  
        this.age = age;                 //初始化属性值age  
        this.name = name;               //初始化属性值name  
    }  
} 
上述代码定义了一个People类，并包含一个默认的构造函数能够为People对象进行年龄和名字的初始化。在应用程序设计中，很多情况下需要创 建对象的集合，创建对象的集合有利于对对象进行搜索操作和排序等操作，以便在集合中筛选相应的对象。使用List进行泛型编程，可以创建一个对象的集合， 示例代码如下。
List<People> people = new List<People>();   //创建泛型对象  
People p1 = new People(21,"guojing");       //创建一个对象  
People p2 = new People(21, "wujunmin");     //创建一个对象  
People p3 = new People(20, "muqing");       //创建一个对象  
People p4 = new People(23, "lupan");        //创建一个对象  
people.Add(p1);                     //添加一个对象  
people.Add(p2);                     //添加一个对象  
people.Add(p3);                     //添加一个对象  
people.Add(p4);                     //添加一个对象 
上述代码创建了4个对象，这4个对象分别初始化了年龄和名字，并添加到List列表中。当应用程序需要对列表中的对象进行筛选时，例如需要筛选年龄大于20岁的人，就需要从列表中筛选，示例代码如下。
//匿名方法  
IEnumerable<People> results = people.Where
(delegate(People p) { return p.age > 20; }); 
上述代码通过使用IEnumerable接口创建了一个result集合，并且该集合中填充的是年龄大于20的People对象。细心的读者能够发现在这里使用了一个匿名方法进行筛选，因为该方法没有名称，通过使用People类对象的age字段进行筛选。
虽然上述代码中执行了筛选操作，但是，使用匿名方法往往不太容易理解和阅读，而Lambda表达式则更加容易理解和阅读，示例代码如下。
IEnumerable<People> results = people.Where(People => People.age > 20); 
上述代码同样返回了一个People对象的集合给变量results，但是，其编写的方法更加容易阅读，从这里可以看出Lambda表达式在编写的格式上和匿名方法非常相似。其实，当编译器开始编译并运行时，Lambda表达式最终也表现为匿名方法。
使用匿名方法并不是创建了没有名称的方法，实际上编译器会创建一个方法，这个方法对于开发人员来说是不可见的，该方法会将People类的对象中符 合p.age>20的对象返回并填充到集合中。相同地，使用Lambda表达式，当编译器编译时，Lambda表达式同样会被编译成一个匿名方法进 行相应的操作，但是与匿名方法相比，Lambda表达式更容易阅读，Lambda表达式的格式如下。
(参数列表)=>表达式或语句块 
上述代码中，参数列表就是People类，表达式或语句块就是People.age>20，使用Lambda表达式能够让人很容易地理解该语 句究竟是如何执行的，虽然匿名方法提供了同样的功能，却不容易被理解。相比之下，People => People.age > 20却能够很好地理解为"返回一个年纪大于20的人"。其实，Lambda表达式并没有什么高深的技术，Lambda表达式可以看作是匿名方法的另一种表 现形式。Lambda表达式经过反编译后，与匿名方法并没有什么区别。
比较Lambda表达式和匿名方法，在匿名方法中，"("、")"内是方法的参数的集合，这就对应了Lambda表达式中的"(参数列表)"，而匿 名方法中"{"、"}"内是方法的语句块，这对应了Lambda表达式中"=>"符号右边的表达式或语句块项。Lambda表达式也包含一些基本的 格式，这些基本格式如下。
Lambda表达式可以有多个参数、一个参数，或者没有参数。其参数类型可以隐式或者显式。示例代码如下：
(x, y) => x * y         //多参数，隐式类型=> 表达式  
x => x * 5              //单参数， 隐式类型=>表达式  
x => { return x * 5; }      //单参数，隐式类型=>语句块  
(int x) => x * 5            //单参数，显式类型=>表达式  
(int x) => { return x * 5; }      //单参数，显式类型=>语句块  
() => Console.WriteLine()   //无参数 
上述格式都是Lambda表达式的合法格式，在编写Lambda表达式时，可以忽略参数的类型，因为编译器能够根据上下文直接推断参数的类型，示例代码如下。
(x, y) => x + y         //多参数，隐式类型=> 表达式 
Lambda表达式的主体可以是表达式也可以是语句块，这样就节约了代码的编写。

来源： <http://www.cnblogs.com/kingmoon/archive/2011/05/03/2035696.html>
 
