DotSpatial里的选择（Selection）通过图层（ILayer）完成
 
IMapLayer等图层接口可以做空间查询，方法为给出IEnvelop，再进行查询，查询完毕自动高亮
 
 DotSpatial.Topology.Point tmpPnt = new DotSpatial.Topology.Point(e.GeographicLocation);
 
IEnvelope env = tmpPnt.Buffer(0.5).Envelope; 
IEnvelope tolerant = env;
IEnvelope tmpEnv ;
targetLayer.ClearSelection();
targetLayer.Select(tolerant, env, DotSpatial.Symbology.SelectionMode.Intersects,out tmpEnv);
 
IFeatureLayer等图层接口可以做属性查询，实例略
 
查询完成后，通过IFeatureLayer等图层接口的Selection属性来获取选择集
 
List<IFeature> resLst = ((IFeatureLayer)targetLayer).Selection.ToFeatureList();
