加载在线地图的步骤:
1:LoadShpMap/LoadRasterMap函数里:首先初始化ServiceProvider(从什么在线服务中读取底图),初始化时使用ServiceProvider shpMapProvider = new ServiceProvider(Properties.Resources.GoogleMap, null);,其中第一个参数为字段串,说明在线服务的名称,第二个参数为URL,说明从该在线服务获取图片的地址,这里有两种方式,如果是通过BruTile的DLL取图片,那么URL为空,如果不是通过BruTile的DLL,那么这个URL必须填写在线服务的地址
 
2:然后调用EnableBasemapFetching(_provider.Name, _provider.Url);这个函数里,
首先把地图控件的投影转到Web墨卡托(天地图有Web墨卡托和经纬度投影的服务,若想调用天地图,使用Web墨卡托投影的服务对代码的改动量比较小),
然后通过EnableBasemapLayer()函数看是否已经有在线底图对应的图层,若没有,则向Map控件里添加一个图层.
再通过_tileManager.ChangeService(tileServerName, tileServerUrl);应用ServiceProvider
最后,再调用后台进程开始下载并显示底图,BwDoWork()
 
2-1:在后台进程中,主要通过调用UpdateStichedBasemap()函数来下载并显示底图,该函数中:
首先:读取Map控件的显示坐标范围,通过几个Clip函数,将超出Web墨卡托坐标范围裁掉
然后,通过Reproject.ReprojectPoints函数将Web墨卡托的坐标范围转到WGS84下的经纬度,得到经纬度范围geogEnv,
第三,通过_tileManager.GetTiles函数来获取所有的切片,
第四,通过TileCalculator.StitchTiles()函数来将所有的切片合成一张大图
第五,通过一系列转换,包括透明度设置,坐标转换,变形等,将这张大图显示在Map控件里
 
2-1-1 在_tileManager.GetTiles函数中,传入参数有两个,一个是Map控件显示的经纬度范围,另一个是Map控件长宽对应的像素数.
首先,通过几个Clip函数将超出经纬度范围的坐标区域裁掉,
然后,通过TileCalculator.DetermineZoomLevel函数确定当前应使用哪一级的切片
第三，通过 Point topLeftTileXY = TileCalculator.LatLongToTileXY(mapTopLeft, zoom);
            Point btmRightTileXY = TileCalculator.LatLongToTileXY(mapBottomRight, zoom);确定左上角点所在的切片坐标以及右下角点所在的切片坐标（切片坐标以行号和列号表示）
第四，针对左上角点所在切片到右下角点所在切片，进行循环，每个循环里，计算该切片对应的左上角点及右下角点经纬度，保存到currEnv中
第五，通过GetTile函数获取切片，传入的参数为切片行号和列号，currEnv以及切片的等级，该函数中，首先判断是否通过BruTile获取，若是，则通过BruTile获取，若否，则通过URL获取
 
 
注意修改的地方：
1：在TileCalculator的StitchTiles函数（该函数把所有获取的切片拼成一个大切片）里，会用g.Clear(Color.Black);语句把底色变为黑色，这样的话，同时叠加多个图层会有底色的遮盖，所以得把这行注释掉
2：还存在的问题，如果缩放到太小，就会出现inramimage的rasterbound仿射系数有问题
