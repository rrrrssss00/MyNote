1:4f7000fd0826 3-28版本
PointShapefile.cs 
 public override void SaveAs(string fileName, bool overwrite)
 
from:
Header.SetExtent(MyExtent);
 
to:
 if(MyExtent != null)
                Header.SetExtent(MyExtent);
 
 
2:4f7000fd0826 3-28版本
Ｍａｐ控件添加了ＭｏｕｓｅＭｏｖｅ事件，显示当前鼠标的坐标，再在Ｍａｐ控件中载入一个空的图层，那么ＭｏｕｓｅＭｏｖｅ事件会报错
 
3:4f7000fd0826 3-28版本
使用FeatureSet的Open方法打开一个文件中FeatureSet时，一定要用静态方法OpenFile，否则不能成功，而且在往里添加记录时，
在FeatureSet.AddFeature之前，要调用一下int adf = targetLayer.DrawingFilter.Count; 其中targetLayer是对应的FeatureLayer，而targetSet是从Layer中取出来的FeatureSet，该问题目前存在于点图层
 
4:342ca313f295 7-20版本
Data.AttributeTable.cs中,读取表头不能读取中文,进行修改后,可以读取
ReadTableHeader()函数
// read the field name
//char[] buffer = reader.ReadChars(11);
 
 int length = 11;
byte[] byteContent = reader.ReadBytes(11);
if (byteContent.Length < length)
{
    length = byteContent.Length;
}
char[] buffer = new char[length];
Encoding.Default.GetChars(byteContent, 0, length, buffer, 0);
 
5:342ca313f295 7-20版本
Data.AttributeTable.cs中,读取表内容时,如果有中文,将会导致其错位,进行修改后可以读取
（写入时中文错误参考第10点）(中文错位现象还有一个地方要改，见11点)
（Shp的属性表中文读取相关还有一篇专门的文件总结）
 
变量声明中:
    //private char[] _characterContent;
    private byte[] _characterContent; 
 
GetRowOffsets()函数中:
    //_characterContent = new char[length];
    //Encoding.Default.GetChars(byteContent, 0, length, _characterContent, 0);
    _characterContent = byteContent; //读取中文问题 by wyz
 
ReadTableRowFromChars()函数中:
    // read the data.
    //char[] cBuffer = new char[currentField.Length];
    //Array.Copy(_characterContent, start, cBuffer, 0, currentField.Length);
    //start += currentField.Length;
 
    byte[] bBuffer = new byte[currentField.Length];
    Array.Copy(_characterContent, start, bBuffer, 0, currentField.Length);
    start += currentField.Length;
 
    char[] cBuffer = new char[currentField.Length];
    cBuffer = Encoding.Default.GetChars(bBuffer);
 
6:342ca313f295 7-20版本
 
DotSpatial.Data.Raster.GdalExtension.GdalHelper.cs的Gdal.AllRegister();之后,
将 Gdal.SetConfigOption("GDAL_FILENAME_IS_UTF8", "NO");注释掉
 
RasterLayer及MapRasterLayer中
加载影像后,显示时,需要将所有的8000*8000改为4000*4000,以防止new Bitmap时因为尺寸过大而出错
 
7:DotSpatial_a526b9edcd86 1027版本 （DotSpatial_65997 120412版本同样）
该版本RasterProvider还在修改中，读取影像有误，做以下修改可以读取TIF文件
(注：这样修改后将不能保存和读取含影像图层的项目文件)
DotSpatial.Data.Rasters.GdalExtension.GdalRasterProvider
构造函数修改为：
 public GdalRasterProvider()
{
    GdalHelper.Configure();
 
    // Add ourself in for these extensions, unless another provider is registered for them.
    //string[] extensions = { ".tif", ".tiff", ".adf" };
    //foreach (string extension in extensions)
    //{
    // if (!DotSpatial.Data.DataManager.DefaultDataManager.PreferredProviders.ContainsKey(extension))
    // {
    // DotSpatial.Data.DataManager.DefaultDataManager.PreferredProviders.Add(extension, this);
    // }
    //}
}
 
