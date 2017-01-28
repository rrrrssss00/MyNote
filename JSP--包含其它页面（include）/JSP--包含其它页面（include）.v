两种方法包含其它页面，两种方法貌似是一样的？

<%@ include file="relative url" %>   （JSP指令）
<jsp:include page="relative URL" flush="true" />  （JSP动作元素）下面是动作元素的一个实例
　前面已经介绍过include指令，它是在JSP文件被转换成Servlet的时候引入文件，而这里的jsp:include动作不同，插入文件的时间是在页面被请求的时候。 
 
以下是include动作相关的属性列表。
 
属性 	描述 
page	包含在页面中的相对URL地址。
flush	布尔属性，定义在包含资源前是否刷新缓存区。
 
实例

 
以下我们定义了两个文件date.jsp和main.jsp，代码如下所示：
 
date.jsp文件代码：
 
<p>
   Today's date: <%= (new java.util.Date()).toLocaleString()%>
</p>
 
main.jsp文件代码：
 
<html>
<head>
<title>The include Action Example</title>
</head>
<body>
<center>
<h2>The include action Example</h2>
<jsp:include page="date.jsp" flush="true" />
</center>
</body>
</html>
 
现在将以上两个文件放在服务器的根目录下，访问main.jsp文件。显示结果如下：
 
The include action Example
Today's date: 12-Sep-2013 14:54:22

来源： <http://www.w3cschool.cc/jsp/jsp-actions.html>
 

