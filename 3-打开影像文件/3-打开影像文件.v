引用库文件并注册完毕后，即可使用GDAL库函数来打开影像文件
 
GDAL库中打开影像文件非常简单，使用Gdal.Open(string path,Acess eAcess)即可
第一个参数为影像路径，第二个参数为权限，分只读和可写两种
该函数返回值为Dataset类型
 
可以从该Dataset中获取到一些影像的基本信息，例如影像宽度和高度，波段数，坐标变换参数，坐标信息等
注：该函数获取到的Dataset中只包含影像的信息，并不包含影像所有像素的信息，要得到像素信息，需要用ReadRaster函数读取到数组中。
 
例
Dataset ds = Gdal.Open(rasterPath,Access.GA_ReadOnly)
int rasterX = ds.RasterXSize;    //影像宽度
int rasterY = ds.RasterYSize;    //影像高度
int bandCount = ds.RasterCount;    //波段数
double tmpD = new double[6];
ds.GetGeoTransform(tmpD);        //影像坐标变换参数
string proj = ds.GetProjection();        //影像坐标系信息（WKT格式字符串）
……
 
注：这里的GeoTransform(影像坐标变换参数)的定义是：通过像素所在的行列值得到其左上角点空间坐标的运算参数
例如:某图像上(P,L)点左上角的实际空间坐标为：
Xp = GeoTransform[0] + P * GeoTransform[1] + L * GeoTransform[2];
Yp = GeoTransform[3] + P * GeoTransform[4] + L * GeoTransform[5];
