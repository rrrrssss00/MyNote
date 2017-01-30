在做重投影前，可以使用IBasicGeometry.Clone()接口存出一个备份

重投影的思路为，先按Geometry里的组织方式，将所有坐标点的XY值取出，存到一个数组中，再将这个数组里的所有坐标都做下重投影计算，最后按照之前的组织方式，将坐标点的XY值再存回去

示例代码为（以Polygon为例
  /// <summary>
        /// 对多边形（Polygon及MultiPolygon）进行重投影
        /// </summary>
        /// <param name="srcPolygon">源多边形</param>
        /// <param name="srcProj">源投影</param>
        /// <param name="destProj">目标投影</param>
        /// <returns></returns>
        public static Geometry ReprojectPolygon(Geometry srcPolygon,ProjectionInfo srcProj,ProjectionInfo destProj)
        {
            if (srcPolygon.FeatureType != FeatureType.Polygon) return null;
                        
            if (srcPolygon.GeometryType == "Polygon")
            {
                #region 如果源Geometry是Polygon
                Polygon tmpPolygon = (Polygon)srcPolygon;       //转为Polygon
                //将Polygon内的所有点取出，放入一个数组
                double[] pntCoords = new double[tmpPolygon.NumPoints * 2];
                int tmpIndex = 0;
                for (int i = 0; i < tmpPolygon.Shell.NumPoints; i++)
                {
                    pntCoords[tmpIndex] = tmpPolygon.Shell.Coordinates[i].X;
                    pntCoords[tmpIndex + 1] = tmpPolygon.Shell.Coordinates[i].Y;
                    tmpIndex += 2;
                }
                for (int i = 0; i < tmpPolygon.Holes.Length; i++)
                {
                    ILinearRing tmpHole = tmpPolygon.Holes[i];
                    for (int j = 0; j < tmpHole.NumPoints; j++)
                    {
                        pntCoords[tmpIndex] = tmpHole.Coordinates[j].X;
                        pntCoords[tmpIndex + 1] = tmpHole.Coordinates[j].Y;
                        tmpIndex += 2;
                    }
                }
                double[] z = new double[tmpPolygon.NumPoints];
                for (int i = 0; i < z.Length; i++)
                {
                    z[i] = 0;
                }
                //将数组里的所有点进行坐标转换
                Reproject.ReprojectPoints(pntCoords, z, srcProj, destProj, 0, tmpPolygon.NumPoints);
                //将转换完成的坐标按照Polygon的结构再赋回去
                tmpIndex = 0;
                for (int i = 0; i < tmpPolygon.Shell.NumPoints; i++)
                {
                    tmpPolygon.Shell.Coordinates[i].X = pntCoords[tmpIndex];
                    tmpPolygon.Shell.Coordinates[i].Y = pntCoords[tmpIndex + 1];
                    tmpIndex += 2;
                }
                for (int i = 0; i < tmpPolygon.Holes.Length; i++)
                {
                    ILinearRing tmpHole = tmpPolygon.Holes[i];
                    for (int j = 0; j < tmpHole.NumPoints; j++)
                    {
                        tmpHole.Coordinates[j].X = pntCoords[tmpIndex] ;
                        tmpHole.Coordinates[j].Y = pntCoords[tmpIndex + 1] ;
                        tmpIndex += 2;
                    }
                }
                return (Geometry)tmpPolygon; 
                #endregion
            }           
            else if(srcPolygon.GeometryType == "MultiPolygon")
            {
                #region 如果源Geometry是MultiPolygon
                List<Polygon> tmpPolys = new List<Polygon>();
                MultiPolygon srcMultiPolygon = (MultiPolygon)srcPolygon;
                
                for (int i = 0; i < srcPolygon.NumGeometries; i++)
                {
                    tmpPolys.Add((Polygon)ReprojectGeometry.ReprojectPolygon(srcMultiPolygon.GetGeometryN(i) as Geometry, srcProj, destProj));
                }
                return new MultiPolygon(tmpPolys.ToArray());
                #endregion
            }
            return null;
        }

）



