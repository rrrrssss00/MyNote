使用C#实现，主代码如下（其中Block类保存了一个方形范围内的浓度分布，内部有坐标范围，行列号以及浓度等信息，其定义在最下方）：
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using DotSpatial.Data;
namespace GISMODEL.Util
{
    /// <summary>
    /// 使用Marching squares算法进行等值面渲染的类(http://www.cnblogs.com/easymind223/p/3849481.html)+(https://en.wikipedia.org/wiki/Marching_squares)
    /// </summary>
    public class ContourBandClass
    {
        //todo：可以添加色系之类的参数
        /// <summary>
        /// 根据输入的参数，进行等值面渲染，并生成图片
        /// </summary>
        /// <param name="path">生成图片的路径</param>
        /// <param name="blocks">传入的浓度分布</param>
        /// <param name="conName">需要生成的污染物名称</param>
        /// <param name="bandLevelBPs">等值面划分区间的断点值（比实际区间数量小1）</param>
        /// <param name="outExtent">目标区域的坐标范围</param>
        /// <param name="pixelSize">生成的图片中，每个像素代表的实际长度</param>
        public static void GenPic(string path, Dictionary<string, Block> blocks, string conName, List<double> bandLevelBPs, Extent outExtent, double pixelSize)
        { 
            //todo:多级网格之类的功能由于没有示例数据暂时还没有做
            //生成图片的大小
            int needWidth = (int)(outExtent.Width / pixelSize) + 1;
            int needHeight = (int)(outExtent.Height / pixelSize) + 1;
            #region 生成的BitMap及相应的Graphic对象
           
            Bitmap TempBitmap = new Bitmap(needWidth, needHeight);
            Graphics gra = Graphics.FromImage(TempBitmap);
            gra.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighSpeed;
            gra.Clear(Color.Transparent);
            //Rectangle rect = new Rectangle(0, 0, needWidth, needHeight);
            //System.Drawing.Imaging.BitmapData bmpData = TempBitmap.LockBits(rect, System.Drawing.Imaging.ImageLockMode.ReadWrite, TempBitmap.PixelFormat);
            //IntPtr ptr = bmpData.Scan0;
            //int bytes = TempBitmap.Width * TempBitmap.Height * 4;
            //byte[] rgbValues = new byte[bytes];
            //System.Runtime.InteropServices.Marshal.Copy(ptr, rgbValues, 0, bytes);
            #endregion
            #region 根据Block数据在图片中进行填充绘制
            //先在bandLevels前后各加一个要素
            List<double> expandBandLevels = new List<double>();
            expandBandLevels.Add(double.MinValue);                //对小于最小断点的部分进行一次填充（填充为透明）
            for (int i = 0; i < bandLevelBPs.Count; i++)
                expandBandLevels.Add(bandLevelBPs[i]);
            expandBandLevels.Add(double.MaxValue);              //加上这个是为了对于大于最大断点的部分进行填充（填充为最高级别的颜色）
            //循环，每个区间生成一次
            for (int currenLevel = 0; currenLevel < expandBandLevels.Count-1; currenLevel++)
            {
                if (currenLevel == 0) continue;             //本来应该对小于最小断点的部分进行一次填充（填充为透明），但由于之前生成Grapphics对象时，已经将整体置为透明了，这一步可以不用处理
                //if (currenLevel != 1) continue;
                //区间最大浓度和最小浓度
                double lowerValue = expandBandLevels[currenLevel];
                double upperValue = expandBandLevels[currenLevel + 1];
                Color currentColor = CalColor(currenLevel, expandBandLevels.Count - 1);
                SolidBrush currentBrush = new SolidBrush(currentColor);
                foreach (Block currentBlk in blocks.Values)
                {
                    double centerVal = currentBlk.centerValues[conName];
                    #region 获取周边八个Block的浓度值，作为计算依据
                    double blkVal1,blkVal2,blkVal3,blkVal4,blkVal5,blkVal6,blkVal7,blkVal8;
                    Block tmpBlk = GetBlockByRowCol(blocks, currentBlk.rowNo - 1, currentBlk.colNo - 1);
                    if (tmpBlk == null) blkVal1 = currentBlk.centerValues[conName];
                    else blkVal1 = tmpBlk.centerValues[conName];
                    tmpBlk = GetBlockByRowCol(blocks, currentBlk.rowNo - 1, currentBlk.colNo );
                    if (tmpBlk == null) blkVal2 = currentBlk.centerValues[conName];
                    else blkVal2 = tmpBlk.centerValues[conName];
                    tmpBlk = GetBlockByRowCol(blocks, currentBlk.rowNo - 1, currentBlk.colNo + 1);
                    if (tmpBlk == null) blkVal3 = currentBlk.centerValues[conName];
                    else blkVal3 = tmpBlk.centerValues[conName];
                    tmpBlk = GetBlockByRowCol(blocks, currentBlk.rowNo , currentBlk.colNo - 1);
                    if (tmpBlk == null) blkVal4 = currentBlk.centerValues[conName];
                    else blkVal4 = tmpBlk.centerValues[conName];
                    tmpBlk = GetBlockByRowCol(blocks, currentBlk.rowNo , currentBlk.colNo + 1);
                    if (tmpBlk == null) blkVal5 = currentBlk.centerValues[conName];
                    else blkVal5 = tmpBlk.centerValues[conName];
                    tmpBlk = GetBlockByRowCol(blocks, currentBlk.rowNo + 1, currentBlk.colNo - 1);
                    if (tmpBlk == null) blkVal6 = currentBlk.centerValues[conName];
                    else blkVal6 = tmpBlk.centerValues[conName];
                    tmpBlk = GetBlockByRowCol(blocks, currentBlk.rowNo + 1, currentBlk.colNo );
                    if (tmpBlk == null) blkVal7 = currentBlk.centerValues[conName];
                    else blkVal7 = tmpBlk.centerValues[conName];
                    tmpBlk = GetBlockByRowCol(blocks, currentBlk.rowNo + 1, currentBlk.colNo + 1);
                    if (tmpBlk == null) blkVal8 = currentBlk.centerValues[conName];
                    else blkVal8= tmpBlk.centerValues[conName];
                    #endregion
                    //计算四个角点的浓度值(周边四个Block的值取平均)
                    double pnt1Val = (blkVal1 + blkVal2 + blkVal4 + centerVal) / 4;
                    double pnt2Val = (blkVal2 + blkVal3 + centerVal + blkVal5) / 4;
                    double pnt3Val = (blkVal4 + centerVal + blkVal6 + blkVal7) / 4;
                    double pnt4Val = (centerVal + blkVal5 + blkVal7 + blkVal8) / 4;
                    //List<double> pntVals = new List<double>() { pnt1Val, pnt2Val, pnt4Val, pnt3Val }; //1243的顺序
                    List<double> pntVals = new List<double>() { pnt3Val, pnt4Val, pnt2Val, pnt1Val }; //3421的顺序(按Marching squares算法，顺序应该是左上，右上，右下，左下，而本程序里的BLock序号是从左下开始向右向上编的，所以应该是3421)
                    //计算四个角点及中心点的Level代码(大于upperValue为2，小于lowerValue为0，两者之间为1)
                    int pnt1Code = CalLevelCode(pnt1Val, lowerValue, upperValue);
                    int pnt2Code = CalLevelCode(pnt2Val, lowerValue, upperValue);
                    int pnt3Code = CalLevelCode(pnt3Val, lowerValue, upperValue);
                    int pnt4Code = CalLevelCode(pnt4Val, lowerValue, upperValue);
                    int centerCode = CalLevelCode(centerVal, lowerValue, upperValue);
                    //计算Block区域对应像素范围，X,Y方向最小值及两方向像素数
                    int currentBlkMinPixelX = (int)((currentBlk.minX - outExtent.MinX) / pixelSize);
                    int currentBlkMinPixelY = (int)((outExtent.MaxY - currentBlk.maxY) / pixelSize);
                    int currentBlkPixelsInWidth = (int)((currentBlk.maxX - outExtent.MinX) / pixelSize) - currentBlkMinPixelX;
                    int currentBlkPixelsInHeight = (int)((outExtent.MaxY - currentBlk.minY) / pixelSize)  - currentBlkMinPixelY;
                    //string tmpCornerCode = pnt1Code + "" + pnt2Code + pnt4Code + pnt3Code;      //1243的顺序
                    string tmpCornerCode = "" + pnt3Code + pnt4Code + pnt2Code + pnt1Code;      //3421的顺序
                    List<PointF[]> currentPolygonPntLsts = GetPolygonByCode(tmpCornerCode, centerCode, pntVals, lowerValue, upperValue, currentBlkMinPixelX, currentBlkMinPixelY, currentBlkPixelsInWidth, currentBlkPixelsInHeight);
                    if (currentPolygonPntLsts == null) continue;
                                      
                    for (int i = 0; i < currentPolygonPntLsts.Count; i++)
                    {
                        gra.FillPolygon(currentBrush, currentPolygonPntLsts[i]);
                    }
                }
            }
            #region 保存图片
            //System.Runtime.InteropServices.Marshal.Copy(rgbValues, 0, ptr, bytes);
            //TempBitmap.UnlockBits(bmpData);
            float istransparent = 0.7f;
            Bitmap bmpTemp = new Bitmap(TempBitmap);//此处报内存不足（风险评估）0527
            Graphics g = Graphics.FromImage(bmpTemp);
            g.Clear(Color.Transparent);
            float[][] ptsArray ={ 
                            new float[] {1, 0, 0, 0, 0},
                            new float[] {0, 1, 0, 0, 0},
                            new float[] {0, 0, 1, 0, 0},
                            new float[] {0, 0, 0, istransparent, 0}, //f，图像的透明度
                            new float[] {0, 0, 0, 0, 1}};
            ColorMatrix clrMatrix = new ColorMatrix(ptsArray);
            ImageAttributes imgAttributes = new ImageAttributes();
            imgAttributes.SetColorMatrix(clrMatrix, ColorMatrixFlag.Default, ColorAdjustType.Bitmap);
            g.DrawImage(TempBitmap, new Rectangle(0, 0, TempBitmap.Width, TempBitmap.Height), 0, 0, TempBitmap.Width, TempBitmap.Height,
                GraphicsUnit.Pixel, imgAttributes);
            TempBitmap.Dispose();
            gra.Dispose();
            g.Dispose();
            GC.Collect();
            try
            {
                bmpTemp.Save(path, System.Drawing.Imaging.ImageFormat.Png);
            }
            finally
            {
                TempBitmap.Dispose();
                bmpTemp.Dispose();
                gra.Dispose();
                g.Dispose();
                GC.Collect();
            }
            #endregion
            #endregion
        }
        /// <summary>
        /// 通过传入的四角点代码以及中心的代码，获取Block内部需要填充的区域（用点集表示）
        /// </summary>
        /// <param name="cornerCode">四角点代码</param>
        /// <param name="centerCode">中心代码</param>
        /// <param name="pntVals">四角点的浓度值</param>
        /// <param name="lowerValue">区间最小浓度</param>
        /// <param name="upperValue">区间最大浓度</param>
        /// <param name="minPixelX">Block区域对应最小的像素坐标X</param>
        /// <param name="minPixelY">Block区域对应最小的像素坐标Y</param>
        /// <param name="pixelsInWidth">Block区域对应宽方向像素数</param>
        /// <param name="pixelsInHeight">Block区域对应高方向像素数</param>
        /// <returns>需要填充的区域</returns>
        private static List<PointF[]> GetPolygonByCode(string cornerCode, int centerCode,List<double> pntVals,double lowerValue,double upperValue,int minPixelX,int minPixelY,int pixelsInWidth,int pixelsInHeight)
        {
            List<PointF[]> resArrayLst = new List<PointF[]>();
            switch (cornerCode)
            {
                case "0000": return null;
                case "2222": return null;
                case "1111":
                    #region 1111状态
                    PointF[] resArray = new PointF[4];
                    resArray[0] = new PointF(minPixelX, minPixelY);
                    resArray[1] = new PointF(minPixelX + pixelsInWidth, minPixelY);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth, minPixelY + pixelsInHeight);
                    resArray[3] = new PointF(minPixelX, minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst; 
                    #endregion
                #region 填充三角形，8种情况
                case "2221":
                    #region 2221状态
                    resArray = new PointF[3];
                    resArray[0] = new PointF(minPixelX, minPixelY + pixelsInHeight);
                    resArray[1] = new PointF(minPixelX, minPixelY + pixelsInHeight - (float)((upperValue - pntVals[3]) / (pntVals[0] - pntVals[3]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst; 
                    #endregion
                case "2212":
                    #region 2212状态
                    resArray = new PointF[3];
                    resArray[0] = new PointF(minPixelX + pixelsInWidth, minPixelY + pixelsInHeight);
                    resArray[1] = new PointF(minPixelX + pixelsInWidth, minPixelY + pixelsInHeight - (float)((upperValue - pntVals[2]) / (pntVals[1] - pntVals[2]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + pixelsInWidth - (float)((upperValue - pntVals[2]) / (pntVals[3] - pntVals[2]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst; 
                    #endregion
                case "2122":
                    #region 2122状态
                    resArray = new PointF[3];
                    resArray[0] = new PointF(minPixelX + pixelsInWidth, minPixelY );
                    resArray[1] = new PointF(minPixelX + pixelsInWidth, minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + pixelsInWidth - (float)((upperValue - pntVals[1]) / (pntVals[0] - pntVals[1]) * pixelsInWidth), minPixelY);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "1222":
                    #region 1222状态
                    resArray = new PointF[3];
                    resArray[0] = new PointF(minPixelX , minPixelY);
                    resArray[1] = new PointF(minPixelX , minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "0001":
                    #region 0001状态
                    resArray = new PointF[3];
                    resArray[0] = new PointF(minPixelX, minPixelY + pixelsInHeight);
                    resArray[1] = new PointF(minPixelX, minPixelY + pixelsInHeight - (float)((lowerValue - pntVals[3]) / (pntVals[0] - pntVals[3]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "0010":
                    #region 0010状态
                    resArray = new PointF[3];
                    resArray[0] = new PointF(minPixelX + pixelsInWidth, minPixelY + pixelsInHeight);
                    resArray[1] = new PointF(minPixelX + pixelsInWidth, minPixelY + pixelsInHeight - (float)((lowerValue - pntVals[2]) / (pntVals[1] - pntVals[2]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + pixelsInWidth - (float)((lowerValue - pntVals[2]) / (pntVals[3] - pntVals[2]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "0100":
                    #region 0100状态
                    resArray = new PointF[3];
                    resArray[0] = new PointF(minPixelX + pixelsInWidth, minPixelY);
                    resArray[1] = new PointF(minPixelX + pixelsInWidth, minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + pixelsInWidth - (float)((lowerValue - pntVals[1]) / (pntVals[0] - pntVals[1]) * pixelsInWidth), minPixelY);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "1000":
                    #region 1000状态
                    resArray = new PointF[3];
                    resArray[0] = new PointF(minPixelX, minPixelY);
                    resArray[1] = new PointF(minPixelX, minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion 
                #endregion
                #region 填充梯形，8种情况
                case "2220":
                    #region 2220状态
                    resArray = new PointF[4];
                    resArray[0] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight - (float)((upperValue - pntVals[3]) / (pntVals[0] - pntVals[3]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight - (float)((lowerValue - pntVals[3]) / (pntVals[0] - pntVals[3]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[3] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "2202":
                    #region 2202状态
                    resArray = new PointF[4];
                    resArray[0] = new PointF(minPixelX + pixelsInWidth,                                                                                minPixelY + pixelsInHeight - (float)((upperValue - pntVals[2]) / (pntVals[1] - pntVals[2]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX + pixelsInWidth,                                                                                minPixelY + pixelsInHeight - (float)((lowerValue - pntVals[2]) / (pntVals[1] - pntVals[2]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + pixelsInWidth - (float)((lowerValue - pntVals[2]) / (pntVals[3] - pntVals[2]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[3] = new PointF(minPixelX + pixelsInWidth - (float)((upperValue - pntVals[2]) / (pntVals[3] - pntVals[2]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "2022":
                    #region 2022状态
                    resArray = new PointF[4];
                    resArray[0] = new PointF(minPixelX + pixelsInWidth,                                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX + pixelsInWidth,                                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + pixelsInWidth - (float)((lowerValue - pntVals[1]) / (pntVals[0] - pntVals[1]) * pixelsInWidth), minPixelY);
                    resArray[3] = new PointF(minPixelX + pixelsInWidth - (float)((upperValue - pntVals[1]) / (pntVals[0] - pntVals[1]) * pixelsInWidth), minPixelY);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "0222":
                    #region 0222状态
                    resArray = new PointF[4];
                    resArray[0] = new PointF(minPixelX ,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX ,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth),  minPixelY);
                    resArray[3] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth),  minPixelY);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "0002":
                    #region 0002状态
                    resArray = new PointF[4];
                    resArray[0] = new PointF(minPixelX,                                                                                 minPixelY + pixelsInHeight - (float)((upperValue - pntVals[3]) / (pntVals[0] - pntVals[3]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX,                                                                                 minPixelY + pixelsInHeight - (float)((lowerValue - pntVals[3]) / (pntVals[0] - pntVals[3]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth),  minPixelY + pixelsInHeight);
                    resArray[3] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth),  minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "0020":
                    #region 0020状态
                    resArray = new PointF[4];
                    resArray[0] = new PointF(minPixelX + pixelsInWidth,                                                                                 minPixelY + pixelsInHeight - (float)((upperValue - pntVals[2]) / (pntVals[1] - pntVals[2]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX + pixelsInWidth,                                                                                 minPixelY + pixelsInHeight - (float)((lowerValue - pntVals[2]) / (pntVals[1] - pntVals[2]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + pixelsInWidth - (float)((lowerValue - pntVals[2]) / (pntVals[3] - pntVals[2]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[3] = new PointF(minPixelX + pixelsInWidth - (float)((upperValue - pntVals[2]) / (pntVals[3] - pntVals[2]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "0200":
                    #region 0200状态
                    resArray = new PointF[4];
                    resArray[0] = new PointF(minPixelX + pixelsInWidth,                                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX + pixelsInWidth,                                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + pixelsInWidth - (float)((lowerValue - pntVals[1]) / (pntVals[0] - pntVals[1]) * pixelsInWidth), minPixelY);
                    resArray[3] = new PointF(minPixelX + pixelsInWidth - (float)((upperValue - pntVals[1]) / (pntVals[0] - pntVals[1]) * pixelsInWidth), minPixelY);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "2000":
                    #region 2000状态
                    resArray = new PointF[4];
                    resArray[0] = new PointF(minPixelX ,                                                                               minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX ,                                                                               minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[3] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                #endregion
                #region 矩形填充，12种情况
                case "0011":
                    #region 0011状态
                    resArray = new PointF[4];
                    resArray[0] = new PointF(minPixelX ,                minPixelY + pixelsInHeight);
                    resArray[1] = new PointF(minPixelX + pixelsInWidth, minPixelY + pixelsInHeight);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth, minPixelY + pixelsInHeight - (float)((lowerValue - pntVals[2]) / (pntVals[1] - pntVals[2]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX ,                minPixelY + pixelsInHeight - (float)((lowerValue - pntVals[3]) / (pntVals[0] - pntVals[3]) * pixelsInHeight));
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "0110":
                    #region 0110状态
                    resArray = new PointF[4];
                    resArray[0] = new PointF(minPixelX + pixelsInWidth,                                                                                 minPixelY );
                    resArray[1] = new PointF(minPixelX + pixelsInWidth,                                                                                 minPixelY + pixelsInHeight);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth - (float)((lowerValue - pntVals[2]) / (pntVals[3] - pntVals[2]) * pixelsInWidth),  minPixelY + pixelsInHeight);
                    resArray[3] = new PointF(minPixelX + pixelsInWidth - (float)((lowerValue - pntVals[1]) / (pntVals[0] - pntVals[1]) * pixelsInWidth),  minPixelY);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "1100":
                    #region 1100状态
                    resArray = new PointF[4];
                    resArray[0] = new PointF(minPixelX ,                 minPixelY );
                    resArray[1] = new PointF(minPixelX + pixelsInWidth,  minPixelY );
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,  minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX,                  minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "1001":
                    #region 1001状态
                    resArray = new PointF[4];
                    resArray[0] = new PointF(minPixelX ,                                                                                 minPixelY );
                    resArray[1] = new PointF(minPixelX ,                                                                                 minPixelY + pixelsInHeight);
                    resArray[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[3] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "2211":
                    #region 2211状态
                    resArray = new PointF[4];
                    resArray[0] = new PointF(minPixelX ,                minPixelY + pixelsInHeight);
                    resArray[1] = new PointF(minPixelX + pixelsInWidth, minPixelY + pixelsInHeight);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth, minPixelY + pixelsInHeight - (float)((upperValue - pntVals[2]) / (pntVals[1] - pntVals[2]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX,                 minPixelY + pixelsInHeight - (float)((upperValue - pntVals[3]) / (pntVals[0] - pntVals[3]) * pixelsInHeight));
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "2112":
                    #region 2112状态
                    resArray = new PointF[4];
                    resArray[0] = new PointF(minPixelX + pixelsInWidth,                                                                                 minPixelY );
                    resArray[1] = new PointF(minPixelX + pixelsInWidth,                                                                                 minPixelY + pixelsInHeight);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth - (float)((upperValue - pntVals[2]) / (pntVals[3] - pntVals[2]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[3] = new PointF(minPixelX + pixelsInWidth - (float)((upperValue - pntVals[1]) / (pntVals[0] - pntVals[1]) * pixelsInWidth), minPixelY);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "1122":
                    #region 1122状态
                    resArray = new PointF[4];
                    resArray[0] = new PointF(minPixelX ,                 minPixelY );
                    resArray[1] = new PointF(minPixelX + pixelsInWidth,  minPixelY );
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,  minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX,                  minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "1221":
                    #region 1221状态
                    resArray = new PointF[4];
                    resArray[0] = new PointF(minPixelX ,                                                                                 minPixelY );
                    resArray[1] = new PointF(minPixelX ,                                                                                 minPixelY + pixelsInHeight);
                    resArray[2] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[3] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "2200":
                    #region 2200状态
                    resArray = new PointF[4];
                    resArray[0] = new PointF(minPixelX ,                minPixelY + pixelsInHeight - (float)((upperValue - pntVals[3]) / (pntVals[0] - pntVals[3]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX ,                minPixelY + pixelsInHeight - (float)((lowerValue - pntVals[3]) / (pntVals[0] - pntVals[3]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + pixelsInWidth, minPixelY + pixelsInHeight - (float)((lowerValue - pntVals[2]) / (pntVals[1] - pntVals[2]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX + pixelsInWidth, minPixelY + pixelsInHeight - (float)((upperValue - pntVals[2]) / (pntVals[1] - pntVals[2]) * pixelsInHeight));
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "2002":
                    #region 2200状态
                    resArray = new PointF[4];
                    resArray[0] = new PointF(minPixelX + pixelsInWidth - (float)((upperValue - pntVals[1]) / (pntVals[0] - pntVals[1]) * pixelsInWidth), minPixelY);
                    resArray[1] = new PointF(minPixelX + pixelsInWidth - (float)((lowerValue - pntVals[1]) / (pntVals[0] - pntVals[1]) * pixelsInWidth), minPixelY);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth - (float)((lowerValue - pntVals[2]) / (pntVals[3] - pntVals[2]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[3] = new PointF(minPixelX + pixelsInWidth - (float)((upperValue - pntVals[2]) / (pntVals[3] - pntVals[2]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "0022":
                    #region 0022状态
                    resArray = new PointF[4];
                    resArray[0] = new PointF(minPixelX,                 minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX,                 minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + pixelsInWidth, minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX + pixelsInWidth, minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "0220":
                    #region 0220状态
                    resArray = new PointF[4];
                    resArray[0] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[1] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[3] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                #endregion
                #region 六角形填充，12种情况
                case "0211":
                    #region 0211状态
                    resArray = new PointF[6];
                    resArray[0] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth),  minPixelY);
                    resArray[1] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth),  minPixelY);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                 minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX + pixelsInWidth,                                                                 minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX ,                                                                                minPixelY + pixelsInHeight);
                    resArray[5] = new PointF(minPixelX,                                                                                 minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "2110":
                    #region 2110状态
                    resArray = new PointF[6];
                    resArray[0] = new PointF(minPixelX,                                                                                 minPixelY + pixelsInHeight - (float)((lowerValue - pntVals[3]) / (pntVals[0] - pntVals[3]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX,                                                                                 minPixelY + pixelsInHeight - (float)((upperValue - pntVals[3]) / (pntVals[0] - pntVals[3]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth),  minPixelY);
                    resArray[3] = new PointF(minPixelX + pixelsInWidth,                                                                 minPixelY );
                    resArray[4] = new PointF(minPixelX + pixelsInWidth,                                                                 minPixelY + pixelsInHeight);
                    resArray[5] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth),  minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "1102":
                    #region 1102状态
                    resArray = new PointF[6];
                    resArray[0] = new PointF(minPixelX,                                                                                 minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX,                                                                                 minPixelY);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                 minPixelY);
                    resArray[3] = new PointF(minPixelX + pixelsInWidth,                                                                 minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[4] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth),  minPixelY + pixelsInHeight);
                    resArray[5] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth),  minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion             
                case "1021":
                    #region 1021状态
                    resArray = new PointF[6];
                    resArray[0] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth),  minPixelY);
                    resArray[1] = new PointF(minPixelX + pixelsInWidth,                                                                 minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                 minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth),  minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX ,                                                                                minPixelY + pixelsInHeight);
                    resArray[5] = new PointF(minPixelX ,                                                                                minPixelY );
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "2011":
                    #region 2011状态
                    resArray = new PointF[6];
                    resArray[0] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth),  minPixelY);
                    resArray[1] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth),  minPixelY);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                 minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX + pixelsInWidth,                                                                 minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX ,                                                                                minPixelY + pixelsInHeight);
                    resArray[5] = new PointF(minPixelX,                                                                                 minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "0112":
                    #region 0112状态
                    resArray = new PointF[6];
                    resArray[0] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight - (float)((upperValue - pntVals[3]) / (pntVals[0] - pntVals[3]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight - (float)((lowerValue - pntVals[3]) / (pntVals[0] - pntVals[3]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY);
                    resArray[4] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + pixelsInHeight);
                    resArray[5] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "1120":
                    #region 1120状态
                    resArray = new PointF[6];
                    resArray[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX,                                                                                minPixelY);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY);
                    resArray[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[4] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[5] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion  
                case "1201":
                    #region 1201状态
                    resArray = new PointF[6];
                    resArray[0] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight);
                    resArray[5] = new PointF(minPixelX,                                                                                minPixelY);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "2101":
                    #region 2101状态
                    resArray = new PointF[6];
                    resArray[0] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY );
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight);
                    resArray[5] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "0121":
                    #region 0121状态
                    resArray = new PointF[6];
                    resArray[0] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight);
                    resArray[5] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "1012":
                    #region 1012状态
                    resArray = new PointF[6];
                    resArray[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX,                                                                                minPixelY );
                    resArray[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[4] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + pixelsInHeight);
                    resArray[5] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "1210":
                    #region 1210状态
                    resArray = new PointF[6];
                    resArray[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX,                                                                                minPixelY);
                    resArray[2] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[4] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + pixelsInHeight);
                    resArray[5] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                #endregion
                #region 五角形填充，24种情况
                case "1211":
                    #region 1211状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX,                                                                                minPixelY);
                    resArray[1] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst; 
                    #endregion
                case "2111":
                    #region 2111状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + pixelsInHeight);
                    resArray[3] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "1112":
                    #region 1112状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX ,                                                                               minPixelY);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY );
                    resArray[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "1121":
                    #region 1121状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[2] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight);
                    resArray[3] = new PointF(minPixelX ,                                                                               minPixelY );
                    resArray[4] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY );
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "1011":
                    #region 1011状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX,                                                                                minPixelY);
                    resArray[1] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "0111":
                    #region 0111状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + pixelsInHeight);
                    resArray[3] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "1110":
                    #region 11102状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX,                                                                                minPixelY);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY);
                    resArray[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "1101":
                    #region 1101状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[2] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight);
                    resArray[3] = new PointF(minPixelX,                                                                                minPixelY);
                    resArray[4] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "1200":
                    #region 1200状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX,                                                                                minPixelY);
                    resArray[1] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY );
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[4] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "0120":
                    #region 0120状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "0012":
                    #region 0012状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "2001":
                    #region 2001状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY );
                    resArray[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY );
                    resArray[3] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX ,                                                                               minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "1022":
                    #region 1022状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX,                                                                                minPixelY);
                    resArray[1] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[4] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "2102":
                    #region 2102状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "2210":
                    #region 2210状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "0221":
                    #region 0221状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[2] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[3] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "1002":
                    #region 1002状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX ,                                                                               minPixelY);
                    resArray[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[3] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "2100":
                    #region 2100状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY );
                    resArray[4] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "0210":
                    #region 0210状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[1] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "0021":
                    #region 0021状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX ,                                                                               minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "1220":
                    #region 1220状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX,                                                                                minPixelY);
                    resArray[2] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[3] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "0122":
                    #region 0122状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY);
                    resArray[4] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "2012":
                    #region 2012状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[1] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                case "2201":
                    #region 2201状态
                    resArray = new PointF[5];
                    resArray[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                    resArray[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                    resArray[3] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                    resArray[4] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight);
                    resArrayLst.Add(resArray);
                    return resArrayLst;
                    #endregion
                #endregion
                #region 复杂情况填充，14种情况
                #region 8面，2种情况，3分支
                case "2020":
                    #region 2020状态
                    if (centerCode == 0)
                    {
                        PointF[] resArray1 = new PointF[4];
                        resArray1[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[1] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[3] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY); 
                        resArrayLst.Add(resArray1);
                        PointF[] resArray2 = new PointF[4];
                        resArray2[0] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray2[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray2[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray2[3] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArrayLst.Add(resArray2);
                    }
                    else if (centerCode == 1)
                    {
                        PointF[] resArray1 = new PointF[8];
                        resArray1[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[1] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[2] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[3] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[4] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[5] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[6] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray1[7] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);                        
                        resArrayLst.Add(resArray1);
                    }
                    else
                    {
                        PointF[] resArray1 = new PointF[4];
                        resArray1[0] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY );
                        resArray1[1] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY );
                        resArray1[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArrayLst.Add(resArray1);
                        PointF[] resArray2 = new PointF[4];
                        resArray2[0] = new PointF(minPixelX ,                                                                               minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray2[1] = new PointF(minPixelX ,                                                                               minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray2[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray2[3] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArrayLst.Add(resArray2);
                    }
                    return resArrayLst;
                    #endregion
                case "0202":
                    #region 0202状态
                    if (centerCode == 0)
                    {
                        PointF[] resArray1 = new PointF[4];
                        resArray1[0] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[1] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArrayLst.Add(resArray1);
                        PointF[] resArray2 = new PointF[4];
                        resArray2[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray2[1] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray2[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray2[3] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArrayLst.Add(resArray2);
                    }
                    else if (centerCode == 1)
                    {
                        PointF[] resArray1 = new PointF[8];
                        resArray1[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[1] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[3] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[4] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[5] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[6] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray1[7] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArrayLst.Add(resArray1);
                    }
                    else
                    {
                        PointF[] resArray1 = new PointF[4];
                        resArray1[0] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[1] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArrayLst.Add(resArray1);
                        PointF[] resArray2 = new PointF[4];
                        resArray2[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray2[1] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray2[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray2[3] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArrayLst.Add(resArray2);
                         PointF[] resArray1 = new PointF[4];
                        //resArray1[0] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        //resArray1[1] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        //resArray1[2] = new PointF(minPixelX + pixelsInWidth, minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        //resArray1[3] = new PointF(minPixelX + pixelsInWidth, minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[0] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[1] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[2] = new PointF(minPixelX , minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[3] = new PointF(minPixelX , minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArrayLst.Add(resArray1);
 
                        PointF[] resArray2 = new PointF[4];
                        //resArray2[0] = new PointF(minPixelX, minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        //resArray2[1] = new PointF(minPixelX, minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        //resArray2[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        //resArray2[3] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray2[0] = new PointF(minPixelX + pixelsInWidth, minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray2[1] = new PointF(minPixelX + pixelsInWidth, minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray2[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray2[3] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArrayLst.Add(resArray2);
                    }
                    return resArrayLst;
                    #endregion
                #endregion
                #region 6面，4种情况，2分支
                case "0101":
                    #region 0101状态
                    if (centerCode == 0)
                    {
                        PointF[] resArray1 = new PointF[3];
                        resArray1[0] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY);
                        resArray1[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArrayLst.Add(resArray1);
                        PointF[] resArray2 = new PointF[3];
                        resArray2[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray2[1] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight);
                        resArray2[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArrayLst.Add(resArray2);
                    }
                    else if (centerCode >0)
                    {
                        PointF[] resArray1 = new PointF[6];
                        resArray1[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[1] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY);
                        resArray1[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[4] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray1[5] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight);
                        resArrayLst.Add(resArray1);
                    }
                    return resArrayLst;
                    #endregion
                case "1010":
                    #region 0101状态
                    if (centerCode == 0)
                    {
                        PointF[] resArray1 = new PointF[3];
                        resArray1[0] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray1[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + pixelsInHeight);
                        resArray1[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArrayLst.Add(resArray1);
                        PointF[] resArray2 = new PointF[3];
                        resArray2[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray2[1] = new PointF(minPixelX,                                                                                minPixelY );
                        resArray2[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY );
                        resArrayLst.Add(resArray2);
                    }
                    else if (centerCode >0)
                    {
                        PointF[] resArray1 = new PointF[6];
                        resArray1[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[1] = new PointF(minPixelX ,                                                                               minPixelY);
                        resArray1[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[4] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + pixelsInHeight);
                        resArray1[5] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArrayLst.Add(resArray1);
                    }
                    return resArrayLst;
                    #endregion
                case "2121":
                    #region 2121状态
                    if (centerCode == 2)
                    {
                        PointF[] resArray1 = new PointF[3];
                        resArray1[0] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY);
                        resArray1[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArrayLst.Add(resArray1);
                        PointF[] resArray2 = new PointF[3];
                        resArray2[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray2[1] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight);
                        resArray2[2] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArrayLst.Add(resArray2);
                    }
                    else if (centerCode <2)
                    {
                        PointF[] resArray1 = new PointF[6];
                        resArray1[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[1] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY);
                        resArray1[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[4] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray1[5] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight);
                        resArrayLst.Add(resArray1);
                    }
                    return resArrayLst;
                    #endregion
                case "1212":
                    #region 1212状态
                    if (centerCode == 2)
                    {
                        PointF[] resArray1 = new PointF[3];
                        resArray1[0] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray1[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + pixelsInHeight);
                        resArray1[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArrayLst.Add(resArray1);
                        PointF[] resArray2 = new PointF[3];
                        resArray2[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray2[1] = new PointF(minPixelX,                                                                                minPixelY );
                        resArray2[2] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArrayLst.Add(resArray2);
                    }
                    else if (centerCode <2)
                    {
                        PointF[] resArray1 = new PointF[6];
                        resArray1[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[1] = new PointF(minPixelX ,                                                                               minPixelY);
                        resArray1[2] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[4] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + pixelsInHeight);
                        resArray1[5] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArrayLst.Add(resArray1);
                    }
                    return resArrayLst;
                    #endregion
                #endregion
                #region 7面,8种情况，2分支
                case "2120":
                    #region 2120状态
                    if (centerCode == 2)
                    {
                        PointF[] resArray1 = new PointF[3];
                        resArray1[0] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY );
                        resArray1[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY );
                        resArray1[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArrayLst.Add(resArray1);
                        PointF[] resArray2 = new PointF[4];
                        resArray2[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray2[1] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray2[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray2[3] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArrayLst.Add(resArray2);
                    }
                    else if (centerCode <2)
                    {
                        PointF[] resArray1 = new PointF[7];
                        resArray1[0] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY);
                        resArray1[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[3] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray1[4] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray1[5] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[6] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArrayLst.Add(resArray1);
                    }
                    return resArrayLst;
                    #endregion
                case "2021":
                    #region 2021状态
                    if (centerCode == 2)
                    {
                        PointF[] resArray1 = new PointF[3];
                        resArray1[0] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray1[1] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight);
                        resArray1[2] = new PointF(minPixelX ,                                                                               minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArrayLst.Add(resArray1);
                        PointF[] resArray2 = new PointF[4];
                        resArray2[0] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY );
                        resArray2[1] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY );
                        resArray2[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray2[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArrayLst.Add(resArray2);
                    }
                    else if (centerCode <2)
                    {
                        PointF[] resArray1 = new PointF[7];
                        resArray1[0] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray1[1] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight);
                        resArray1[2] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[3] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[4] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[5] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[6] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArrayLst.Add(resArray1);
                    }
                    return resArrayLst;
                    #endregion
                case "1202":
                    #region 1202状态
                    if (centerCode == 2)
                    {
                        PointF[] resArray1 = new PointF[3];
                        resArray1[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[1] = new PointF(minPixelX,                                                                                minPixelY );
                        resArray1[2] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY );
                        resArrayLst.Add(resArray1);
                        PointF[] resArray2 = new PointF[4];
                        resArray2[0] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray2[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray2[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray2[3] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArrayLst.Add(resArray2);
                    }
                    else if (centerCode <2)
                    {
                        PointF[] resArray1 = new PointF[7];
                        resArray1[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[1] = new PointF(minPixelX,                                                                                minPixelY);
                        resArray1[2] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[4] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[5] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray1[6] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArrayLst.Add(resArray1);
                    }
                    return resArrayLst;
                    #endregion
                case "0212":
                    #region 0212状态
                    if (centerCode == 2)
                    {
                        PointF[] resArray1 = new PointF[3];
                        resArray1[0] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + pixelsInHeight);
                        resArray1[2] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArrayLst.Add(resArray1);
                        PointF[] resArray2 = new PointF[4];
                        resArray2[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray2[1] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray2[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray2[3] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArrayLst.Add(resArray2);
                    }
                    else if (centerCode <2)
                    {
                        PointF[] resArray1 = new PointF[7];
                        resArray1[0] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + pixelsInHeight);
                        resArray1[2] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray1[3] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[4] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[5] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[6] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArrayLst.Add(resArray1);
                    }
                    return resArrayLst;
                    #endregion
                case "0102":
                    #region 0102状态
                    if (centerCode == 0)
                    {
                        PointF[] resArray1 = new PointF[3];
                        resArray1[0] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY );
                        resArray1[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY );
                        resArray1[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArrayLst.Add(resArray1);
                        PointF[] resArray2 = new PointF[4];
                        resArray2[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray2[1] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray2[2] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray2[3] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArrayLst.Add(resArray2);
                    }
                    else if (centerCode >0)
                    {
                        PointF[] resArray1 = new PointF[7];
                        resArray1[0] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY);
                        resArray1[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[3] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray1[4] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray1[5] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[6] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArrayLst.Add(resArray1);
                    }
                    return resArrayLst;
                    #endregion
                case "0201":
                    #region 0201状态
                    if (centerCode == 0)
                    {
                        PointF[] resArray1 = new PointF[3];
                        resArray1[0] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray1[1] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight);
                        resArray1[2] = new PointF(minPixelX ,                                                                               minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArrayLst.Add(resArray1);
                        PointF[] resArray2 = new PointF[4];
                        resArray2[0] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY );
                        resArray2[1] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY );
                        resArray2[2] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray2[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArrayLst.Add(resArray2);
                    }
                    else if (centerCode >0)
                    {
                        PointF[] resArray1 = new PointF[7];
                        resArray1[0] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray1[1] = new PointF(minPixelX,                                                                                minPixelY + pixelsInHeight);
                        resArray1[2] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[3] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[4] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[5] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[6] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArrayLst.Add(resArray1);
                    }
                    return resArrayLst;
                    #endregion
                case "1020":
                    #region 1020状态
                    if (centerCode == 0)
                    {
                        PointF[] resArray1 = new PointF[3];
                        resArray1[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[1] = new PointF(minPixelX,                                                                                minPixelY );
                        resArray1[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY );
                        resArrayLst.Add(resArray1);
                        PointF[] resArray2 = new PointF[4];
                        resArray2[0] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray2[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray2[2] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray2[3] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArrayLst.Add(resArray2);
                    }
                    else if (centerCode >0)
                    {
                        PointF[] resArray1 = new PointF[7];
                        resArray1[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[1] = new PointF(minPixelX,                                                                                minPixelY);
                        resArray1[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[3] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[4] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((upperValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[5] = new PointF(minPixelX + (float)((upperValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray1[6] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArrayLst.Add(resArray1);
                    }
                    return resArrayLst;
                    #endregion
                case "2010":
                    #region 2010状态
                    if (centerCode == 0)
                    {
                        PointF[] resArray1 = new PointF[3];
                        resArray1[0] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + pixelsInHeight);
                        resArray1[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArrayLst.Add(resArray1);
                        PointF[] resArray2 = new PointF[4];
                        resArray2[0] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray2[1] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray2[2] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray2[3] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArrayLst.Add(resArray2);
                    }
                    else if (centerCode >0)
                    {
                        PointF[] resArray1 = new PointF[7];
                        resArray1[0] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + (float)((lowerValue - pntVals[1]) / (pntVals[2] - pntVals[1]) * pixelsInHeight));
                        resArray1[1] = new PointF(minPixelX + pixelsInWidth,                                                                minPixelY + pixelsInHeight);
                        resArray1[2] = new PointF(minPixelX + (float)((lowerValue - pntVals[3]) / (pntVals[2] - pntVals[3]) * pixelsInWidth), minPixelY + pixelsInHeight);
                        resArray1[3] = new PointF(minPixelX,                                                                                minPixelY + (float)((lowerValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[4] = new PointF(minPixelX,                                                                                minPixelY + (float)((upperValue - pntVals[0]) / (pntVals[3] - pntVals[0]) * pixelsInHeight));
                        resArray1[5] = new PointF(minPixelX + (float)((upperValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArray1[6] = new PointF(minPixelX + (float)((lowerValue - pntVals[0]) / (pntVals[1] - pntVals[0]) * pixelsInWidth), minPixelY);
                        resArrayLst.Add(resArray1);
                    }
                    return resArrayLst;
                    #endregion
                #endregion
                #endregion
                default:
                    break;
            }
            return resArrayLst;
        }
        /// <summary>
        /// 根据传入的行列号，取出相应的BLock
        /// </summary>
        /// <param name="blocks">使用字典格式保存的所有Block</param>
        /// <param name="row">行号</param>
        /// <param name="col">列号</param>
        /// <returns>返回的Block值</returns>
        public static Block GetBlockByRowCol(Dictionary<string, Block> blocks,int row, int col)
        {
            string tmpKey = row + "-" + col;
            if (blocks.ContainsKey(tmpKey))
                return blocks[tmpKey];
            else return null;
        }
        /// <summary>
        /// 根据角点的值，为该点赋代码(大于upperValue为2，小于lowerValue为0，两者之间为1)
        /// </summary>
        /// <param name="currentVal">角点值</param>
        /// <param name="lowerValue">下界</param>
        /// <param name="upperValue">上界</param>
        /// <returns>代码</returns>
        public static int CalLevelCode(double currentVal, double lowerValue, double upperValue)
        {
            if (currentVal < lowerValue) return 0;
            else if (currentVal >= lowerValue && currentVal < upperValue) return 1;
            else return 2;
        }
        /// <summary>
        /// 根据划分的区间段数量，确定指定区间的颜色
        /// </summary>
        /// <param name="currentLevel">当前区间编号</param>
        /// <param name="totalLevels">总共区间数量（比断点数大1）</param>
        /// <returns>颜色值</returns>
        public static Color CalColor(int currentLevel,int totalLevels)
        {
            int r = 0, g = 0, b = 0, a = 255;
            //if (pntValue <= 1e-06)
            if (currentLevel==0)                     //小于最小断点的部分，设置为透明
            {
                r = 0; g = 0; b = 0; a = 0;
            }
            //else if (pntValue <= minValue)
            //{
            //    r = 0; g = 0; b = 255;
            //}
            else if (currentLevel >= totalLevels-1)         //大于最大断点的部分，设置为最高值
            {
                r = 255; g = 0; b = 0;
            }
            else
            {
                //double tmpScale = (pntValue - minValue) / (maxValue - minValue);
                double tmpScale = (double)(currentLevel-1) / (totalLevels-1);      //这里分子分母都需要减一个1，因为之前把currentLevel==0的情况跳过去了
                if (tmpScale >= 0.75)
                {
                    r = 255;
                    g = (int)(4 * (1 - tmpScale) * 255);
                    b = 0;
                }
                else if (tmpScale >= 0.5 && tmpScale < 0.75)
                {
                    r = (int)(255 - 4 * (0.75 - tmpScale) * 255);
                    g = 255;
                    b = 0;
                }
                else if (tmpScale >= 0.25 && tmpScale < 0.5)
                {
                    r = 0;
                    g = 255;
                    b = (int)(4 * (0.5 - tmpScale) * 255);
                }
                else
                {
                    r = 0;
                    g = (int)(255 - 4 * (0.25 - tmpScale) * 255);
                    b = 255;
                }
            }
            Color pColor = Color.FromArgb(a, r, g, b);
            return pColor;
        }
    }
}


Block定义
public class Block
    {
        /// <summary> 矩形块的X坐标最小值 </summary>
        public double minX;
        /// <summary> 矩形块的X坐标最大值 </summary>
        public double maxX;
        /// <summary> 矩形块的Y坐标最小值 </summary>
        public double minY;
        /// <summary> 矩形块的Y坐标最大值 </summary>
        public double maxY;
        /// <summary> 矩形块的中心X坐标  </summary>
        public double centerX;
        /// <summary> 矩形块的中心Y坐标  </summary>
        public double centerY;
        /// <summary> 矩形块的中心像素X坐标 </summary>
        public int centerPixelX;
        /// <summary> 矩形块的中心像素Y坐标  </summary>
        public int centerPixelY;
        /// <summary> //矩形块的中心浓度值  </summary>
        public Dictionary<string, double> centerValues = new Dictionary<string, double>();
        /// <summary> 矩形对应的内部像素(只有第一级网格的才赋内部像素) </summary>
        public List<CPixel> pixels = new List<CPixel>();
        /// <summary> 矩形块所在第一级网格的行号（对于嵌套网格，只取第一级网格的行列号）  </summary>
        public int rowNo;
        /// <summary> 矩形块所在第一级网格的列号（对于嵌套网格，只取第一级网格的行列号）  </summary>
        public int colNo;
        /// <summary> 矩形块所在网格行列号的字符（即结果文件中的第一列，包括行列号以及子网格信息）  </summary>
        public string row_col_str;      //wyz151119
        /// <summary> 矩形块如果不是第一级网格，取该矩形块的路径，即标明其所属关系的行列号</summary>
        public string interGridPath;
        /// <summary> 网格所属的级别（最低为1，默认值也为1）</summary>
        public int level = 1;
        /// <summary> 风向</summary>
        public double windAng;
        /// <summary> 风速</summary>
        public double windLen;
    }