DotSpatial.Data.Rasters.GdalExtension.GdalImageProvider
添加构造函数：
public GdalImageProvider()
{
    string[] extensions = { ".tif", ".tiff", ".adf"};
    foreach (string extension in extensions)
    {
        if (!DotSpatial.Data.DataManager.DefaultDataManager.PreferredProviders.ContainsKey(extension))
        {
            DotSpatial.Data.DataManager.DefaultDataManager.PreferredProviders.Add(extension, this);
        }
    }
}

8:DotSpatial_65997 120412版本
DotSpatial.Control.SpatialToolStrip
部分工具没有对应的ICON,还有部分工具功能未实现（量距），将其从工具条中移去

9:DotSpatial_65997 120412版本的插件问题
见另一篇专门讲插件的文章

10:DotSpatial_67140 120829版本
Shp文件中，如果向字段中写入中文，下一行中会出现错位等现象该行的显示也有问题，解决方法如下：
Data.AttributeTable.cs中，
public void Write(string text, int length)这个函数，修改为：
 
//by wyz
            //text = text.PadRight(length, ' ');         
            //string dbaseString = text.Substring(0, length);
            //byte[] bytes = Encoding.Default.GetBytes(dbaseString.ToCharArray());
 
 
            byte[] tmpBytes = Encoding.Default.GetBytes(text.ToCharArray());        //原字符串序列化后的二进制流
            int tmpLength = length - tmpBytes.Length;           //原字符串要加多少个空格才能对应上字段宽度
            byte[] bytes = new byte[length];
            if (tmpLength < 0)                          //如果字符串序列化以后比字段宽度要长，那么截取一下
            {
                Array.Copy(tmpBytes, bytes, length);
            }
            else
            {
                string dbaseString = text.PadRight(text.Length + tmpLength, ' ');
                bytes = Encoding.Default.GetBytes(dbaseString.ToCharArray());
            }
 
            _writer.Write(bytes);
 
10:DotSpatial_67140 120829版本
Shp文件中，如果读取中文，还有一个地方会造成错位，需要和第5点一起改一下（Shp的属性表中文读取相关还有一篇专门的文件总结）
Data.AttributeTable.cs中，
private DataRow ReadTableRow(int currentRow, long start, char[] characterContent, DataTable table）函数将原有的
 
start += currentField.Length;
 
修改为：
//这里由于Char的长度和Byte的长度不一样，而字段长度是按Byte长度算的，
//如果按这个长度截Char数组，会产生问题（实际上就是start +=的数错了）by wyz
                byte[] tmpBytes = Encoding.Default.GetBytes(cBuffer);
                byte[] tmpBytes2 = new byte[currentField.Length];
                Array.Copy(tmpBytes, tmpBytes2, currentField.Length);
                char[] cBuffer2 = Encoding.Default.GetChars(tmpBytes2);
                start += cBuffer2.Length;
 
11:DotSpatial_67140 120829版本
Shp文件中，如果属性表的字段名有中文，那么在向Shp中写数据或修改数据时，字段名会变成乱码，需要进行的修改为：
Data.AttributeTable.cs中，
public void WriteHeader(BinaryWriter writer)
函数里，将原有的
                for (int j = 0; j < 11; j++)
                {
                    if (currentField.ColumnName.Length > j)
                        writer.Write((byte)currentField.ColumnName[j]);
                    else writer.Write((byte)0);
                }
改为：
 
 byte[] tmpBytes =  Encoding.Default.GetBytes(currentField.ColumnName);
                writer.Write(tmpBytes);
                if (tmpBytes.Length < 11)
                    for (int i = 0; i < 11-tmpBytes.Length; i++)
                        writer.Write((byte)0);
