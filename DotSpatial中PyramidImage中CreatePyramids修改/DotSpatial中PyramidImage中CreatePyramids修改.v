主要是为了避免因为分块建立金字塔时，每一块在多次除以2时造成的累计舍入误差

修改后（这里）第一层循环中，block == numBlocks - 1时，应该还存在一定的舍入误差
  /// <summary>
        /// This assumes that the base image has been written to the file.  This will now attempt to calculate
        /// the down-sampled images.
        /// </summary>
        public void CreatePyramids()
        {
            int w = _header.ImageHeaders[0].NumColumns;
            int h = _header.ImageHeaders[0].NumRows;
            int blockHeight = 8000000 / w;
            if (blockHeight > h) blockHeight = h;
            int numBlocks = (int)Math.Ceiling(h / (double)blockHeight);
            ProgressMeter pm = new ProgressMeter(ProgressHandler, "Generating Pyramids",
                                                 _header.ImageHeaders.Length * numBlocks);
            double[] blockMod = new double[_header.ImageHeaders.Length];          //wyz151107:对于每个等级的金字塔，为避免舍入误差，循环BLock时，每隔几行需要将Block的行数加一
            int[] writedRowNum = new int[_header.ImageHeaders.Length];      //对每个等级的金字塔，记录已经写过的行数，替换原有的sbh
            //wyz151107:确定BlockMod
            //int tmpsw = sw;
            int tmpsh = blockHeight;
            for (int i = 1; i < _header.ImageHeaders.Length - 1; i++)
            {
                //tmpsw = tmpsw / 2;
                tmpsh = tmpsh / 2;
                double chazhi = (((double)blockHeight * numBlocks / _header.ImageHeaders[0].NumRows) * _header.ImageHeaders[i].NumRows) - tmpsh * numBlocks;
                blockMod[i] = chazhi / numBlocks;
            }
            
            for (int block = 0; block < numBlocks; block++)
            {
                // Normally block height except for the lowest block which is usually smaller
                int bh = blockHeight;
                if (block == numBlocks - 1) bh = h - block * blockHeight;
                // Read a block of bytes into a bitmap
                byte[] vals = ReadWindow(block * blockHeight, 0, bh, w, 0);
                Bitmap bmp = new Bitmap(w, bh);
                BitmapData bd = bmp.LockBits(new Rectangle(0, 0, w, bh), ImageLockMode.WriteOnly,
                                             PixelFormat.Format32bppArgb);
                Marshal.Copy(vals, 0, bd.Scan0, vals.Length);
                bmp.UnlockBits(bd);
                // cycle through the scales, and write the resulting smaller bitmap in an appropriate spot
                int sw = w; // scale width
                int sh = bh; // scale height
                //int sbh = blockHeight;
                for (int scale = 1; scale < _header.ImageHeaders.Length - 1; scale++)
                {
                    sw = sw / 2;
                    if (block == numBlocks - 1 || block == 1)
                        sh = bh / (int)Math.Pow(2, scale);
                    else
                        sh = bh / (int)Math.Pow(2, scale) + (int)(blockMod[scale] * block) - (int)(blockMod[scale] * (block-1));
                    //sbh = sbh / 2;
                    //wyz151107:这里由于是按行分为多块，在每一块之内如果再按照多次除以二确定子块的行数，会造成多次的积累舍入误差
                    //sw = sw / 2;        //列数因为不分块，应该不影响
                    //sh = (int)(((double)bh / _header.ImageHeaders[0].NumRows) * _header.ImageHeaders[scale].NumRows);
                    //sbh = (int)(((double)blockHeight / _header.ImageHeaders[0].NumRows) * _header.ImageHeaders[scale].NumRows);
                    if (sh == 0 || sw == 0)
                    {
                        break;
                    }
                    Bitmap subSet = new Bitmap(sw, sh);
                    Graphics g = Graphics.FromImage(subSet);
                    g.DrawImage(bmp, 0, 0, sw, sh);
                    bmp.Dispose(); // since we keep getting smaller, don't bother keeping the big image in memory any more.
                    bmp = subSet;  // keep the most recent image alive for making even smaller subsets.
                    g.Dispose();
                    BitmapData bdata = bmp.LockBits(new Rectangle(0, 0, sw, sh), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
                    byte[] res = new byte[sw * sh * 4];
                    Marshal.Copy(bdata.Scan0, res, 0, res.Length);
                    bmp.UnlockBits(bdata);
                    //WriteWindow(res, sbh * block, 0, sh, sw, scale);
                    WriteWindow(res, writedRowNum[scale]  , 0, sh, sw, scale);
                    pm.CurrentValue = block * _header.ImageHeaders.Length + scale;
                    //wyz151107
                    writedRowNum[scale] += sh;
                }
                vals = null;
                bmp.Dispose();
            }
            pm.Reset();
        }

修改前：
  /// <summary>
        /// This assumes that the base image has been written to the file.  This will now attempt to calculate
        /// the down-sampled images.
        /// </summary>
        public void CreatePyramids()
        {
            int w = _header.ImageHeaders[0].NumColumns;
            int h = _header.ImageHeaders[0].NumRows;
            int blockHeight = 32000000 / w;
            if (blockHeight > h) blockHeight = h;
            int numBlocks = (int)Math.Ceiling(h / (double)blockHeight);
            ProgressMeter pm = new ProgressMeter(ProgressHandler, "Generating Pyramids",
                                                 _header.ImageHeaders.Length * numBlocks);
            for (int block = 0; block < numBlocks; block++)
            {
                // Normally block height except for the lowest block which is usually smaller
                int bh = blockHeight;
                if (block == numBlocks - 1) bh = h - block * blockHeight;
                // Read a block of bytes into a bitmap
                byte[] vals = ReadWindow(block * blockHeight, 0, bh, w, 0);
                Bitmap bmp = new Bitmap(w, bh);
                BitmapData bd = bmp.LockBits(new Rectangle(0, 0, w, bh), ImageLockMode.WriteOnly,
                                             PixelFormat.Format32bppArgb);
                Marshal.Copy(vals, 0, bd.Scan0, vals.Length);
                bmp.UnlockBits(bd);
                // cycle through the scales, and write the resulting smaller bitmap in an appropriate spot
                int sw = w; // scale width
                int sh = bh; // scale height
                int sbh = blockHeight;
                for (int scale = 1; scale < _header.ImageHeaders.Length - 1; scale++)
                {
                    sw = sw / 2;
                    sh = sh / 2;
                    sbh = sbh / 2;
                    if (sh == 0 || sw == 0)
                    {
                        break;
                    }
                    Bitmap subSet = new Bitmap(sw, sh);
                    Graphics g = Graphics.FromImage(subSet);
                    g.DrawImage(bmp, 0, 0, sw, sh);
                    bmp.Dispose(); // since we keep getting smaller, don't bother keeping the big image in memory any more.
                    bmp = subSet;  // keep the most recent image alive for making even smaller subsets.
                    g.Dispose();
                    BitmapData bdata = bmp.LockBits(new Rectangle(0, 0, sw, sh), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
                    byte[] res = new byte[sw * sh * 4];
                    Marshal.Copy(bdata.Scan0, res, 0, res.Length);
                    bmp.UnlockBits(bdata);
                    WriteWindow(res, sbh * block, 0, sh, sw, scale);
                    pm.CurrentValue = block * _header.ImageHeaders.Length + scale;
                }
                vals = null;
                bmp.Dispose();
            }
            pm.Reset();
        }

