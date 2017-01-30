OGR的空间要素Geometry，在自相交，或者包含岛屿时，可能会在空间运算（例如Intersect或Union）时发生错误，
可以参考的处理方式如下：

Geometry geo1 = srcLyr.GetFeature(i).GetGeometryRef();
if (geo1.IsValid() == false) geo1 = ValidGeometryWithHole(geo1).Simplify(tolerance);

private Geometry ValidGeometryWithHole(Geometry input)
        {
            if (input.IsValid()) return input;
            Dictionary<double, int> areas = new Dictionary<double, int>();
            List<double> areaLst = new List<double>();
            for (int i = 0; i < input.GetGeometryCount(); i++)
            {
                Geometry tmpGeo = input.GetGeometryRef(i);
                double tmpArea = tmpGeo.Area();
                areas.Add(tmpArea,i);
                areaLst.Add(tmpArea);              
            }
            areaLst.Sort();
            Geometry newGeo = new Geometry(input.GetGeometryType());
            for (int i = areaLst.Count -1; i >=0; i--)
            {
                newGeo.AddGeometry(input.GetGeometryRef(areas[areaLst[i]]));
            }
            return newGeo;
        }

