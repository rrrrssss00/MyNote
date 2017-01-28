         Java数据库ResultSet转json实现
分类： Java语言 2013-02-26 10:19 6249人阅读 评论(24) 收藏 举报
javaresultsetjson数据库转换
现在有很多json相关的Java工具，如json-lib、gson等，它们可以直接把JavaBean转换成json格式。
在开发中，可能会从数据库中获取数据，希望直接转成json数组，中间不通过bean。
比如进行下面的转换：
数据表：
id
name
age
1
xxg
23
2
xiaoming
20
转换成json数组：
[
            {
               "id": "1",
                "name":"xxg",
                "age": "23"
            },
            {
               "id": "2",
                "name":" xiaoming",
                "age":"20"
            }
]
实现很简单，就是把查询结果ResultSet的每一条数据转换成一个json对象，数据中的每一列的列名和值组成键值对，放在对象中，最后把对象组织成一个json数组。
[java] view plaincopy
public String resultSetToJson(ResultSet rs) throws SQLException,JSONException  
{  
   // json数组  
   JSONArray array = new JSONArray();  
    
   // 获取列数  
   ResultSetMetaData metaData = rs.getMetaData();  
   int columnCount = metaData.getColumnCount();  
    
   // 遍历ResultSet中的每条数据  
    while (rs.next()) {  
        JSONObject jsonObj = new JSONObject();  
         
        // 遍历每一列  
        for (int i = 1; i <= columnCount; i++) {  
            String columnName =metaData.getColumnLabel(i);  
            String value = rs.getString(columnName);  
            jsonObj.put(columnName, value);  
        }   
        array.put(jsonObj);   
    }  
    
   return array.toString();  
}  
上面的代码只需要用到org.json的jar包，网上随处可下载。

来源： <http://blog.csdn.net/xiao__gui/article/details/8612503>
 
