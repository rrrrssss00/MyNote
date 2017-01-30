扩展：涉及表连接，排序等高级操作时，可再阅读：
http://bijian1013.iteye.com/blog/1973259  这个系列的文章

在Oracle中，用SQL来实现分页有很多种实现方式，但有些语句可能并不是很通用，只能用在一些特殊场景之中；
以下介绍三种比较通用的实现方案；在以下各种实现中，ROWNUM是一个最核心的关键词，在查询时他是一个虚拟的列，取值为1到记录总数的序号；
首先来介绍我们工作中最常使用的一种实现方式：
SELECT *
  FROM (SELECT ROW_.*, ROWNUM ROWNUM_
          FROM (SELECT *
                  FROM TABLE1
                 WHERE TABLE1_ID = XX
                 ORDER BY GMT_CREATE DESC) ROW_
         WHERE ROWNUM <= 20)
 WHERE ROWNUM_ >= 10;
其中最内层的查询SELECT为不进行翻页的原始查询语句，可以用自己的任意Select SQL替换；ROWNUM <= 20和ROWNUM >= 10控制分页查询的每页的范围。
分页的目的就是控制输出结果集大小，将结果尽快的返回；上面的SQL语句在大多数情况拥有较高的效率，主要体现在WHERE ROWNUM <= 20这句上，这样就控制了查询过程中的最大记录数。
上面例子中展示的在查询的第二层通过ROWNUM <= 20来控制最大值，在查询的最外层控制最小值。而另一种方式是去掉查询第二层的WHERE ROWNUM <= 20语句，在查询的最外层控制分页的最小值和最大值。此时SQL语句如下，也就是要介绍的第二种实现方式：
SELECT *
  FROM (SELECT A.*, ROWNUM RN
          FROM (SELECT *
                  FROM TABLE1
                 WHERE TABLE1_ID = XX
                 ORDER BY GMT_CREATE DESC) A)
 WHERE RN BETWEEN 10 AND 20;
由于Oracle可以将外层的查询条件推到内层查询中，以提高内层查询的执行效率，但不能跨越多层。
对于第一个查询语句，第二层的查询条件WHERE ROWNUM <= 20就可以被Oracle推入到内层查询中，这样Oracle查询的结果一旦超过了ROWNUM限制条件，就终止查询将结果返回了。
而 第二个查询语句，由于查询条件BETWEEN 10 AND 20是存在于查询的第三层，而Oracle无法将第三层的查询条件推到最内层（即使推到最内层也没有意义，因为最内层查询不知道RN代表什么）。因此，对 于第二个查询语句，Oracle最内层返回给中间层的是所有满足条件的数据，而中间层返回给最外层的也是所有数据。数据的过滤在最外层完成，显然这个效率 要比第一个查询低得多。
以上两种方案完全是通过ROWNUM来完成，下面一种则采用ROWID和ROWNUM相结合的方式，SQL语句如下：
SELECT *
  FROM (SELECT RID
          FROM (SELECT R.RID, ROWNUM LINENUM
                  FROM (SELECT ROWID RID
                          FROM TABLE1
                         WHERE TABLE1_ID = XX
                         ORDER BY GMT_CREATE DESC) R
                 WHERE ROWNUM <= 20)
         WHERE LINENUM >= 10) T1,
       TABLE1 T2
 WHERE T1.RID = T2.ROWID;

这里注意，这种方法除了查询的开销外，还涉及到LINK的开销，可能会花费较大，测试中，在WHERE T1.RID = T2.ROWID;后加(+)会大大减小开销
另外，如果不需要筛选和排序，可将最中心一层去掉，如下，但是要注意 select rowid from 和select * from 的顺序有可能是不一样的~
SELECT *
  FROM (SELECT RID
          FROM (SELECT ROWID RID, ROWNUM LINENUM
                          FROM TABLE1   WHERE ROWNUM <= 20)
         WHERE LINENUM >= 10) T1,
       TABLE1 T2
 WHERE T1.RID = T2.ROWID;

从语句上看，共有4层Select嵌套查询，最内层为可替换的不分页原始SQL语句，但是他查询的字段只有ROWID，而没有任何待查询的实际表字段，具体查询实际字段值是在最外层实现的；
这种方式的原理大致为：首先通过ROWNUM查询到分页之后的10条实际返回记录的ROWID，最后通过ROWID将最终返回字段值查询出来并返回；
和前面两种实现方式相比，该SQL的实现方式更加繁琐，通用性也不是非常好，因为要将原始的查询语句分成两部分（查询字段在最外层，表及其查询条件在最内层）；
但这种实现在特定场景下还是有优势的：比如我们经常要翻页到很后面，比如10000条记录中我们经常需要查9000-9100及其以后的数据；此时该方案效率可能要比前面的高；
因为前面的方案中是通过ROWNUM <= 9100来控制的，这样就需要查询出9100条数据，然后取最后9000-9100之间的数据，而这个方案直接通过ROWID取需要的那100条数据；
从不断向后翻页这个角度来看，第一种实现方案的成本会越来越高，基本上是线性增长，而第三种方案的成本则不会像前者那样快速，他的增长只体现在通过查询条件读取ROWID的部分；

………………
注意：当ROWNUM作为查询条件时，他是在order by之前执行，所以要特别小心；
比如我们想查询TABLE1中按TABLE1_ID倒序排列的前10条记录不能用如下的SQL来完成：
SELECT * FROM TABLE1 WHERE ROWNUM <= 10 ORDER BY TABLE1_ID DESC;
来源： <http://blog.csdn.net/sfdev/article/details/2801712>
 
