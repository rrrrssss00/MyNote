基础知识（教程）：http://www.runoob.com/servlet/servlet-tutorial.html

声明：在web.xml里定义servlet，包括servlet的name,class,mapping等
           以02C网站为例，用下边的代码，定义了一个叫ImageCheckServlet的Servlet，然后处理所有后缀为imager的请求
           
<servlet>
   <servlet-name>ImageCheckServlet</servlet-name>
   <servlet-class>org.hdht.commonapp.imager.ImagerServlet</servlet-class>
</servlet>
<servlet-mapping>
   <servlet-name>ImageCheckServlet</servlet-name>
   <url-pattern>*.imager</url-pattern>
</servlet-mapping>

这个Servlet使用声明里的ImagerServlet类来处理，这个类里解析参数，并做出相应处理
详情参考教程



