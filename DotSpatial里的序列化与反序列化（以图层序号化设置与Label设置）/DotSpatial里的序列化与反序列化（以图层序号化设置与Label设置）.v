序列化：
DotSpatial.Serialization.XmlSerializer serialer = new DotSpatial.Serialization.XmlSerializer();
string LayerSymbolizerSerialStr = serialer.Serialize(((IFeatureLayer)layer).Symbolizer);
ILabelLayer labelLayer = ((IFeatureLayer)layer).LabelLayer;
if (labelLayer != null)
{
	string LayerLabelSerailStr = serialer.Serialize(labelLayer);
}

反序列化：
DotSpatial.Serialization.XmlDeserializer deser = new DotSpatial.Serialization.XmlDeserializer();
IDataSet dataset = DataManager.DefaultDataManager.OpenFile(.LayerPath);
IFeatureLayer tmplyr = map.Layers.Add(dataset) as IFeatureLayer;
if (caseLyr.LayerSymbolizerSerialStr != "")
{
	    IFeatureSymbolizer symbolizer = deser.Deserialize<IFeatureSymbolizer>(LayerSymbolizerSerialStr);
	    tmplyr.Symbolizer = symbolizer;
}
if (caseLyr.LayerLabelSerailStr != "")
{
             IMapLabelLayer labellyr = deser.Deserialize<IMapLabelLayer>(LayerLabelSerailStr);
             tmplyr.LabelLayer = labellyr;
             tmplyr.ShowLabels = true;
}

