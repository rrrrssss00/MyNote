第一种方法：在tomcat中的conf目录中，在server.xml中的，<host/>节点中添加： 
<Context path="/hello"
docBase="D:\eclipse3.2.2forwebtools\workspace\hello\WebRoot" debug="0"
privileged="true">
</Context> 
至于Context 节点属性，可详细见相关文档。 

第二种方法：将web项目文件件拷贝到webapps 目录中。 
第三种方法：很灵活，在conf目录中，新建
Catalina（注意大小写）＼localhost目录，在该目录中新建一个xml文件，名字可以随意取，只要和当前文件中的文件名不重复就行了，该xml文件的内容为：
<Context path="/hello"
docBase="D:\eclipse3.2.2forwebtools\workspace\hello\WebRoot" debug="0"
privileged="true">
</Context>
来源： http://zhidao.baidu.com/link?url=kgNnUzCCWtY1BVVeigd3r-Gji0sW8ZS7_OcJDEjtgOpALGwmaW4U-34dfKly4vrY-zvsDRZS7z7D7Pls34NFV_
