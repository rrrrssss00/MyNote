一.WebContextLoaderListener 监听类
它能捕捉到服务器的启动和停止，在启动和停止触发里面的方法做相应的操作!
它必须在web.xml 中配置才能使用，是配置监听类的
二.下面是搜集的一些listener方面的知识
简例一
监听用户上线与退出，显示在线用户

1、登陆页面 Login.jsp

<%@page pageEncoding="gb2312" contentType="text/html; charset=gb2312" %>
<%
session=request.getSession(false);
if(session!=null)session.invalidate();
%>
<html>
<head><title></title></head>
<body>
<form action="isOnline.jsp" method="post">
用户名：<input type="text" name="uName"/>
<input type="submit" value="上线">
</form>
</body>
</html>

2、控制页面（只是为了说明监听器问题，所以简单了点...） isOnline.jsp

<%@page pageEncoding="gb2312" contentType="text/html; charset=gb2312" %>
<html>
<head><title></title></head>
<body>
<%
session=request.getSession();
session.setAttribute("userName",request.getParameter("uName"));
response.sendRedirect("showOnline.jsp");
%>
</body>
</html>


3、显示页面 showOnline.jsp

<%@page pageEncoding="gb2312" contentType="text/html; charset=gb2312" import="java.util.ArrayList" %>
<html>
<head><title></title></head>
<body>
<%
ArrayList showList=(ArrayList)(getServletContext().getAttribute("list"));
out.print("在线人数 "+showList.size()+"<br>");
for(int i=0;i<showList.size();i++){
out.print(showList.get(i)+"在线"+"<br>");
}
%>
<br>
<a href="Login.jsp">退出</a>
</body>
</html>

4、配置页面 web.xml

<?xml version="1.0" encoding="gb2312"?>
<!DOCTYPE web-app
    PUBLIC "-//Sun Microsystems, Inc.//DTD Web Application 2.3//EN"
    "http://java.sun.com/dtd/web-app_2_3.dtd">
<web-app>
<listener>
    <listener-class>org.xiosu.listener.onlineListener</listener-class>
</listener>
</web-app>

5、监听器 onlineListener.java

package org.xiosu.listener;

import java.util.ArrayList;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpSessionAttributeListener;
import javax.servlet.http.HttpSessionBindingEvent;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

public class onlineListener implements HttpSessionListener,
HttpSessionAttributeListener {
// 参数
ServletContext sc;
ArrayList list = new ArrayList();
// 新建一个session时触发此操作
public void sessionCreated(HttpSessionEvent se) {
sc=se.getSession().getServletContext();
System.out.println("新建一个session");
}
// 销毁一个session时触发此操作
public void sessionDestroyed(HttpSessionEvent se) {
System.out.println("销毁一个session");
if (!list.isEmpty()) {
   list.remove((String) se.getSession().getAttribute("userName"));
   sc.setAttribute("list", list);
}
}
// 在session中添加对象时触发此操作，在list中添加一个对象
public void attributeAdded(HttpSessionBindingEvent sbe) {
list.add((String) sbe.getValue());
sc.setAttribute("list", list);
}
// 修改、删除session中添加对象时触发此操作
public void attributeRemoved(HttpSessionBindingEvent arg0) {
}
public void attributeReplaced(HttpSessionBindingEvent arg0) {
}
}


说明：本例只为简单介绍监听器，并未进行安全方面设置。

监听器也叫Listener，是Servlet的监听器，它可以监听客户端的请求、服务端的操作等。通过监听器，可以自动激发一些操作，比如监听在线的用户的数量。当增加一个HttpSession时，就激发sessionCreated(HttpSessionEvent  se)方法，这样
就可以给在线人数加1。常用的监听接口有以下几个：
ServletContextAttributeListener监听对ServletContext属性的操作，比如增加、删除、修改属性。
ServletContextListener监听ServletContext。当创建ServletContext时，激发 contextInitialized(ServletContextEvent   sce)方法；当销毁ServletContext时，激发contextDestroyed(ServletContextEvent   sce)方法。
HttpSessionListener监听HttpSession的操作。当创建一个Session时，激发session   Created(HttpSessionEvent  se)方法；当销毁一个Session时，激发sessionDestroyed   (HttpSessionEvent   se)方法。
HttpSessionAttributeListener监听HttpSession中的属性的操作。当在Session增加一个属性时，激发 attributeAdded(HttpSessionBindingEvent   se)   方法；当在Session删除一个属性时，激发attributeRemoved(HttpSessionBindingEvent   se)方法；当在Session属性被重新设置时，激发attributeReplaced(HttpSessionBindingEvent   se)   方法。
example:随服务器启动
＜web-app＞

      com.tb.listener.CountStartListener


package com.tb.listener;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.http.HttpServlet;
import com.tb.timertask.DoCountTask;
public class CountStartListener extends HttpServlet implements ServletContextListener
{
private static final long serialVersionUID = 1824920962239905170L;
public CountStartListener()
{
   // TODO Auto-generated constructor stub
}
public void contextDestroyed(ServletContextEvent arg0)
{
   // TODO Auto-generated method stub
}
   public void contextInitialized(ServletContextEvent arg0)
{   
   DoCountTask.dotask();
}
}

