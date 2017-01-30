OGR库中，所有的空间对象都使用Geometry类来表示，不同的空间对象类型（点线面）使用Geometry对象中的GeometryType属性来区分，可以使用Geometry对象的GetGeometryType()方法来获取这一属性

GeometryType属性是一个wkbGeometryType枚举型，里面包括Point，MultiPoint，LineString，MultiLineString，Polygon，MultiPolygon等多种类型，其中几种点和线的类型比较好理解和处理，下面解释一下Polygon和MultiPolygon在使用上需要注意的地方

-----
首先是构成，Polygon类型，先声明一个空对象
Geometry curGeo = new Geometry(wkbGeometryType.wkbPolygon);
然后在其中添加LineString，这样是正确的
curGeo.AddGeometry(linestringGeo);        //linestringGeo的类型是LineString

而MultiPolygon类型，则不能直接添加LineString类型的Geometry，这样会出错，而是应该直接添加Polygon类型的对象
Geometry remainGeo = new Geometry(wkbGeometryType.wkbMultiPolygon);
remainGeo.AddGeometry(linestringGeo);                //这样不行，会出错
remainGeo.AddGeometry(curGeo);                    //curGeo是Polygon类型，这样才是正确的

使用下面的函数可以获得构成Polygon或MultiPolygon的所有子对象（可能会有多层），该方法获取的所有子对象都是最基础的LineString类型
/// <summary>
        /// 获取一个空间对象所有的子块
        /// </summary>
        /// <param name="geo">待获取的空间对象</param>
        /// <param name="subGeos">所有的子块</param>
        private List<Geometry> GetSubGeos(Geometry geo)
        {
            List<Geometry> subGeos = new List<Geometry>();
            //当前空间对象的所有子对象
            int count = geo.GetGeometryCount();
            for (int i = 0; i < count; i++)
            {   
                //循环子对象，
                Geometry tmpgeo = geo.GetGeometryRef(i);
                //看子对象是否还有下一级子对象，LineString类型都是没有下一级子对象的，而Polygon类型都至少有一个LineString类型的子对象
                if (tmpgeo.GetGeometryCount() > 0)
                {
                    subGeos.AddRange(GetSubGeos(tmpgeo));
                }
                else subGeos.Add(tmpgeo);
            }
            return subGeos;
        }

