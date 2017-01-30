SerializationManager:用于保存或打开项目文档
AppManager：保存了一系列MapControl，SerializationManager等，
LayoutControl: 打印输出窗口
SQLExpressionDialog（Symbology）：拼属性表SQL查询语句的窗体
SpatialToolStrip：主工具条，包括添加图层，放大缩小等功能
 
IMapLayer: 相当于ILayer
IFeatureLayer：同IFeatureLayer
IFeatureLayer中的Dataset属性，即为属性表
 
ImageData（Data）：影像图层
 
DataManager（Data）:提供打开，新建各种类型数据（栅格、矢量）的方法
IDataProvider（Data）：提供各种支持数据类型的接口，主要即重写其中的Open函数，
               包括：ShapefileDataProvider，BinaryRasterProvider，DotNetImageProvider
 
 
ShapefileDataProvider（Data）：提供了打开及新建Shapefile文件的功能（实际上只是提供了到各类数据相应功能函数的接口，方便统一管理
                   及调用）
ShapefileHeader（Data）：读取Shp文件头里的一些信息，包括类型ShapeType，长度，Extent等
 
AppManager中,在开始时需要调用一下LoadExtentions()函数来装载所有的插件,
 
FeatureSet:图层
 
 
Feature与Shape都是图层中的一个要素，包含空间和属性信息
 
MapPointLayer,MapLineLayer,MapPolygonLayer对应着三种最常用的矢量图层，都继承自IFeatureLayer，里面分别有一些功能函数
     tmpPntLayer = (MapPointLayer)map1.Layers[0];
 
    //用自带的控件显示属性表
          tmpPntLayer.ShowAttributes();
 
    //根据属性信息选择某些要素
    tmpPntLayer.SelectByAttribute("[str1]='aaaa'");
 
   
FeatureSet -> Shapefile :对应图层文件，例如一个shp图层。
IBasicGeometry接口：Point,LineString,Polygon这几种主要的Geometry均继承自它，对应图层中要素的空间信息，不包括属性信息，还有一些进行空间运算的函数
Feature:继承自IFeature,对应图层中的要素，包含空间信息和属性信息，空间信息即为IBasicGeometry类型，可以Point,LineString以及Polygon几种，属性信息可以通过DataRow属性获取和修改
 
 
Map1.ResetBuffer()　　　　刷新Ｍａｐ
 
 
新建一个Point的图层（内存）：
FeatureSet pointF = new FeatureSet(DotSpatial.Topology.FeatureType.Point);
pointF.Projection = map1.Projection;
DataColumn tmpCol = new DataColumn();
tmpCol.ColumnName = "ID";
tmpCol.DataType = System.Type.GetType("System.Int32");
pointF.DataTable.Columns.Add(tmpCol);
 
修改一个Field的长度及精度
 if (pointF is Shapefile)
{
    Field tmpFld = ((Shapefile)pointF).Attributes.Columns[0];
    tmpFld.Length = 15; //在ArcMap中显示为14
    if (tmpFld.DataType == System.Type.GetType("System.Double"))
    {
        tmpFld.DecimalCount = 4;
        ((Shapefile)pointF).Attributes.Attributes.Save();
    }
}
 
向刚建立的Point图层中添加要素
Coordinate coord = map1.PixelToProj(e.Location);
DotSpatial.Topology.Point point = new DotSpatial.Topology.Point(coord);
IFeature currentFeature = pointF.AddFeature(point);
pointID = pointID + 1;
currentFeature.DataRow["ID"] = pointID;
map1.ResetBuffer();        //刷新Map
 
新建一个Line图层（内存）
lineF = new FeatureSet(FeatureType.Line);
lineF.Projection = map1.Projection;
shapeType = FeatureType.Line;
DataColumn tmpCol = new DataColumn();
tmpCol.ColumnName = "ID";
tmpCol.DataType = System.Type.GetType("System.Int32");
lineF.DataTable.Columns.Add(tmpCol);
 
向新建立的Line图层中添加要素
if (e.Button == System.Windows.Forms.MouseButtons.Left)
{
    Coordinate coord = map1.PixelToProj(e.Location);
    if (firstClick)
    {                          
        List<Coordinate> lineArray = new List<Coordinate>();
        LineString lineGeometry = new LineString(lineArray);
        IFeature lineFeature = lineF.AddFeature(lineGeometry);
        lineID = lineID + 1;
        lineFeature.DataRow["ID"] = lineID;
        lineGeometry.Coordinates.Add(coord);
        firstClick = false;
    }
    else
    {
        IFeature existingFeature = lineF.Features[lineF.Features.Count - 1];
        existingFeature.Coordinates.Add(coord);
        if (existingFeature.Coordinates.Count >= 2)
        {
            lineF.InitializeVertices();
            map1.ResetBuffer();
        }
    }
}
else if (e.Button == System.Windows.Forms.MouseButtons.Right)
{
    firstClick = true;
    map1.ResetBuffer();
}
 
向一个图层中添加一个字段
fs.DataTable.Columns.Add( new DataColumn( "ID", typeof( int ))); //fs为FeatureSet
 
从一个图层中删除一个字段
DataTable dt = stateLayer.DataSet.DataTable;        //这个StateLayer是MapLayer（FeatureLayer），也可以用FeatureSet的DataTable属性做同样的操作
dt.Columns.Remove("PercentMale");
 
FeatureSet 新建一个内存中的FeatureSet后，Save()方法是不可以使用的，只能使用SaveAs方法，但是从文件中打开的FeatureSet对像，是可以使用Save方法的
 
Dotspatial里DataSet的GetFeature(int index)方法,表面上看起来是获取Feature对象,但实际上只是获取了Feature对象的一个拷贝
 
Map控件及MapFrame控件的初始投影（Projection）是wgs84,在代码中可以将其设为NULL，但这样的话，图层列表中MapFrame的右键菜单Projection会出错，要避免这一情况
