一、关于MongoDB

 

在众多NoSQL数据库，MongoDB是一个优秀的产品。其官方介绍如下： 
MongoDB (from "humongous") is a scalable, high-performance, open source, document-oriented database.

看起来，十分诱人！值得说明的是，MongoDB的document是以BSON（Binary JSON）格式存储的，完全支持Schema Free。这对地理空间数据是十分友好的。因为有著名的GeoJSON可供使用。另外OGR库也支持将Geometry类型导出为JSON格式。

本文将尝试使用OGR库把Shapefile导入到MongoDB存储，然后建立空间索引，进行空间查询。

著名的Foursquare使用了MongoDB数据库。

二、开发环境

 

MongoDB+Python+Pymongo+GDAL for Python

关于MongoDB和Python安装，本文不做介绍。关于GDAL for Python的安装，可见我的另一篇博文：http://blog.3sdn.net/311.html

在继续本文之前，请先启动你的MongoDB服务器。本文默认采用如下服务器参数： 
Server:localhost 
Post:27017 
Database Name:gisdb

三、将shapefile导入到MongoDB

 

这里我直接提供代码，代码中已经有比较详尽的注释了。代码基本源于“引文1”，只是做了些改动，将MongoDB的Geometry的存储格式由wkt改成json。你可直接复制并运行下面的代码，当然需要修改一下Shapefile路径和MongoDB服务器相关参数。

import os 
import sys 
import json 
from pymongo import json_util 
from pymongo.connection import Connection 
from progressbar import ProgressBar 
from osgeo import ogr
def shp2mongodb(shape_path, mongodb_server, mongodb_port, mongodb_db, mongodb_collection, append, query_filter): 
        """Convert a shapefile to a mongodb collection""" 
        print ‘Converting a shapefile to a mongodb collection ‘ 
        driver = ogr.GetDriverByName(‘ESRI Shapefile’) 
        print ‘Opening the shapefile %s…’ % shape_path 
        ds = driver.Open(shape_path, 0) 
        if ds is None: 
                print ‘Can not open’, ds 
                sys.exit(1) 
        lyr = ds.GetLayer() 
        totfeats = lyr.GetFeatureCount() 
        lyr.SetAttributeFilter(query_filter) 
        print ‘Starting to load %s of %s features in shapefile %s to MongoDB…’ % (lyr.GetFeatureCount(), totfeats, lyr.GetName()) 
        print ‘Opening MongoDB connection to server %s:%i…’ % (mongodb_server, mongodb_port) 
        connection = Connection(mongodb_server, mongodb_port) 
        print ‘Getting database %s’ % mongodb_db 
        db = connection[mongodb_db] 
        print ‘Getting the collection %s’ % mongodb_collection 
        collection = db[mongodb_collection] 
        if append == False: 
                print ‘Removing features from the collection…’ 
                collection.remove({}) 
        print ‘Starting loading features…’ 
        # define the progressbar 
        pbar = ProgressBar(maxval=lyr.GetFeatureCount()).start() 
        k=0 
        # iterate the features and access its attributes (including geometry) to store them in MongoDb 
        feat = lyr.GetNextFeature() 
        while feat: 
                mongofeat = {} 
                geom = feat.GetGeometryRef() 
                mongogeom = geom.ExportToJson() 
                # store the geometry data with json format 
                mongofeat['geom'] = json.loads(mongogeom,object_hook=json_util.object_hook)
                # iterate the feature’s  fields to get its values and store them in MongoDb 
                feat_defn = lyr.GetLayerDefn() 
                for i in range(feat_defn.GetFieldCount()): 
                        value = feat.GetField(i) 
                        if isinstance(value, str): 
                                value = unicode(value, "gb2312") 
                        field = feat.GetFieldDefnRef(i) 
                        fieldname = field.GetName() 
                        mongofeat[fieldname] = value 
                # insert the feature in the collection 
                collection.insert(mongofeat) 
                feat.Destroy() 
                feat = lyr.GetNextFeature() 
                k = k + 1 
                pbar.update(k) 
        pbar.finish() 
        print ‘%s features loaded in MongoDb from shapefile.’ % lyr.GetFeatureCount() 
        
        
