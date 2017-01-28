1:获取ResultSet的行数
ResultSet rs = ps.executeQuery();
int rowcount = 0;
if (rs.last()) {
  rowcount = rs.getRow();
  rs.beforeFirst(); // not rs.first() because the rs.next() below will move on, missing the first element
}
while (rs.next()) {
  // do your standard per row stuff
}

2.ResultSet里的列是从左到右编号,从1开始(不是0)

3.操作要求可卷动的 ResultSet，但此 ResultSet 是 FORWARD_ONLY错误
org.postgresql.util.PSQLException: Operation requires a scrollable ResultSet, but this ResultSet is FORWARD_ONLY.(操作要求可卷动的 ResultSet，但此 ResultSet 是 FORWARD_ONLY。)
      此为Java JDBC及其驱动提供的功能，和PostgreSQL数据库没有任何关系。
      此情况一般是在创建Statement对象时使用的是缺省无参数,系统生成的数据集只可单向向前移动指针,而不可双向移动数据记录指针,即原为
...
Statement stmt = dbConn.createStatement() ; 
Result rs = stmt.executeQuery(sql) ; 
....
      改为
...
Statement stmt = dbConn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,ResultSet.CONCUR_READ_ONLY) ; 
Result rs = stmt.executeQuery(sql) ; 
...
       此时生成的rs可以使用 rs.first()等反向移动指针的操作

       另外 业务系统中大多数应为FORWARD_ONLY的Result,因其资源消耗与SCROLLABLE的Result要小得多,故并不是全部要修改,只是在业务逻辑中需反向移动指针的功能才需修改

来源： <http://blog.csdn.net/piaoshisun/article/details/5698725>
 
