进行坐标转换时，需要使用到proj.dll

1：以同坐标系下投影转地理坐标为例：
       string wkt = "PROJCS[\"Beijing_1954_GK_Zone_ZN1\",GEOGCS[\"GCS_Beijing_1954\",DATUM[\"D_Beijing_1954\",SPHEROID[\"Krasovsky_1940\",6378245.0,298.3]],PRIMEM[\"Greenwich\",0.0],UNIT[\"Degree\",0.0174532925199433]],PROJECTION[\"Gauss_Kruger\"],PARAMETER[\"False_Easting\",17500000.0],PARAMETER[\"False_Northing\",0.0],PARAMETER[\"Central_Meridian\",CM2.0],PARAMETER[\"Scale_Factor\",1.0],PARAMETER[\"Latitude_Of_Origin\",0.0],UNIT[\"Meter\",1.0]]";
        SpatialReference srPorj = null;

        SpatialReference srGeo = null;
        CoordinateTransformation ct = null;

       string tmpWkt = wkt.Replace("ZN1", zn.ToString()).Replace("CM2",cm.ToString());
       srPorj = new SpatialReference(tmpWkt);
       srPorj.ImportFromESRI(new string[] { tmpWkt });
       SpatialReference srGeo = srPorj.CloneGeogCS();
       ct = new CoordinateTransformation(srPorj, srGeo);

        double x, y,xout,yout;
        x = para[4];
        y = para[5];
        double [] d = new double[3];
        ct.TransformPoint(d, x, y, 0);
        xout = d[0];
        yout = d[1];


