C#使用GDAL中设置GDAL_DATA变量需要使用下面的语句

Gdal.SetConfigOption("GDAL_DATA","C:\gdaldata");

但该语句无法自动识别中文路径，因此如果目录中包含中文路径，使用时将会报错
