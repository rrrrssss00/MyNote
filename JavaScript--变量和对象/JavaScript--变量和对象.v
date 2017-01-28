JavaScript--变量和对象
声明变量类型

当您声明新变量时，可以使用关键词 "new" 来声明其类型：
var carname=new String;
var x=      new Number;
var y=      new Boolean;
var cars=   new Array;
var person= new Object;
局部变量会在函数运行以后被删除。
全局变量会在页面关闭后被删除。
在 HTML 中, 所有全局变量都会成为 window 变量，可以使用window.变量名访问

向未声明的 JavaScript 变量分配值

如果您把值赋给尚未声明的变量，该变量将被自动作为全局变量声明。
这条语句：
carname="Volvo";

JavaScript 对象

对象由花括号分隔。在括号内部，对象的属性以名称和值对的形式 (name : value) 来定义。属性由逗号分隔：
var person={firstname:"John", lastname:"Doe", id:5566};
上面例子中的对象 (person) 有三个属性：firstname、lastname 以及 id。
空格和折行无关紧要。声明可横跨多行：
var person={
firstname : "John",
lastname  : "Doe",
id        :  5566
};
对象属性有两种寻址方式：
实例

name=person.lastname;
name=person["lastname"];


创建名为 "person" 的对象，并为其添加了四个属性：
实例

person=new Object();
person.firstname="John";
person.lastname="Doe";
person.age=50;
person.eyecolor="blue"; 

