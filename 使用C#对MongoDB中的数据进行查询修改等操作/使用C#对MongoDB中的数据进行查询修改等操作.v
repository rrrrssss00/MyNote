首先，使用的是官方提供的C#访问组件https://github.com/mongodb/mongo-csharp-driver

然后、编译后引用MongoDB.Bson.dll及MongoDB.Driver.dll，并在cs文件中声明引用
using MongoDB.Bson;
using MongoDB.Driver;
using MongoDB.Driver.Builders;
第一个是针对Bson格式的命名空间，第二个是主空间，第三个是用来构造查询和更新等条件的构造器命名空间

一、数据库连接
           MongoClient client = null;
            MongoServer server = null;
       
            //connection
            string conStr = "mongodb://user:pw@127.0.0.1/db1";
            client = new MongoClient(conStr);
            server = client.GetServer();
            server.Connect();

注意连接串的写法，上面的写法是带用户认证的，关于连接串写法的更多信息可以参考http://docs.mongodb.org/ecosystem/tutorial/authenticate-with-csharp-driver/

二、获取数据库内的Collection
            MongoDatabase db = server.GetDatabase("db1");
            MongoCollection colaa = db.GetCollection("col1");
这里获取在db1数据库下，名为col1的Collection，

这里获取的MongoCollection支持泛型，可以按默认的BsonDocument为一行的格式获取，也可以按自定义的类来获取，
若按BsonDocument为一行获取，代码如下（每个BsonDocument对象为Collection的一行）：
            MongoCursor<BsonDocument> doc = colaa.FindAllAs<BsonDocument>();
            foreach (BsonDocument book in doc) {}

若按自定义的类为一行来获取，代码如下：
            MongoCursor<row> res = colaa.FindAllAs<row>();
                         foreach (row row1 in res){}
这里要注意，如果按自定义类来获取，那么类需要预先定义好，且类中的变量名必须与数据库中一致，且列数也需要一致，若出现数据库中有某一列，但类中缺少这个对象时，会报错，下面是一个类定义的示例：
    public class row
    {
        public ObjectId _id;
        public string name;
        public string part;
        public string age;
    }
上例中，FindAllAs函数为全部查询，还有一些其它行查询及筛选方法，见http://docs.mongodb.org/ecosystem/tutorial/use-csharp-driver/#mongocollection-tdefaultdocument-class中的MongoCollection部分

三、读取Collection中一行内的内容
和上面对应的，有两种情况，如果是按自定义类来获取的数据行，那么直接访问类的成员变量即可

如果是按BsonDocument获取的，那每一行数据对应一个BsonDocument，一个BsonDocument是由多个“Name-Value“对构成的，其中Name为String格式，Value为BsonValue类型，该值可以直接使用book["name"]的格式进行访问，关于BsonValue的进一步详细说明，可以参考http://docs.mongodb.org/ecosystem/tutorial/use-csharp-driver/#bsonvalue-and-subclasses中的BsonValue部分

四：新建Collection
新建Colletion很简单，代码示例如下，但注意，如果已经存在了指定名称的Collection，则会抛出异常
            //create Collection
            MongoDatabase db = server.GetDatabase("db1");
            var res =db.CreateCollection("col2");

五：插入行
同样分两种情况，插入方式基本相同，代码如下：
            //insert
            MongoDatabase db = server.GetDatabase("db1");
            MongoCollection colaa = db.GetCollection("col1");
            //使用BsonDocument格式插入
            BsonDocument doc = new BsonDocument { { "name", "sse2" }, { "part", "44224" } };
            colaa.Insert(doc);
            //使用自定类插入
            row r1 = new row { name = "sse3", part = "554" };
            colaa.Insert<row>(r1);

这里注意一下，如果自定义类里某一个变量没有赋值，在插入到数据库时，也会写一个Null进去，而BsonDocument则不会出现这个元素，比如上两个语句的运行结果：
{ "_id" : ObjectId("5355d8dfccee160de4dca545"), "name" : "sse2", "part" : "44224" }
{ "_id" : ObjectId("5355d93bccee16088491c420"), "name" : "sse3", "part" : "554", "age" : null }

还有一些的方法，例如批量写入等，可以参考http://docs.mongodb.org/ecosystem/tutorial/use-csharp-driver/#insertbatch-method中的相应内容

六：更新行
更新行时需要使用到构造器构造查询条件和更新语句，Query为查询条件构造器，Update为更新语句构造器，代码示例如下：
           //update
            MongoDatabase db = server.GetDatabase("db1");
            MongoCollection colaa = db.GetCollection("col1");
            var query = Query.And(
                Query.EQ("name", "sse3"),
                Query.EQ("part", "554")
            );
            var update = MongoDB.Driver.Builders.Update.Set("age", "36");
            colaa.Update(query, update);

其它还有一些更新的函数，比如更新和插入为一体的Save等，可以参考http://docs.mongodb.org/ecosystem/tutorial/use-csharp-driver/#save-tdocument-method的相应内容

七：删除行
删除行时也需要使用到Query构造器构造查询条件，语句会将符合条件的行删除掉，代码示例如下：
           //remove
            MongoDatabase db = server.GetDatabase("db1");
            MongoCollection colaa = db.GetCollection("col1");
            var query = Query.And(
                Query.EQ("name", "sse3"),
                Query.EQ("part", "554")
            );
            var res = colaa.Remove(query);

