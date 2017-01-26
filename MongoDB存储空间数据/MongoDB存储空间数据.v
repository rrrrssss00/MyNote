本文使用官方C# Driver，在MongoDB中存储，查询空间数据（矢量）

空间数据的存储
本例中，从一个矢量文件(shapefile格式)中读取矢量要素空间信息以及属性表，并写入到MongoDB中去，其中读取shapefile文件以及将空间信息转成json的功能通过Ogr库实现
            //打开MongoDB的Collection
            MongoDatabase db = server.GetDatabase("aa");
            MongoCollection colSheng = db.GetCollection("sheng");

            //使用Ogr库打开Shapefile文件
            DataSource ds = Ogr.Open(@"c:\temp\sheng.shp", 0);
            Layer lyr = ds.GetLayerByIndex(0);
            //读取要素数量和字段数量
            int feaCount = lyr.GetFeatureCount(0);
            int fieldCount = lyr.GetLayerDefn().GetFieldCount();
            //读取所有字段名
            List<string> fieldNames  =new List<string>();
            for (int i = 0; i < fieldCount; i++)
            {
                fieldNames.Add(lyr.GetLayerDefn().GetFieldDefn(i).GetName());
            }

            //循环将所有要素添加到MongoDB中
            for (int i = 0; i < feaCount; i++)
            {
                //使用Ogr库将矢量要素的空间信息转成Json格式
                Feature fea = lyr.GetFeature(i);
                Geometry geo = fea.GetGeometryRef();      
                string json = geo.ExportToJson(null);
                
                BsonDocument doc = new BsonDocument();
                
                //将Json格式的空间信息存到Collection中
                //BsonValue bs = BsonValue.Create(json);                  //这种方法是不可以的，添加到库里之后无法使用空间查询语句查询
                BsonValue bs2 = BsonDocument.Parse(json);               //这种方法才是正确的
                //doc.Add(new BsonElement("geom", bs));
                doc.Add(new BsonElement("geo",bs2));

                //通过循环将所有字段的属性信息存入Collection中
                for (int j = 0; j < fieldCount; j++)
                {
                    string tmpFieldVal = fea.GetFieldAsString(j);
                    doc.Add(new BsonElement(fieldNames[j],tmpFieldVal));
                }
                var res  = colSheng.Insert<BsonDocument>(doc);                
            }

然后，可以查看一下存储到MongoDB中的矢量数据是什么样的
在命令行中输入：
> db.sheng.find().limit(1)
结果为
{ "_id" : ObjectId("5371bf4e1dbba31914224563"), "geo" : { "type" : "Polygon", "coordinates" : [ [ [ 89.8496, 14.093 ], [ 90.3933, 14.004 ], [ 90.2708, 13.4708 ], [ 89.7284, 13.5597 ], [ 89.8496, 14.093 ] ] ] }, "pyname" : "sx", "boxtype" : "inter", "date" : "2012/6/5 12:41:42" }
可以看到名称为geo的这个Field，里边存的就是矢量要素的坐标信息

空间查询与空间索引
可用的空间操作包括geointersect,geowithin,near等，参考http://docs.mongodb.org/manual/reference/operator/query-geospatial/
这里使用geointersect为例说明一下：
            //获取Collection
            MongoDatabase db = server.GetDatabase("aa");
            MongoCollection colSheng = db.GetCollection("sheng");
         
            //定义一个查询框或查询多边形
            var poly = GeoJson.Polygon<GeoJson2DCoordinates>(
                GeoJson.Position(100, 20),
                GeoJson.Position(110, 20),
                GeoJson.Position(110, 40),
                GeoJson.Position(100, 40),
                GeoJson.Position(100, 20));

            //以这个查询多边形为条件定义一条查询语句
            var queryFilter2 = Query.GeoIntersects("geo", poly);
            //进行查询，输出MongoCursor
            cur = colSheng.FindAs<BsonDocument>(queryFilter2).SetFields( "pyname", "date");
            //获取结果
            var res = cur.ToArray();
            for (int i = 0; i < res.Count(); i++)
            {
                BsonDocument tmpDoc = res.ElementAt(i);
                //do something you want
            }
关于空间索引，可参考http://docs.mongodb.org/manual/applications/geospatial-indexes/
这里不详细说了

空间查询运算的问题：
在使用GeoIntersect进行空间查询时，遇到了查询结果与ArcGIS不一致的情况，详细看了一下，像是MongoDB的一个BUG（目前使用的是2.6.0版本）
具体信息如下（在命令行中操作）：

Collection中的坐标
> db.test.find()
{ "_id" : ObjectId("535884771dbba31858ad2101"), "geo" : { "type" : "Polygon", "coordinates" : [ [ [ 96.722, 38.755 ], [ 97.3482, 38.6922 ], [ 97.1674, 38.0752 ], [ 96.5474, 38.1383 ], [ 96.722, 38.755 ] ] ] } }

使用的查询语句
> db.test.find({ "geo" : { "$geoIntersects" : { "$geometry" : { "type" : "Polygon", "coordinates" : [[[91.0, 33.0], [102.0, 33.0], [102.0, 38.0], [91.0, 38.0], [91.0, 33.0]]] } } } })