input_shape = ‘/home/evan/data/map/res4_4m/XianCh_point.shp’ 
mongodb_server = ‘localhost’ 
mongodb_port = 27017 
mongodb_db = ‘gisdb’ 
mongodb_collection = ‘xqpoint’ 
filter = ”

print ‘Importing data to mongodb…’ 
shp2mongodb(input_shape, mongodb_server, mongodb_port, mongodb_db, mongodb_collection, False, filter)


四、MongoDB中空间数据的存储格式

 

在MongoDB的Shell中执行： 
>db.xqpoint.findOne() 
结果如下：

{ 
    "_id" : ObjectId("4dc82e7f7de36a5ceb000000"), 
    "PERIMETER" : 0, 
    "NAME" : "漠河县", 
    "PYNAME" : "Mohe Xian", 
    "AREA" : 0, 
    "ADCODE93" : 232723, 
    "CNTYPT_ID" : 31, 
    "CNTYPT_" : 1, 
    "geom" : { 
        "type" : "Point", 
        "coordinates" : [ 
            122.53233, 
            52.968872 
        ] 
    }, 
    "ID" : 1031, 
    "PN" : 1, 
    "CLASS" : "AI" 
} 
 

这便是一个document，使用JSON格式，一目了然。其中的"geom"即为Geometry类型的数据，即地理空间数据，也是采用JSON格式存储，这样后续的空间索引与空间查询将十分方便。

MongoDB原生地支持了空间索引与空间查询，这一点比PostgreSQL方便，不再需要使用PostGIS进行空间扩展了。至于性能，我还没测试，在此不敢妄加评论。

五、在MongoDB中建立空间索引

 

>db.xqpoint.ensureIndex({‘geom.coordinates’:’2d’})

是不是十分简单？其它参数及用法请自行查看MongoDB手册。

六、在MongoDB中进行空间查询

 

>db.xqpoint.find({"geom.coordinates":[122.53233,52.968872]})

即可查询到上述“莫河县”这个点。当然，像这种精确查询，实际应用并不多。实际应用的空间查询大多为范围查询。MongoDB支持邻域查询（$near），和范围查询（$within）。

1. 邻域查询($near)

 

>db.xqpoint.find({"geom.coordinates":{$near:[122,52]}}) 
上述查询语句查询点[122,52]附近的点，MongoDB默认返回附近的100个点，并按距离排序。你也可以用limit()指定返回的结果数量， 如：>db.xqpoint.find({"geom.coordinates":{$near:[122,52]}}).limit(5)

另外，你也可以指定一个最大距离，只查询这个距离内的点。 
>db.xqpoint.find({"geom.coordinates":{$near:[122,52],$maxDistance:5}}).limit(5)

MongoDB的find()方法可很方便的进行查询，同时MongoDB也提供了geoNear命令，用于邻域查询。 
>db.runCommand({geoNear:"xqpoint",near:[122,56],num:2}) 
上述语句用于查询[122,56]点附近的点，并只返回2个点。结果如下：

{ 
    "ns" : "gisdb.xqpoint", 
    "near" : "1110011000111101111100010000011000111101111100010000", 
    "results" : [ 
        { 
            "dis" : 3.077515616588727, 
            "obj" : { 
                "_id" : ObjectId("4dc82e7f7de36a5ceb000000"), 
                "PERIMETER" : 0, 
                "NAME" : "漠河县", 
                "PYNAME" : "Mohe Xian", 
                "AREA" : 0, 
                "ADCODE93" : 232723, 
                "CNTYPT_ID" : 31, 
                "CNTYPT_" : 1, 
                "geom" : { 
                    "type" : "Point", 
                    "coordinates" : [ 
                        122.53233, 
                        52.968872 
                    ] 
                }, 
                "ID" : 1031, 
                "PN" : 1, 
                "CLASS" : "AI" 
            } 
        }, 
        { 
            "dis" : 4.551319677334594, 
            "obj" : { 
                "_id" : ObjectId("4dc82e7f7de36a5ceb000001"), 
                "PERIMETER" : 0, 
                "NAME" : "塔河县", 
                "PYNAME" : "Tahe Xian", 
                "AREA" : 0, 
                "ADCODE93" : 232722, 
                "CNTYPT_ID" : 66, 
                "CNTYPT_" : 2, 
                "geom" : { 
                    "type" : "Point", 
                    "coordinates" : [ 
                        124.7058, 
                        52.340332 
                    ] 
                }, 
                "ID" : 1059, 
                "PN" : 1, 
                "CLASS" : "AI" 
            } 
        } 
    ], 
    "stats" : { 
        "time" : 0, 
        "btreelocs" : 85, 
        "nscanned" : 85, 
        "objectsLoaded" : 4, 
        "avgDistance" : 3.814417646961661, 
        "maxDistance" : 4.551319677334594 
    }, 
    "ok" : 1 
}
 
