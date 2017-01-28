1：需要解压一个Tomcat，然后在Eclipse的Server页里面New，并指定解压目录，之后项目在Run的时候，即会让用户选择在哪个Server下Run

2：定义完Tomcat的Server后，可以在项目-properties-Target Runtimes下指定該Sever，这样可以避免一些类似“The superclass "javax.servlet.http.HttpServlet" was not found on the Java Build Path”的错误
