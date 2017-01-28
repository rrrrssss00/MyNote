Java数据库访问——
1、加载JDBC驱动：
  加载JDBC驱动，并将其注册到DriverManager中，下面是一些主流数据库的JDBC驱动加裁注册的代码:    
  //Oracle8/8i/9iO数据库(thin模式)    
  Class.forName("oracle.jdbc.driver.OracleDriver").newInstance();    
  //Sql Server7.0/2000数据库    
  Class.forName("com.microsoft.jdbc.sqlserver.SQLServerDriver").newInstance();    
  //DB2数据库    
  Class.froName("com.ibm.db2.jdbc.app.DB2Driver").newInstance();    
  //Informix数据库    
  Class.forName("com.informix.jdbc.IfxDriver").newInstance();    
  //Sybase数据库    
  Class.forName("com.sybase.jdbc.SybDriver").newInstance();    
  //MySQL数据库    
  Class.forName("com.mysql.jdbc.Driver").newInstance();    
  //PostgreSQL数据库    
  Class.forNaem("org.postgresql.Driver").newInstance(); 
2、建立数据库连接：
  //Oracle8/8i/9i数据库(thin模式)    
  String url="jdbc:oracle:thin:@localhost:1521:orcl";    
  String user="scott";    
  String password="tiger";    
  Connection conn=DriverManager.getConnection(url,user,password);    
     
  //Sql Server7.0/2000数据库    
  String url="jdbc:microsoft:sqlserver://localhost:1433;DatabaseName=pubs";    
  String user="sa";    
  String password="";    
  Connection conn=DriverManager.getConnection(url,user,password);    
     
  //DB2数据库    
  String url="jdbc:db2://localhost:5000/sample";    
  String user="amdin"    
  String password=-"";    
  Connection conn=DriverManager.getConnection(url,user,password);    
     
  //Informix数据库    
  String url="jdbc:informix-sqli://localhost:1533/testDB:INFORMIXSERVER=myserver;user=testuser;password=testpassword";    
  Connection conn=DriverManager.getConnection(url);    
     
  //Sybase数据库    
  String url="jdbc:sybase:Tds:localhost:5007/tsdata";    
  Properties sysProps=System.getProperties();    
  SysProps.put("user","userid");    
  SysProps.put("password","user_password");    
  Connection conn=DriverManager.getConnection(url,SysProps);    
     
  //MySQL数据库    
  String url="jdbc:mysql://localhost:3306/testDB?user=root&password=root&useUnicode=true&characterEncoding=gb2312";    
  Connection conn=DriverManager.getConnection(url);    
     
  //PostgreSQL数据库    
  String url="jdbc:postgresql://localhost/testDB";    
  String user="myuser";    
  String password="mypassword";    
  Connection conn=DriverManager.getConnection(url,user,password); 
3、建立Statement对象或PreparedStatement对象：
  1、执行静态SQL语句。通常通过Statement实例实现。   
      2、执行动态SQL语句。通常通过PreparedStatement实例实现。   
      3、执行数据库存储过程。通常通过CallableStatement实例实现。 
//建立Statement对象    
  Statement stmt=conn.createStatement();    
  //建立ProparedStatement对象    
  String sql="select * from user where userName=? and password=?";    
  PreparedStatement pstmt=Conn.prepareStatement(sql);    
  pstmt.setString(1,"admin");    
  pstmt.setString(2,"liubin"); 
4、执行sql语句：
String sql="select * from users";    
  ResultSet rs=stmt.executeQuery(sql);    
  //执行动态SQL查询    
  ResultSet rs=pstmt.executeQuery();    
  //执行insert update delete等语句，先定义sql    
  stmt.executeUpdate(sql);  
5、访问结果记录集ResultSet对象。
while(rs.next)    
  {    
  out.println("你的第一个字段内容为："+rs.getString());    
  out.println("你的第二个字段内容为："+rs.getString(2));    
  }  
 6、依次将ResultSet、Statement、PreparedStatement、Connection对象关闭，释放所占用的资源：
rs.close();    
  stmt.clost();    
  pstmt.close();    
  con.close(); 
7、其他数据库连接：
MySQL：       
    String Driver="com.mysql.jdbc.Driver";    //驱动程序    
    String URL="jdbc:mysql://localhost:3306/db_name";    //连接的URL,db_name为数据库名       
    String Username="username";    //用户名    
    String Password="password";    //密码    
    Class.forName(Driver).new Instance();    
    Connection con=DriverManager.getConnection(URL,Username,Password);    
Microsoft SQL Server 2.0驱动(3个jar的那个):    
    String Driver="com.microsoft.jdbc.sqlserver.SQLServerDriver";    //连接SQL数据库的方法    
    String URL="jdbc:microsoft:sqlserver://localhost:1433;DatabaseName=db_name";    //db_name为数据库名    
    String Username="username";    //用户名    
    String Password="password";    //密码    
    Class.forName(Driver).new Instance();    //加载数据可驱动    
    Connection con=DriverManager.getConnection(URL,UserName,Password);    //    
Microsoft SQL Server 3.0驱动(1个jar的那个): // 老紫竹完善    
    String Driver="com.microsoft.sqlserver.jdbc.SQLServerDriver";    //连接SQL数据库的方法    
    String URL="jdbc:microsoft:sqlserver://localhost:1433;DatabaseName=db_name";    //db_name为数据库名    
    String Username="username";    //用户名    
    String Password="password";    //密码    
    Class.forName(Driver).new Instance();    //加载数据可驱动    
    Connection con=DriverManager.getConnection(URL,UserName,Password);    //    