当然，我们也可附加条件查询条件，如查询[122,56]附近的且"PYNAME"为"Tahe Xian"的点： 
>db.runCommand({geoNear:"xqpoint",near:[122,56],num:2,query:{"PYNAME":"Tahe Xian"}) 
返回结果如下：

{ 
    "ns" : "gisdb.xqpoint", 
    "near" : "1110011000111101111100010000011000111101111100010000", 
    "results" : [ 
        { 
            "dis" : 4.551319677334594, 
            "obj" : { 
                "_id" : ObjectId("4dc82e7f7de36a5ceb000001"), 
                "PERIMETER" : 0, 
                "NAME" : "塔河县", 
                "PYNAME" : "Tahe Xian", 
                "AREA" : 0, 
                "ADCODE93" : 232722, 
                "CNTYPT_ID" : 66, 
                "CNTYPT_" : 2, 
                "geom" : { 
                    "type" : "Point", 
                    "coordinates" : [ 
                        124.7058, 
                        52.340332 
                    ] 
                }, 
                "ID" : 1059, 
                "PN" : 1, 
                "CLASS" : "AI" 
            } 
        } 
    ], 
    "stats" : { 
        "time" : 45, 
        "btreelocs" : 2095, 
        "nscanned" : 2096, 
        "objectsLoaded" : 2096, 
        "avgDistance" : 4.551319677334594, 
        "maxDistance" : 4.551319677334594 
    }, 
    "ok" : 1 
}

 
2. 范围查询($within)

 

MongoDB的$within操作符支持的形状有$box（矩形）,$center（圆形）,$polygon（多边形，包括凹多边形和凸多边形）。所有的范围查询，默认是包含边界的。

查询一个矩形范围，需要指定矩形的左下角和右上角两个坐标点，如下： 
> box = [[80,40],[100,50]] 
> db.xqpoint.find({"geom.coordinates":{$within:{$box:box}}})

查询一个圆形范围，需要指定圆心坐标和半径，如下： 
> center = [80,44] 
> radius =5 
> db.xqpoint.find({"geom.coordinates":{$within:{$center:[center,radius]}}})

查询一个多边形范围，需要指定多边形的各个顶点，可以通过一个顶点数组或一系列点对象指定。其中，最后一个点是默认与第一个点连接的。如下： 
> polygon1 = [[75,35],[80,35],[80,45],[60,40]] 
> db.xqpoint.find({"geom.coordinates":{$within:{$polygon:polygon1}}}) 
或者 
> polygon2 = ｛a:{75,35},b:{80,35},c:{80,45},d:{60,40}} 
> db.xqpoint.find({"geom.coordinates":{$within:{$polygon:polygon2}}})

注意：MongoDB 1.9及以上版本才支持多边形范围查询。

P.S. MongoDB还支持复合索引，球面模型（可简单理解为投影吧），多位置文档（Multi-location Documents，即一个文档中包括多个Geometry），可参见“引文2”或MongoDB手册。

七、参考资料

 

引文1：http://www.paolocorti.net/2009/12/06/using-mongodb-to-store-geographic-data/ 
引文2：http://www.mongodb.org/display/DOCS/Geospatial+Indexing


来源： <http://blog.sina.com.cn/s/blog_9ffa2c9b01011z7z.html>
 

