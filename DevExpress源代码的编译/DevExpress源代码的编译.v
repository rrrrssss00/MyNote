可以用VS打开一个个编译，只要注意编译顺序的问题即可，具体的编译顺序可以用VS打开后，看项目的引用DLL，先把引用的DLL编译掉就行
 
编译前，需要在DevExpress.Key文件夹下生成一个StrongKey.snk文件，用vs提供的CMD工具，里边调用sn.exe -p xxxx.snk即可
 
编译中，会遇到很多internal引用的错误，这里需要使用官方提供的编译脚本里的PatchInternalVisibleTo.exe来更改各项目里AssemblyInfo.cs文件中的命名，总体原则是，打开AssemblyInfo.cs文件，看其中有没有[assembly: InternalsVisibleTo(AssemblyInfo.SRAssemblyReports + ", PublicKey=00240000……]，如果有，就使用PatchInternalVisibleTo.exe把PublicKey后边的串换成StrongKey.snk对应的串，具体的原理和方法见另一篇文章：《使用InternalsVisibleTo给assembly添加“友元assembly”》
