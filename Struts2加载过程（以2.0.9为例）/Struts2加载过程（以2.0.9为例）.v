以struts2.0.9为例，02C共享服务系统中的Struts加载过程（相关Java包的下载和导入参考引一篇《Struts2入门》 ）：

首先在web\WEB-INF文件夹中，web.xml文件为整个网站的配置文件，在里边加入了以下内容，对所有URL调用加载struts处理

 <filter>  
    <filter-name>struts</filter-name>  
    <filter-class>org.apache.struts2.dispatcher.FilterDispatcher</filter-class>  
  </filter>  
  <filter-mapping>  
    <filter-name>struts</filter-name>  
    <url-pattern>/*</url-pattern>  
  </filter-mapping>

 */
然后，在src目录下建立struts.xml，那样部署的时候会自动发布到WEB-INF/classes目录下，里面包含了所有要调用的action。以02C项目中，里面还可以引用其它配置文件，大致格式为
<?xml version="1.0" encoding="UTF-8" ?>  
<!DOCTYPE struts PUBLIC  
    "-//Apache Software Foundation//DTD Struts Configuration 2.3//EN"  
    "http://struts.apache.org/dtds/struts-2.3.dtd">  
  
  
    <struts>  
        <include file ="struts/constant.xml" />
	
        <package name="struts2" extends="struts-default">  
            <action name="main" class="org.hdht.system.uim.action.LoginController" method="main">  
                <result name="success">/main.jsp</result>  
            </action>  
        </package>  
    </struts> 

那么，当用户在URL中建入http://<serverip>:<port>/<webbase>/main.do时，网站就会根据这个action,调用org.hdht.system.uim.action.LoginController这个Java类中的main方法，返回一个值后，根据这个返回值(比如说返回值为"success")跳转到下面<result>中对应的URL


struts相关的配置文件：除了上面提到的web.xml以及struts.xml以外，还有以下配置文件：
1：struts-default.xml    这个文件位于 struts2-core-2.0.9.jar包中，定义了struts2一些核心bean和拦截器，它会自动包含(included)到struts.xml文件中(实质是通过<package  extends="struts-default">)
2：default.properties 文件：这个文件位于struts2-core-2.0.9.jar包中的org.apache.struts2文件夹中，定义了Struts框架中使用到的很多属性。用户也可以生成struts.properties，放在WEB-INF/classes下，修改其中的某些属性


备注：
1：struts的action后缀名修改：struts2的默认后缀名为action,即：其识别的URL格式为http://<serverip>:<port>/<webbase>/main.action，这个后缀名可以通过配置修改，其默认配置是在default.properties文件中的，用户可以在struts.properties，或struts.xml文件中进行修改，但注意这两类文件中的格式不太一样
struts.properties   格式：   struts.action.extension = action
struts.xml    格式：             
<struts>
   <constant name="struts.action.extension" value="do,htm">
</struts>
这样，用户就可以通过使用  http://<serverip>:<port>/<webbase>/main.do  或   http://<serverip>:<port>/<webbase>/main.htm    来进行跳转，02C网站就是这么处理的

