JDBC连接Oracle数据库时出现的ORA-12505错误及解决办法

Posted on 2007-12-20 16:42 itspy 阅读(17672) 评论(22)  编辑  收藏 所属分类: 其它技术  

Oracle 
问题描述：
今天使用jdbc连接oracle 10.2.0.1.0 数据库的时候出现了下列错误：
Connection refused(DESCRIPTION=(TMP=)(VSNNUM=153093120)(ERR=12505)(ERROR_STACK=(ERROR=(CODE=12505)(EMFI=4))))
而直接通过plsql可以正常连接数据库,或者可以通过sqlplus 连接数据库
经过debug和查找相关的资料发现问题原因如下：
jdbc连接数据库的时候，需要使用数据库的sid_name，而不是数据库的services_name
而使用plsql连接数据库的时候，只需要数据库的services_name即可，所以修改连接字符串中的services_name 为sid_name
附：
察看数据库中当前的sid:
SQL> select INSTANCE_NAME from v$instance;
INSTANCE_NAME
----------------
hasl

来源： <http://www.blogjava.net/itspy/archive/2007/12/20/169072.html>
 