概述：
Servlet监听器用于监听一些重要事件的发生，监听器对象可以在事情发生前、发生后可以做一些必要的处理。
接口：
目前Servlet2.4和JSP2.0总共有8个监听器接口和6个Event类，其中HttpSessionAttributeListener与
HttpSessionBindingListener 皆使用HttpSessionBindingEvent;HttpSessionListener和 HttpSessionActivationListener则都使用HttpSessionEvent;其余Listener对应的Event如下所示：
 
Listener接口
Event类
ServletContextListener
ServletContextEvent
ServletContextAttributeListener
ServletContextAttributeEvent
HttpSessionListener
HttpSessionEvent
HttpSessionActivationListener
HttpSessionAttributeListener
HttpSessionBindingEvent
HttpSessionBindingListener
ServletRequestListener
ServletRequestEvent
ServletRequestAttributeListener
ServletRequestAttributeEvent
分别介绍：
一 ServletContext相关监听接口
补充知识：
通过ServletContext 的实例可以存取应用程序的全局对象以及初始化阶段的变量。
在JSP文件中，application 是 ServletContext 的实例，由JSP容器默认创建。Servlet 中调用 getServletContext()方法得到 ServletContext 的实例。
注意：
全局对象即Application范围对象，初始化阶段的变量指在web.xml中，经由<context-param>元素所设定的变量，它的范围也是Application范围，例如：
<context-param>
<param-name>Name</param-name>
<param-value>browser</param-value>
</context-param>
当容器启动时，会建立一个Application范围的对象，若要在JSP网页中取得此变量时：
String name = (String)application.getInitParameter("Name");
或者使用EL时：
${initPara.name}
若是在Servlet中，取得Name的值方法：
String name = (String)ServletContext.getInitParameter("Name");
1.ServletContextListener：
用于监听WEB 应用启动和销毁的事件，监听器类需要实现javax.servlet.ServletContextListener 接口。
ServletContextListener 是 ServletContext 的监听者，如果 ServletContext 发生变化，如服务器启动时 ServletContext 被创建，服务器关闭时 ServletContext 将要被销毁。
ServletContextListener接口的方法：
void contextInitialized(ServletContextEvent sce)
通知正在接受的对象，应用程序已经被加载及初始化。
void contextDestroyed(ServletContextEvent sce)
通知正在接受的对象，应用程序已经被载出。
ServletContextEvent中的方法：
ServletContext getServletContext()
取得ServletContext对象
2.ServletContextAttributeListener：用于监听WEB应用属性改变的事件，包括：增加属性、删除属性、修改属性，监听器类需要实现javax.servlet.ServletContextAttributeListener接口。
ServletContextAttributeListener接口方法：
void attributeAdded(ServletContextAttributeEvent scab)
若有对象加入Application的范围，通知正在收听的对象
void attributeRemoved(ServletContextAttributeEvent scab)
若有对象从Application的范围移除，通知正在收听的对象
void attributeReplaced(ServletContextAttributeEvent scab)
若在Application的范围中，有对象取代另一个对象时，通知正在收听的对象
ServletContextAttributeEvent中的方法：
java.lang.String getName()
回传属性的名称
java.lang.Object getValue()
回传属性的值
二、HttpSession相关监听接口
1.HttpSessionBindingListener接口
注意：HttpSessionBindingListener接口是唯一不需要再web.xml中设定的Listener
当我们的类实现了HttpSessionBindingListener接口后，只要对象加入 Session范围（即调用HttpSession对象的setAttribute方法的时候）或从Session范围中移出（即调用HttpSession对象的 removeAttribute方法的时候或Session Time out的时候）时，容器分别会自动调用下列两个方法：
void valueBound(HttpSessionBindingEvent event)
void valueUnbound(HttpSessionBindingEvent event)
思考：如何实现记录网站的客户登录日志， 统计在线人数？
2.HttpSessionAttributeListener接口
HttpSessionAttributeListener监听HttpSession中的属性的操作。
当在Session增加一个属性时，激发attributeAdded(HttpSessionBindingEvent se) 方法；当在Session删除一个属性时，激发attributeRemoved(HttpSessionBindingEvent se)方法；当在Session属性被重新设置时，激发attributeReplaced(HttpSessionBindingEvent se) 方法。这和ServletContextAttributeListener比较类似。
3.HttpSessionListener接口
HttpSessionListener监听 HttpSession的操作。当创建一个Session时，激发session Created(HttpSessionEvent se)方法；当销毁一个Session时，激发sessionDestroyed (HttpSessionEvent se)方法。
4.HttpSessionActivationListener接口
主要用于同一个Session转移至不同的JVM的情形。
四、ServletRequest监听接口
1.ServletRequestListener接口
和ServletContextListener接口类似的，这里由ServletContext改为ServletRequest
2.ServletRequestAttributeListener接口
和ServletContextListener接口类似的，这里由ServletContext改为ServletRequest
有的listener可用于统计网站在线人数及访问量。 如下：
服务器启动时（实现ServletContextListener监听器contextInitialized方法），读取数据库，并将其用一个计数变量保存在application范围内
session创建时（实现HttpSessionListener监听器sessionCreated方法），读取计数变量加1并重新保存
服务器关闭时（实现ServletContextListener监听器contextDestroyed方法），更新数据库

转自： http://www.blogjava.net/wx886104/archive/2010/06/01/322419.html
       http://hht83.blog.163.com/blog/static/44037112008324232278/

来源： http://blog.csdn.net/java_pengjin/article/details/6760175
