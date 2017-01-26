一些常用的ColorMap见附件

读取类

 public class ColorMap
    {
        #region 静态部分
        /// <summary>
        /// 加载的所有ColorMap
        /// </summary>
        public static Dictionary<string, ColorMap> ColorMaps = new Dictionary<string, ColorMap>();
        /// <summary>
        /// 最开始的时候，加载指定目录下所有的ColorMap
        /// </summary>
        /// <param name="path">ColorMap文件所在目录</param>
        public static void LoadColorMaps(string path)
        {
            string[] colormapFiles = Directory.GetFiles(path, "*.clrmap");
            ColorMaps.Clear();
            for (int i = 0; i < colormapFiles.Length; i++)
            {
                string tmpName = Path.GetFileNameWithoutExtension(colormapFiles[i]);
                ColorMap tmpcm = new ColorMap();
                StreamReader sr = new StreamReader(colormapFiles[i]);
                string tmpStr = sr.ReadLine();
                tmpStr = sr.ReadLine();
                tmpStr = sr.ReadLine();
                if (tmpStr.Contains("SPACE=HSV")) continue;         //HSV空间的先不使用
                tmpStr = sr.ReadLine();
                while (tmpStr!= null)
                {
                    #region 读取文件内的值
                    string[] tmpStrs = tmpStr.Split(new char[] { ' ', '\t' }, StringSplitOptions.RemoveEmptyEntries);
                    if (tmpStrs.Length != 3 && tmpStrs.Length!=4) { tmpStr = sr.ReadLine(); continue; }
                    else if (tmpStrs.Length == 3)
                    {
                        //如果只有三列，则表示没有明确的断点，需要根据段数来平均计算，这里先设为-1，在循环完毕后，按照段数进行计算
                        tmpcm.breaks.Add(-1);
                        int tmpr, tmpg, tmpb;
                        if(!int.TryParse(tmpStrs[0],out tmpr) || 
                            !int.TryParse(tmpStrs[1],out tmpg) || 
                            !int.TryParse(tmpStrs[2],out tmpb) )
                        { tmpStr = sr.ReadLine(); continue; }
                        tmpcm.rVals.Add(tmpr);
                        tmpcm.gVals.Add(tmpg);
                        tmpcm.bVals.Add(tmpb);
                    }
                    else
                    {
                        //如果有四列，则表示有明确的断点，只需要读取并写入即可
                        double tmpbreak;
                        int tmpr, tmpg, tmpb;
                        if (!int.TryParse(tmpStrs[1], out tmpr) ||
                            !int.TryParse(tmpStrs[2], out tmpg) ||
                            !int.TryParse(tmpStrs[3], out tmpb) ||
                            !double.TryParse(tmpStrs[0],out tmpbreak))
                        { tmpStr = sr.ReadLine(); continue; }
                        tmpcm.breaks.Add(tmpbreak);
                        tmpcm.rVals.Add(tmpr);
                        tmpcm.gVals.Add(tmpg);
                        tmpcm.bVals.Add(tmpb);
                    }
                    #endregion
                    tmpStr = sr.ReadLine();
                }
                if (tmpcm.breaks.Count == 0) continue;
                else if (tmpcm.breaks[0] == -1)
                {
                    int breakcount = tmpcm.breaks.Count - 1;        //分段的数量
                    double breakVal = 1.0 / breakcount;             //每段的长度
                    for (int j = 0; j < tmpcm.breaks.Count; j++)
                    {
                        tmpcm.breaks[j] = j * breakVal;
                    }
                    tmpcm.breaks[tmpcm.breaks.Count - 1] = 1.0;     //避免舍入误差，确认一下最后一个值为0
                }
                ColorMaps.Add(tmpName, tmpcm);
            }
        }
        #endregion
        #region 非静态部分
        /// <summary>  断点  </summary>
        public List<double> breaks = new List<double>();
        /// <summary>  R分量值  </summary>
        public List<double> rVals = new List<double>();
        /// <summary>  G分量值  </summary>
        public List<double> gVals = new List<double>();
        /// <summary>  B分量值  </summary>
        public List<double> bVals = new List<double>();
        /// <summary>
        /// 根据划分的区间段数量，确定指定区间的颜色
        /// </summary>
        /// <param name="currentLevel">当前区间编号</param>
        /// <param name="totalLevels">总共区间数量（比断点数大1）</param>
        /// <returns>颜色值</returns>
        public Color CalColor(int currentLevel, int totalLevels)
        {
            int r = 0, g = 0, b = 0, a = 255;
            if (currentLevel == 0)                     //小于最小断点的部分，设置为透明
            {
                r = 0; g = 0; b = 0; a = 0;
            }
            else if (currentLevel >= totalLevels - 1)         //大于最大断点的部分，设置为最高值
            {
                r = (int)rVals[rVals.Count - 1];
                g = (int)gVals[gVals.Count - 1];
                b = (int)bVals[bVals.Count - 1];
            }
            else
            {
                double tmpScale = (double)(currentLevel - 1) / (totalLevels - 1);//这里分子分母都需要减一个1，因为之前把currentLevel==0的情况跳过去了
                for (int i = 0; i < breaks.Count-1; i++)
                {
                    if (tmpScale >= breaks[i] && tmpScale < breaks[i + 1])
                    {
                        double r1 = rVals[i]; double g1 = gVals[i]; double b1 = bVals[i];
                        double r2 = rVals[i + 1]; double g2 = gVals[i + 1]; double b2 = bVals[i + 1];
                        r = (int)(r1 + (r2 - r1) * (tmpScale - breaks[i]) / (breaks[i + 1] - breaks[i]));
                        g = (int)(g1 + (g2 - g1) * (tmpScale - breaks[i]) / (breaks[i + 1] - breaks[i]));
                        b = (int)(b1 + (b2 - b1) * (tmpScale - breaks[i]) / (breaks[i + 1] - breaks[i]));
                    }
                }
            }
            Color pColor = Color.FromArgb(a, r, g, b);
            return pColor;
        }
        #endregion

生成ColorMap对应的图片

  foreach (string tmpName in ColorMap.ColorMaps.Keys) 
            {
                ColorMap tmpcm = ColorMap.ColorMaps[tmpName];
                Bitmap TempBitmap = new Bitmap(100, 30);
                Graphics gra = Graphics.FromImage(TempBitmap);
                gra.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighSpeed;
                gra.Clear(Color.Transparent);
                for (int i = 0; i < 100; i++)
                {
                    Color tmpColor = tmpcm.CalColor(i + 1, 101);
                    Brush tmpbrush = new SolidBrush(tmpColor);
                    gra.FillRectangle(tmpbrush, new Rectangle(i, 0, 1, 30));
                }
                TempBitmap.Save(Application.StartupPath + "\\colormaps\\" + tmpName + ".png", System.Drawing.Imaging.ImageFormat.Png);
            }

