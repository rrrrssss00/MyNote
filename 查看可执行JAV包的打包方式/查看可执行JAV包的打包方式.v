在Eclipse中打包JAVA项目（右键菜单Export）时，可以选择包含的内容以及执行的主类（Main-Class）(需要包含Main方法，在选项占)，直接使用java -jar命令，不加其它参数的情况下运行这个JAR包，则直接执行这个主类，（java -jar xxxx.jar）

打包之后，怎么查看打包时的参数呢？
可以直接用压缩软件打开这个JAR包，查看其中包含的CLASS文件

另外，可以用记事本打开压缩包中META-INF文件夹中的MANIFEST.MF文件，Main-Class就记录在其中
