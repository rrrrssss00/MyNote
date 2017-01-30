ArcGIS Engine栅格数据使用总结
1、栅格数据的存储类型
 
栅格数据一般可以存储为ESRI GRID（由一系列文件组成），TIFF格式（包括一个TIF文件和一个AUX文件），IMAGINE Image格式 在AE中一般调用ISaveAs接口来保存栅格数据
 
2、栅格数据集和栅格编目的区别
 
一个栅格数据集由一个或者多个波段（RasterBand）的数据组成，一个波段就是一个数据矩阵。对于格网数据（DEM数据）和单波段的影像数据，表现为仅仅只有一个波段数据的栅格数据集，而对于多光谱影像数据则表现为具有多个波段的栅格数据集
 
栅格编目（RasterCatalog）用于显示某个研究区域内各种相邻的栅格数据，这些相邻的栅格数据没有经过拼接处理合成一副大的影像图
 
3、IRasterWorkspaceEx与IRasterWorkspace ,IRsterWorkspace2的区别
 
1).IRasteWorkspaceEx接口主要是用来读取GeoDatabase中的栅格数据集和栅格编目
 
2) . IRasterWorkspace ,IRsterWorkspace2主要是用来读取以文件格式存储在本地的栅格数据
 
4、加载栅格数据（以存储在本地的栅格数据文件为例）
 
1.直接用IRasterLayer接口打开一个栅格文件并加载到地图控件
 
    IRasterLayer rasterLayer = new RasterLayerClass();
    rasterLayer.CreateFromFilePath(fileName); // fileName指存本地的栅格文件路径
    axMapControl1.AddLayer(rasterLayer, 0);
 
 
2. 用IRasterDataset接口打开一个栅格数据集
 
    IWorkspaceFactory workspaceFactory = new RasterWorkspaceFactory();
    IWorkspace workspace;
    workspace = workspaceFactory.OpenFromFile(inPath, 0); //inPath栅格数据存储路径
    if (workspace == null)
    {
    Console.WriteLine("Could not open the workspace.");
    return;
    }
    IRasterWorkspace rastWork = (IRasterWorkspace)workspace;
    IRasterDataset rastDataset;
    rastDataset= rastWork.OpenRasterDataset(inName);//inName栅格文件名
    if (rastDataset == null)
    {
    Console.WriteLine("Could not open the raster dataset.");
    return;
    }
 
 
5、如何读取栅格数据的属性和遍历栅格数据
 
栅格数据的属性包括栅格大小，行数，列数，投影信息，栅格范围等等，见下面代码
（假设当前加载的栅格文件栅格值存储方式为：UShort类型）
 
    IRasterProps rasterProps = (IRasterProps)clipRaster;
    int dHeight = rasterProps.Height;//当前栅格数据集的行数
    int dWidth = rasterProps.Width; //当前栅格数据集的列数
    double dX = rasterProps.MeanCellSize().X; //栅格的宽度
    double dY = rasterProps.MeanCellSize().Y; //栅格的高度
    IEnvelope extent=rasterProps.Extent; //当前栅格数据集的范围
    rstPixelType pixelType=rasterProps.PixelType; //当前栅格像素类型
    IPnt pntSize = new PntClass();
    pntSize.SetCoords(dX, dY);
    IPixelBlock pixelBlock = clipRaster.CreatePixelBlock(pntSize);
    IPnt pnt = new PntClass();
    for (int i = 0; i < dHeight; i++)
    for (int j = 0; j < dWidth; j++)
    {
    pnt.SetCoords(i, j);
    clipRaster.Read(pnt, pixelBlock);
    if (pixelBlock != null)
    {
    object obj = pixelBlock.GetVal(0, 0, 0);
    MessageBox.Show( Convert.ToUInt32(obj).ToString());
    }
    }
 
 
6、如何提取指定的范围的栅格数据
 
提取指定范围内的栅格数据通常用两种方法IRasterLayerExport(esriCarto), IExtractionOp, IExtractionOp2 (esriSpatialAnalyst)，IRasterLayerExport接口提供的栅格数据提取功能有限，只能以矩形范围作为提取范围，而IExtractionOp接口提供了多边形，圆，属性，矩形等几种形式作为提取栅格数据.
 
