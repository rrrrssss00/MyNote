在做DevExpress编译的时候，经常遇到工程之间引用internal对象的错误，找了一下，发现是assembly: InternalsVisibleTo没有修改造成的，基本方法和概念如下：
 
 
使用InternalsVisibleTo给assembly添加“友元assembly”
 
C#的internal关键字可以使标记的方法，字段或者属性等等只能在当前assembly内部使用，那么如果其他的assembly需要使用这个internal的方法的时候怎么办呢？.NET提供了一种类似于C++中的友元类的方式来完成这个功能，那就是使用InternalsVisibleTo。
 
这种情况常见于做测试的时候，需要另外一个项目来测试项目中的internal方法所标记的功能，所以有了InternalsVisibleTo，我们就不用为了做单元测试而把一个本不该公开的方法改为public了.
 
使用InternalsVisibleTo还有一些需要注意的地方，特别是PublicKey不太容易弄的明白，下面先来说说这个InternalsVisibleTo该怎么使用：
 
先来说明一下前提：Project1是功能项目，Project1.Test (assembly name: Project1.Test.dll)是为做Project1的测试工程。
 
1. 打开Project1的Assembly.cs文件，在文件的末尾加上这样一句话：
 
1 [assembly: InternalsVisibleTo("Project1.Test, PublicKey=******")]
 
其中PublicKey=******应该替换成Project1.Test.dll的public key，至于如何获取PublicKey，请看文章末尾的部分.
 
2. 确认namespace: System.Runtime.CompilerServices 添加到了Assembly.cs的namespace引用中，因为InternalsVisibleTo位于命名空间System.Runtime.CompilerService中。
 
3. 如何获取PublicKey？
 
   在命令行下，使用sn -Tp Project1.Test.dll就可以看到PublicKey和PublicKeyToken
 
4. 如果Project1是个strong-named的项目，那么InternalsVisibleTo必须指定PublicKey，所以Project1.Test也必须使用强签名才能正确使用InternalsVisibleTo, 不然编译会出错，如果Project1没有使用强签名，那么Project1.Test也不必使用强签名，而且在使用InternalsVisibleTo的时候只需要程序集的名字就可以了，不需要设置PuklicKey。
 
此外，在DevExpress提供的编译脚本里，包含了这样一个程序，用于更改AssemblyInfo.cs文件里assembly: InternalsVisibleTo里的PuklicKey，代码见附件
