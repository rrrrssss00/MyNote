WKT、SRID、EPSG概念
WKT、SRID、EPSG概念
 
http://www.cnblogs.com/jackdong/archive/2010/12/20/1911558.html
之前一直对WKT、EPSG、SRID不是很理解，总是混淆，今天看了一下，清晰了很多，顺便总结一下，嘿嘿：）
EPSG：European Petroleum Survey Group (EPSG)， http://www.epsg.org/，它成立于1986年，并在2005年重组为OGP(Internation Association of Oil & Gas Producers)，它负责维护并发布坐标参照系统的数据集参数，以及坐标转换描述，该数据集被广泛接受并使用，通过一个Web发布平台进行分发，同时提供了微软Acess数据库的存储文件，通过SQL 脚本文件，mySQL, Oracle 和PostgreSQL等数据库也可使用。
目前已有的椭球体，投影坐标系等不同组合都对应着不同的ID号，这个号在EPSG中被称为EPSG code，它代表特定的椭球体、单位、地理坐标系或投影坐标系等信息。

SRID：，OGC标准中的参数SRID，也是指的空间参考系统的ID，与EPSG一致；
WMS 1.1.1以前用SRS参数（空间参考系）表示坐标系统，WMS1.3开始用CRS参数（坐标参考系统）来表示。
A Spatial Reference System Identifier(SRID) is a unique value used to unambiguously identify projected, unprojected, and local spatial coordinate system definitions. These coordinate systems form the heart of all GIS applications.
	Virtually all major spatial vendors have created their own SRID implementation or refer to those of an authority, such as the European Petroleum Survey Group (EPSG). (NOTE: As of 2005 the EPSG SRID values are now maintained by the International Association of Oil & Gas Producers (OGP) Surveying & Positioning Committee).
	以OGC请求为例：
	http://localhost/IS/WebServices/wms.ashx?map=World&SERVICE=WMS&REQUEST=GetMap&LAYERS=&STYLES=&SRS=EPSG:4326&BBOX=-3,44,10,53&WIDTH=600&HEIGHT=300&FORMAT=image/gif&BGCOLOR=&VERSION=1.1.1
	SRS=EPSG:4326代表地理坐标系WGS1984
	WKT：空间参考系统的文字描述；
	无论是参考椭球、基准面、投影方式、坐标单位等，都有相应 的EPSG值表示，如下表：
	http://hiphotos.baidu.com/liyunluck/pic/item/56ff7cf0ac23572db17ec54b.jpg(图片不显示，用Url代替吧)
	举例：
	Beijing 1954地理坐标系，高斯--克吕格投影（横轴等角切圆柱投影）
	下面为投影相关信息：
	投影方式 Gauss_Kruger
	中央经线 75.000000
	原点纬线 0.000000
	标准纬线(1) 0.000000
	标准纬线(2) 0.000000
	水平偏移量 13500000.000000
	垂直偏移量 0.000000
	比例因子 1.000000
	方位角   0.000000
	第一点经线 0.000000
	第二点经线 0.000000
	地理坐标系 GCS_Beijing_1954
	大地参照系 D_Beijing_1954
	参考椭球体 Krasovsky_1940
	椭球长半轴 6378245.000000
	椭球扁率 0.0033523299
	本初子午线 0.000000
	WKT形式表示该投影坐标系：
	PROJCS["Gauss_Kruger",
		GEOGCS["GCS_Beijing_1954",
		   DATUM["D_Beijing_1954",
		       SPHEROID["Krasovsky_1940",6378245.000000,298.299997264589]] 
		          ]
			  PEIMEM["Greenwich",0] 
			  UNIT["degree",0.0174532925199433]//地理单位：0.0174532925199433代表与米之间的转换
			  ],
				  PROJECTION["Gauss_Kruger"],
				  PARAMETER["False_Easting",13500000.000000],
				  PARAMETER["False_Northing",0],
				  PARAMETER["Central_Meridian",75.000000],
				  PARAMETER["Scale_Factor",1.0],
				  PARAMETER["Latitude_Of_Origin",0.0],
				  UNIT["Meter",1.0]] ;
			  ]

			  来源： <http://blog.csdn.net/cpcpc/article/details/6123320>
			   
