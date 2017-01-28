import java.sql.DriverManager;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.*;
public class test {
    public static void main(String[] args) {

        
        try {
             
            Class.forName("org.postgresql.Driver");
 
        } catch (ClassNotFoundException e) {
 
            System.out.println("Where is your PostgreSQL JDBC Driver? "
                    + "Include in your library path!");
            e.printStackTrace();
            return; 
        }   
 
        System.out.println("PostgreSQL JDBC Driver 注册成功");
 
        Connection connection = null;
        try {             
            connection = DriverManager.getConnection(
                    "jdbc:postgresql://192.168.1.101:5432/testj", "testj","testj"); 
        } catch (SQLException e) { 
            System.out.println("连接失败："+e.getMessage());
            e.printStackTrace();
            return; 
        }        
        
        if (connection != null) {
            System.out.println("连接成功");
        } else {
            System.out.println("连接失败");
        }
        
        String sql="select * from test1"; 
         
        ResultSet rs=null;      
        
        try {
            Statement stmt=connection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
             
            rs = stmt.executeQuery(sql);
            
            //查询行数
            if(rs.wasNull()) throw new Exception("empty result");
            int rowcount = 0;
            if (rs.last()) {
              rowcount = rs.getRow();
              rs.beforeFirst(); // not rs.first() because the rs.next() below will move on, missing the first element
            }
            
            //循环获取记录
            while (rs.next()) {
                String col1Val = rs.getString(1);
                String col2Val = rs.getString(2);
                String col3Val = rs.getString(3);
                String col4Val = rs.getString(4);                
            }
            
            connection.setAutoCommit(false);
            
            //插入记录
            sql = "insert into test1 (pid,f1,fint,ffloat) values('aac1','bb',1,2.56)";
            int res = stmt.executeUpdate(sql);   
   
            connection.commit();
            connection.setAutoCommit(true);

            //删除记录
            sql = "delete from  test1 where pid='aac1'";
            res = stmt.executeUpdate(sql);     
            
            //更新记录
            sql = "update test1 set f1='afefwwf' where pid='aa'";
            res = stmt.executeUpdate(sql);            
        } 
        catch(SQLException ex)
        {
            System.out.println("Failed in query! "+ex.getLocalizedMessage());            
        }
        catch (Exception e) {
        }        
    }
}

注：上面配置的Statement 现在将产生可以更新并将应用其他数据库用户所作更改的 ResultSet。您还可以在这个 ResultSet 中向前和向后移动。

第一个参数指定 ResultSet 的类型。其选项有：

TYPE_FORWARD_ONLY：缺省类型。只允许向前访问一次，并且不会受到其他用户对该数据库所作更改的影响。 
TYPE_SCROLL_INSENSITIVE：允许在列表中向前或向后移动，甚至可以进行特定定位，例如移至列表中的第四个记录或者从当前位置向后移动两个记录。不会受到其他用户对该数据库所作更改的影响。 
TYPE_SCROLL_SENSITIVE：象 TYPE_SCROLL_INSENSITIVE 一样，允许在记录中定位。这种类型受到其他用户所作更改的影响。如果用户在执行完查询之后删除一个记录，那个记录将从 ResultSet 中消失。类似的，对数据值的更改也将反映在 ResultSet 中。 
第二个参数设置 ResultSet 的并发性，该参数确定是否可以更新 ResultSet。其选项有：

CONCUR_READ_ONLY：这是缺省值，指定不可以更新 ResultSet 
CONCUR_UPDATABLE：指定可以更新 ResultSet
 
