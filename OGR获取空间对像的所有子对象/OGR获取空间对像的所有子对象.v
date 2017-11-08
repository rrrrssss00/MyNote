  private List<Geometry> GetSubGeos(Geometry geo)
        {
            List<Geometry> subGeos = new List<Geometry>();

            //当前空间对象的所有子对象
            int count = geo.GetGeometryCount();
            for (int i = 0; i < count; i++)
            {   
                //循环子对象，
                Geometry tmpgeo = geo.GetGeometryRef(i);
                //看子对象是否还有下一级子对象
                if (tmpgeo.GetGeometryCount() > 0)
                {
                    subGeos.AddRange(GetSubGeos(tmpgeo));
                }
                else subGeos.Add(tmpgeo);
            }
            return subGeos;
        }