查询结果：
{ "_id" : ObjectId("535884771dbba31858ad2101"), "geo" : { "type" : "Polygon", "coordinates" : [ [ [ 96.722, 38.755 ], [ 97.3482, 38.6922 ], [ 97.1674, 38.0752 ], [ 96.5474, 38.1383 ], [ 96.722, 38.755 ] ] ] } }

但可以看到，collection中只有一条记录，且该记录所有点的Y坐标均大于38.0，为什么查询结果里，这条记录与语句中的Box相交呢。。。很奇怪
因为有这样的问题，所以还不放心直接将空间查询用于实际应用，而是通过一种变通的方法进行简单的空间查询

大致思路为：为每一条记录均生成一个最小外接矩形，得到其xmax,xmin,ymax,ymin四个边界值，用数值的形式保存至Collection中，每次进行空间查询时，首先通过最小外接矩形进行一次筛选，判断这些最小外接矩形与查询语句中多边形的最小外接矩形之间的关系，如果相交，那么进行第二步判断，通过Ogr组件判断实际的多边形是否相交，返回最后结果
首先是生成最小外接矩形的代码：
            //获取Collection
            MongoDatabase db = server.GetDatabase("aa");
            MongoCollection colsheng= db.GetCollection("sheng");
            //查询所有记录
            var cur = colsheng.FindAllAs<BsonDocument>();
            long totalCount = cur.Count();
            //遍历所有记录
            for (int i = 0; i <= totalCount/1000; i++)
            {
                if (i * 1000 >= totalCount) continue;
                int skip = i * 1000;
                var cur2 = cur.Clone<BsonDocument>().SetSkip(skip).SetLimit(1000);
                var lst = cur2.ToArray();
                for (int j = 0; j < lst.Count(); j++)
                {
                    //获取一条记录对应的BsonDocument
                    BsonDocument doc = lst[j];
                        var id = doc["_id"];                    //该记录对应的ID
                        BsonDocument geo = doc["geo"].ToBsonDocument();    
                        string geostr = geo[1].ToString();        //该记录对应空间信息的Json字符串
                        List<double> coords = GetCoordLstFromString(geostr);        //解析Json串，获得所有点的坐标（这里子函数就省略了）
                        double xmin = 181, xmax = -181, ymin = 91, ymax = -91;        //四个边界值，由于图层为经纬度，所以初值设为这些值
                        //计算最大最小值
                        for (int k = 0; k < coords.Count; k++)
                        {
                            if (k % 2 == 0)
                            {
                                if (coords[k] < xmin) xmin = coords[k];
                                if (coords[k] > xmax) xmax = coords[k];
                            }
                            else
                            {
                                if (coords[k] < ymin) ymin = coords[k];
                                if (coords[k] > ymax) ymax = coords[k];
                            }
                        }
                        //将最大最小值写入Collection
                        var tmpQuery = Query.EQ("_id", id);
                        var tmpUpdate = MongoDB.Driver.Builders.Update.Set("xmax", xmax);
                        var tmpres = col02c.Update(tmpQuery, tmpUpdate);
                        tmpUpdate = MongoDB.Driver.Builders.Update.Set("xmin", xmin);
                        tmpres = col02c.Update(tmpQuery, tmpUpdate);
                        tmpUpdate = MongoDB.Driver.Builders.Update.Set("ymax", ymax);
                        tmpres = col02c.Update(tmpQuery, tmpUpdate);
                        tmpUpdate = MongoDB.Driver.Builders.Update.Set("ymin", ymin);
                        tmpres = col02c.Update(tmpQuery, tmpUpdate);
                    }
                }

然后是查询的代码：
            //获取Collection
            MongoDatabase db = server.GetDatabase("aa");
            MongoCollection colSheng = db.GetCollection("zy02c");

            //第一步，通过四边界筛选，
            var query = Query.And(Query.GT("xmax", 91.0), Query.LT("xmin", 102.0), Query.GT("ymax", 33.0), Query.LT("ymin", 38.0));
            var cur = colSheng.FindAs<BsonDocument>(query);

            //定义第二空间运算时的条件多边形（Ogr格式的定义）
            Geometry queryGeoLR = new Geometry(wkbGeometryType.wkbLinearRing);
            queryGeoLR.AddPoint(91.0, 33.0,0);
            queryGeoLR.AddPoint(102.0, 33.0,0);
            queryGeoLR.AddPoint(102.0, 38.0,0);
            queryGeoLR.AddPoint(91.0, 38.0,0);
            queryGeoLR.AddPoint(91.0, 33.0,0);
            Geometry queryGeo = new Geometry(wkbGeometryType.wkbPolygon);
            queryGeo.AddGeometry(queryGeoLR);

            //循环查询到的结果
            var lst = cur.ToArray();
            for (int i = lst.Length-1; i >=0; i--)
            {
                //获取当前记录对应的BsonDocument
                BsonDocument doc = lst[i];
                var id = doc["_id"];            //当前记录的ID
                BsonDocument geo = doc["geo"].ToBsonDocument();
                string geostr = geo.ToString();        //当前记录对应空间信息的Json字符串
                
                Geometry resGeo = Ogr.CreateGeometryFromJson(geostr);

                //判断是该Geometry与条件多边形是否相交
                if (resGeo.Intersects(queryGeo))
                {
                        //do something
                }
            }
 

