public void CreateHeaders(int numRows, int numColumns, double[] affineCoefficients)
        {
            _header = new PyramidHeader();
            List<PyramidImageHeader> headers = new List<PyramidImageHeader>();
            int scale = 0;
            long offset = 0;
            int nr = numRows;
            int nc = numColumns;
            //wyz151107,计算Affine时，单纯使用2的次方去乘可能会因为行列号在不停除2的过程中，小数被舍去而造成误差
            //目前这种算法只适用于正形的情况，其它情况可能还有一些误差
            double totalWidth =  affineCoefficients[1] * numColumns;
            double totalHeight =  affineCoefficients[5] * numRows;
            while (nr > 2 && nc > 2)
            {
                PyramidImageHeader ph = new PyramidImageHeader();
                //ph.SetAffine(affineCoefficients, scale); 
                ph.SetNumRows(numRows, scale);
                ph.SetNumColumns(numColumns, scale);
                //wyz151107
                double[] tmpAffine = new double[6];
                tmpAffine[0] = affineCoefficients[0];
                tmpAffine[1] = totalWidth / (int)(numColumns / Math.Pow(2, scale));
                tmpAffine[2] = affineCoefficients[2] * Math.Pow(2, scale);
                tmpAffine[3] = affineCoefficients[3];
                tmpAffine[4] = affineCoefficients[4] * Math.Pow(2, scale);
                tmpAffine[5] = totalHeight / (int)(numRows / Math.Pow(2, scale));
                ph.SetAffine(tmpAffine, 0); 
                ph.Offset = offset;
                offset += (ph.NumRows * ph.NumColumns * 4);
                nr = nr / 2;
                nc = nc / 2;
                scale++;
                headers.Add(ph);
            }
            _header.ImageHeaders = headers.ToArray();
        }

