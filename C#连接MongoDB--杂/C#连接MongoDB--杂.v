String转到BsonDocument
BsonDocument.Parse(string)

声明一个Document类型的BsonValue
BsonValue val = BsonValue.Create(doc);

查询条件中使用Like：
复杂版：Query.Matches("name", BsonRegularExpression.Create(new Regex("Joe")));
简单版：Query.Matches("name", "Joe")


查询中只返回指定的字段
var queryFilter = Query.Matches("NAME","西");
MongoCursor<BsonDocument> cur = colSheng.FindAs<BsonDocument>(queryFilter).SetFields("NAME", "PYNAME", "CAPNAME");

遍历某个表
在通过Query获取到MongoCursor的情况下
如果表记录比较少：直接Cursor.ToArray()，得到一个List（不指定的情况下，为BsonDocument的List）直接循环即可
如果表记录数比较多，直接ToArray可能会对内存造成比较大的压力，则可以使用如下方式
            var cur = collection1.FindAllAs<BsonDocument>();
            long totalCount = cur.Count();
            for (int i = 0; i <= totalCount/1000; i++)
            {
                if (i * 1000 >= totalCount) continue;
                int skip = i * 1000;
                var cur2 = cur.Clone<BsonDocument>().SetSkip(skip).SetLimit(1000);
                var lst = cur2.ToArray();
                for (int j = 0; j < lst.Count(); j++)
                {
                    //do something;
               }
           }
注意其中cur2声明那一行，需要用到cur.Clone，如果不用的话，会报错：cur已经被 Frozen

向已有的某个Collection中添加一个Field
假如原来collection1中没有xmax这个Field，那么可以用如下代码向其中写值（自动添加xmax这个Field，如果已经有了，则覆盖该Field现有的内容）
  var tmpQuery = Query.EQ("_id", id);
  var tmpUpdate = MongoDB.Driver.Builders.Update.Set("xmax", xmax);
  var tmpres = collection1.Update(tmpQuery, tmpUpdate);


