在创建影像前,需要先引用GDAL库的注册函数Gdal.AllRegister()
 
1:GDAL支持的影像格式
首先要明确GDAL所支持的影像格式,
http://www.gdal.org/formats_list.html 中列出了GDAL支持的影像格式,每一种影像格式在GDAL中都对应一种驱动(Driver),
网页中表格第一列(Long Format Name)为影像格式的描述,点击该列还可通过链接查看该格式的详细信息,其中包括该格式的创建参数
第二列(Code)为该格式在GDAL中的代码,也是驱动的名称,
第三列(Creation)代表该格式是否支持创建影像
第四列(Georeferencing)未知,可能是指是否支持对该格式赋予空间信息
第五列(Maximum file size)为影像大小限制
第六列(Compiled by default)指是否默认支持该格式,还是需要其它插件的支持
 
2:获取驱动
在GDAL中创建影像,先需要明确待创建影像的格式,并获取到该影像格式的驱动:
Driver d = Gdal.GetDriverByName("HFA");
使用该函数获取影像格式的驱动,其中参数为驱动名称,可以在上文中表格第二列查得,例如HFA即为Erdas Img的驱动名
 
3:驱动的属性(元数据)
对每一种驱动(Driver),都有一些属性,通过d.GetMetadata("")可以获取到,结果是一个字符串数组,内容与网页上查到的基本相同,包括:是否允许创建,是否拷贝创建,支持的像素浓度类型,支持的创建参数等
 
4:调用Create函数创建影像
获取驱动后,使用d.Create(string uft8_path,int xSize,int ySize,int bands,DataType eType,string[] options)函数即可创建影像
该函数的参数为:
uft8_path:影像路径
xSize:宽度(像素值)
ySize:高度
bands:波段数
DataType:像素深度,可以设为Byte,Float,Int等等
options:创建影像的可选项设置,GDAL对不同的格式设置了不同的创建参数,详细信息参考上文中影像格式的介绍
 
该函数返回值为Dataset,与上一篇文件中打开影像得到的Dataset相同,可以在此基础上对影像数据进行操作
Create函数的示例代码:
1)Dataset dsout = d.Create(this.cut_savePathBox.Text, width, height, bands.Length, DataType.GDT_Byte, null);
2)Dataset dsout = d.Create(this.cut_savePathBox.Text, width, height, bands.Length, DataType.GDT_Byte, n new string[] { "AUX=YES", "STATISTICS=YES" });
 
5:调用CreateCopy函数进行拷贝创建
CreateCopy函数支持从已打开的影像创建一个拷贝的影像,保留原影像的一些基本信息,例如宽高,波段数,坐标,偏移等
d.CreateCopy(string utf8_path,Dataset src,int strict,string [] options,GDALProcessFuncDelegate callback,string callback_data)
参数如下:
utf8_path:路径
src:打开的影像数据
strict:取值是0或者1,取值为非的时候说明即使不能精确匹配地由原数据转化为目标数据，程序也照样执行CreateCopy方法，不会产生致命错误。这种错误有可能是输出格式不支持输入数据格式象元的数据类型，或者是目标数据不支持写入空间参考等等[该参数介绍转自http://www.gissky.net/Article/645.htm]
options:与Create函数相同
callback,callback_data:传入一个委托,可用于实时显示创建数据的进度,不需要时可设为NULL
 
例如:Dataset ds = d.CreateCopy(path,dsin,1,null,null,null);
