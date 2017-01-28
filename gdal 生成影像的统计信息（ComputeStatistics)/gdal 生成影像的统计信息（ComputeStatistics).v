double tmpDou = -1;  
            for (int i = 1; i <= dsout.RasterCount; i++)  
            {  
                dsout.GetRasterBand(i).ComputeStatistics(false, out tmpDou, out tmpDou, out tmpDou, out tmpDou, null, null);  
            }  
就是把所有的波段都调用一下ComputeStatistics函数即可，该函数第一个参数为Bool型，按照官网解释，如果为True，那么GDAL会尝试先从金字塔文件中去计算统计值，
第二到五个参数分别为该波段的最小值，最大值，平均值，均方差，最后两个参数是可以用来显示进度的，一般用不上