Sysbase:    
    String Driver="com.sybase.jdbc.SybDriver";    //驱动程序    
    String URL="jdbc:Sysbase://localhost:5007/db_name";    //db_name为数据可名    
    String Username="username";    //用户名    
    String Password="password";    //密码    
    Class.forName(Driver).newInstance();       
    Connection con=DriverManager.getConnection(URL,Username,Password);    
Oracle(用thin模式):    
    String Driver="oracle.jdbc.driver.OracleDriver";    //连接数据库的方法    
    String URL="jdbc:oracle:thin:@loaclhost:1521:orcl";    //orcl为数据库的SID    
    String Username="username";    //用户名    
    String Password="password";    //密码    
    Class.forName(Driver).newInstance();    //加载数据库驱动    
    Connection con=DriverManager.getConnection(URL,Username,Password);       
PostgreSQL:    
    String Driver="org.postgresql.Driver";    //连接数据库的方法    
    String URL="jdbc:postgresql://localhost/db_name";    //db_name为数据可名    
    String Username="username";    //用户名    
    String Password="password";    //密码    
    Class.forName(Driver).newInstance();       
    Connection con=DriverManager.getConnection(URL,Username,Password);    
DB2：    
    String Driver="com.ibm.db2.jdbc.app.DB2.Driver";    //连接具有DB2客户端的Provider实例    
    //String Driver="com.ibm.db2.jdbc.net.DB2.Driver";    //连接不具有DB2客户端的Provider实例    
    String URL="jdbc:db2://localhost:5000/db_name";    //db_name为数据可名    
    String Username="username";    //用户名    
    String Password="password";    //密码    
    Class.forName(Driver).newInstance();       
    Connection con=DriverManager.getConnection(URL,Username,Password);    
Informix:    
    String Driver="com.informix.jdbc.IfxDriver";       
    String URL="jdbc:Informix-sqli://localhost:1533/db_name:INFORMIXSER=myserver";    //db_name为数据可名    
    String Username="username";    //用户名    
    String Password="password";    //密码    
    Class.forName(Driver).newInstance();       
    Connection con=DriverManager.getConnection(URL,Username,Password);    
JDBC-ODBC:    
    String Driver="sun.jdbc.odbc.JdbcOdbcDriver";    
    String URL="jdbc:odbc:dbsource";    //dbsource为数据源名    
    String Username="username";    //用户名    
    String Password="password";    //密码    
    Class.forName(Driver).newInstance();       
    Connection con=DriverManager.getConnection(URL,Username,Password);  
下面是我自己做的一个例子：
package dao;   
   
import java.sql.SQLException;   
import java.sql.Statement;   
import java.sql.Connection;   
import java.sql.DriverManager;   
import java.sql.ResultSet;   
import java.util.ArrayList;   
import java.util.List;   
   
import bean.Tbmeet;   
   
public class OracleDao {   
       
       
    private Statement stmt = null;   
       
    private  ResultSet rs = null;   
       
    private Connection conn = null;   
       
    public OracleDao(){   
        this.getConnection();   
    }   
       
    public void getConnection(){   
        try{   
            Class.forName("oracle.jdbc.driver.OracleDriver").newInstance();    
            String url="jdbc:oracle:thin:@10.11.0.31:1521:orcl"; //orcl为数据库的SID    
            String user="meeting";    
            String password="meeting";    
            conn= DriverManager.getConnection(url,user,password);    
        }catch (Exception e) {   
            System.out.println(e);   
        }   
    }   
       
    public List<Tbmeet> getRes(){   
        List<Tbmeet> list = new ArrayList<Tbmeet>();    
        try {   
            stmt = conn.createStatement();   
            rs = stmt.executeQuery("select * from tbmeetroomequipment");   
            while (rs.next()) {   
                Tbmeet t = new Tbmeet();   
                t.setId(rs.getLong(1));   
                t.setName(rs.getString(2));   
                t.setEcid(rs.getLong(3));   
                list.add(t);   
            }   
        } catch (SQLException e) {   
            list = null ;   
            e.printStackTrace();   
        }finally{   
            this.close(conn, stmt, rs);   
        }   
        return list;   
    }   
       
    public int delete(String sql) throws SQLException{   
        int number = 0 ;   
        try{   
            stmt = conn.createStatement();   
               
            number = stmt.executeUpdate(sql);   
               
            conn.commit();   
        }catch(Exception e){   
            System.out.println(e);   
            conn.rollback();   
            number = 0 ;   
        }finally{   
            this.close(conn, stmt, rs);   
        }   
        return number;   
    }   
       
    public void close(Connection conn , Statement stmt, ResultSet rs){   
        try{   
            if(rs != null){   
                rs.close();   
                rs = null ;   
            }   
            if(stmt != null){   
                stmt.close();   
                stmt = null ;   
            }   
            if(conn != null){   
                conn.close();   
                conn = null;   
            }   
               
        }catch(Exception e){   
            System.out.println(e);   
        }   
    }   
       
} 
来源： <http://hzw2312.blog.51cto.com/2590340/748307>
 
