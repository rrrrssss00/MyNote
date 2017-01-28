JDBC中的事务
java JDBC使用事务示例 
下面代码演示如何使用JDBC的事务。JDBC事务操作需要在执行操作之前调用Connection类的setAutoCommit(false)方法。
在执行完操作之后，需要调用Connection实例的commit()方法来提交事务。
下面是示例代码：
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author outofmemory.cn
 */
public class Main {

    /**
     * 事务使用示例
     */
    public void updateDatabaseWithTransaction() {

        Connection connection = null;
        Statement statement = null;

        try {
            Class.forName("[nameOfDriver]");

            connection = DriverManager.getConnection("[databaseURL]",
                    "[userid]",
                    "[password]");

            //此处调用setAutoCommit(false)指定要在事务中提交
            connection.setAutoCommit(false);

            statement = connection.createStatement();

            //Execute the queries
            statement.executeUpdate("UPDATE Table1 SET Value = 1 WHERE Name = 'foo'");
            statement.executeUpdate("UPDATE Table2 SET Value = 2 WHERE Name = 'bar'");

            //No changes has been made in the database yet, so now we will commit
            //the changes.
            connection.commit();

        } catch (ClassNotFoundException ex) {
            ex.printStackTrace();
        } catch (SQLException ex) {
            ex.printStackTrace();

            try {
                //An error occured so we rollback the changes.
                connection.rollback();
            } catch (SQLException ex1) {
                ex1.printStackTrace();
            }
        } finally {
            try {
                if (statement != null)
                    statement.close();
                if (connection != null)
                    connection.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }

    }

来源： <http://outofmemory.cn/code-snippet/2422/java-JDBC-usage-transaction-example>
 
