int index;
                index = feature.Fields.FindField("Shape");
                IGeometryDef pGeometryDef;
                pGeometryDef = feature.Fields.get_Field(index).GeometryDef as IGeometryDef;
 
                if (pGeometryDef.HasZ)
                {
                    IZAware pZAware = (IZAware)geometry;
                    pZAware.ZAware = true;
                    //IZ iz1 = (IZ)geometry;
                    //iz1.SetConstantZ(0);  //将Z值设置为0
                    IPoint point = (IPoint)geometry;
                    point.Z = 0;
                }
                else
                {
                    IZAware pZAware = (IZAware)geometry;
                    pZAware.ZAware = false;
                }
                if (pGeometryDef.HasM)
                {
                    IMAware pMAware = (IMAware)geometry;
                    pMAware.MAware = true;
                }
                else
                {
                    IMAware pMAware = (IMAware)geometry;
                    pMAware.MAware = false;
                }
 
