1：编译完成后，生成的是.class,需要用到File-》Export来打成JAR包，在打JAR包时，需要选定Main Class
然后，在命令行中使用 java -jar xxx.jar来运行

2：JSP引用.class文件时，在页首使用
<jsp:directive.page import="common.util.User"/>即可引用该Class
<jsp:directive.page import="common.util.*"/>即可将该命名空间的所有Class文件都包括进来 
如果是引用JAR包，也可以在Explorer里点开该包，查看里面的所有class，使用相同的方法即可引用 
