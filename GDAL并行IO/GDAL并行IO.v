和导师在Transactions in GIS 上发表的关于GDAL并行I/O方面的文章
http://onlinelibrary.wiley.com/doi/10.1111/tgis.12068/abstract

摘要：Input/output (I/O) of geospatial raster data often becomes the bottleneck of parallel geospatial processingdue to the large data size and diverse formats of raster data. The open-source Geospatial Data Abstrac-tion Library (GDAL), which has been widely used to access diverse formats of geospatial raster data, hasbeen applied recently to parallel geospatial raster processing. This article first explores the efficiency andfeasibility of parallel raster I/O using GDAL under three common ways of domain decomposition: row-wise, column-wise, and block-wise. Experimental results show that parallel raster I/O using GDAL undercolumn-wise or block-wise domain decomposition is highly inefficient and cannot achieve correct output,although GDAL performs well under row-wise domain decomposition. The reasons for this problem withGDAL are then analyzed and a two-phase I/O strategy is proposed, designed to overcome this problem. Adata redistribution module based on the proposed I/O strategy is implemented for GDAL using amessage-passing-interface (MPI) programming model. Experimental results show that the data redistribu-tion module is effective. 

来源： <http://blog.csdn.net/zhanlijun/article/details/16874459>
 