1).IRasterLayerExport接口
 
    IRasterLayerExport rLayerExport = new RasterLayerExportClass();
    rLayerExport.RasterLayer = rasterLayer;// rasterLayer指当前加载的栅格图层
    rLayerExport.Extent = clipExtent;//clipExtent指提取栅格数据的范围
    if (proSpatialRef != null)
    rLayerExport.SpatialReference = proSpatialRef;// proSpatialRef当前栅格数据的投影信息
    IWorkspaceFactory pWF = new RasterWorkspaceFactoryClass();
    try
    {
    IWorkspace pRasterWorkspace = pWF.OpenFromFile(_folder, 0);// _folder指栅格文件保存路径
    IRasterDataset outGeoDataset = rLayerExport.Export(pRasterWorkspace, code, strRasterType);
    //调用ISaveAs接口将导出的数据集保存
    ……………………..
    }
    Catch(Exception ex)
    {
    Throw new Argumention(ex.Message);
    }
 
 
2．IExtractionOp接口(调用此接口前，应该先检查空间许可)
 
    IExtractionOp extraction = new RasterExtractionOpClass();
    try
    {
    IGeoDataset geoDataset = extraction.Rectangle((IGeoDataset)clipRaster, clipExtent, true);
    IRaster raster = geoDataset as IRaster;
    if (raster != null)
    {
    IWorkspaceFactory WF = new RasterWorkspaceFactoryClass();
    IWorkspace rasterWorkspace = WF.OpenFromFile(_folder, 0);
    ISaveAs saveAs = (ISaveAs)raster;
    saveAs.SaveAs(“Result.tif”, rasterWorkspace, "TIFF");
    }
    }
    catch (Exception ex)
    {
    MessageBox..Show(Ex.message);
    }
 
 
7．栅格数据重采样
 
栅格数据的重采样主要基于三种方法：最邻近采样（NEAREST），双线性
ILINEAR）和三次卷积采样（CUBIC）。
（1）.最邻近采样：它用输入栅格数据中最临近栅格值作为输出值。因此，在重采
样后的输出栅格中的每个栅格值, 都是输入栅格数据中真实存在而未加任何改变的值。这种方法简单易用，计算量小，重采样的速度最快。
（2）.双线性采样：此重采样法取待采样点（x，y）点周围四个邻点，在y方向（或X方向）内插两次，再在x方向（或y方向）内插一次，得到（x，y）点的栅格值。
（3）.三次卷积采样：这是进一步提高内插精度的一种方法。它的基本思想是增加邻点来获
得最佳插值函数。取待计算点周围相邻的16个点，与双线性采样类似，可先在某一方向上内插，如先在x方向上，每四个值依次内插四次，再根据四次的计算结果在y方上内插，最终得到内插结果
 
代码示例：采用双线性采样
 
    IRasterGeometryProc rasterGeometryProc = new RasterGeometryProcClass();
    rasterGeometryProc.Resample(rstResamplingTypes.RSP_CubicConvolution, newCellSize, clipRaster);
 
 
ArcGIS Engine 中对栅格数据的波段信息统计
 
先打开栅格文件所在的工作空间(文件),然后获取其所有的波段,访问每一个波段
有时候波段中已经有直方图或统计信息,有时候没有这些信息,可以使用ComputeStatsAndHist()函数对其进行计算
(数据量较大时,可能耗时较长)
 
IWorkspaceFactory workspaceFactory = new RasterWorkspaceFactory();
IWorkspace workspace;
workspace = workspaceFactory.OpenFromFile(filePath, 0);
 
IRasterWorkspace rastWork = (IRasterWorkspace)workspace;
IRasterDataset rastDataset = rastWork.OpenRasterDataset(pathBox.Text.Substring(pathBox.Text.LastIndexOf("\\") + 1));
IRasterDataset2 rd2 = rastDataset as IRasterDataset2;
IRaster raster = rd2.CreateFullRaster();
IRasterBandCollection rbc = (IRasterBandCollection)raster;
for (int i = 0; i < rbc.Count; i++)
{
    IRasterBand rb = rbc.Item(i);
    bool tmpBool ;
    rb.HasStatistics(out tmpBool);
    if(!tmpBool)
        rb.ComputeStatsAndHist();
    IRasterHistogram rh = rb.Histogram;
    IRasterStatistics rs = rb.Statistics;
}
