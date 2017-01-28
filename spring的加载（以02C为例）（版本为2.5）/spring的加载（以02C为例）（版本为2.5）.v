Spring 提供ServletContextListener 的一个实现类ContextLoaderListener ，该类可以作为listener 使用，它会在创建时自动查找WEB-INF/ 下的applicationContext.xml 文件。因此，如果只有一个配置文件，并且文件名为applicationContext.xml ，则只需在web.xml文件中增加如下代码即可:
<listener>
<listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
</listener>


如果有多个配置文件需要载入，则考虑使用<context-para>元素来确定配置文件的文件名。由于ContextLoaderListener加载时，会查找名为contextConfigLocation的参数。因此，配置context-param时参数名字应该是contextConfigLocation。
带多个配置文件的web.xml 文件如下:
<1-- XML 文件的文件头二〉
<web-app>
<!一确定多个配置文件>
<context-param>
<1-- 参数名为contextConfigLocation…〉
<param-name>contextConfigLocation</param-name>
<!一多个配置文件之间以，隔开二〉
<param-value>/WEB-INF/daoContext.xml,/WEB-INF/applicationContext.xml</param-value>
</context-param>
<!-- 采用listener创建ApplicationContext 实例-->
<listener>
<listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
</listener>
</web-app>


