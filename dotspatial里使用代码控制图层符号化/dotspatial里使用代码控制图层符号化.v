点图层:
 
//根据属性信息对某些要素做符号化
tmpPntLayer.DataSet.FillAttributes();
PointScheme tmpScheme = new PointScheme();
PointCategory tmpCate = new PointCategory(Color.Red, DotSpatial.Symbology.PointShape.Star, 6);
tmpCate.FilterExpression = "[str1]='aaaa'";
tmpCate.LegendText = "wfefa";
tmpScheme.AddCategory(tmpCate);
tmpPntLayer.Symbology = tmpScheme;
 
//根据属性信息使用随机的颜色对所有要素进行符号化
tmpPntLayer.DataSet.FillAttributes();
PointScheme tmpScheme = new PointScheme();
tmpScheme.EditorSettings.ClassificationType = ClassificationType.UniqueValues;
tmpScheme.EditorSettings.FieldName = "str1";
tmpScheme.CreateCategories(tmpPntLayer.DataSet.DataTable);
for (int i = 0; i < tmpScheme.Categories.Count; i++)
{
tmpScheme.Categories[i].Symbolizer.SetSize(new Size2D(9, 9));
}
　 tmpPntLayer.Symbology = tmpScheme;
 
线图层:
 
LineScheme myScheme = new LineScheme();
myScheme.Categories.Clear();

LineCategory low = new LineCategory(Color.Blue, 2);
low.FilterExpression = "[tile_id] < 36";
low.LegendText = "Low";

LineCategory high = new LineCategory(Color.Red, Color.Black, 6, DashStyle.Solid,
LineCap.Triangle);
high.FilterExpression = "[tile_id] >= 36";
50 of 85
high.LegendText = "High";

myScheme.AppearsInLegend = true;
myScheme.LegendText = "Tile ID";

myScheme.Categories.Add(low);
myScheme.Categories.Add(high);

myLayer.Symbology = myScheme;
 
 
面图层:
 
PolygonScheme scheme = new PolygonScheme();
         scheme.Categories.Clear();
         PolygonCategory category = new PolygonCategory(Color.Yellow, Color.Red, 2);
         scheme.Categories.Add(category);
         ss.Symbology = scheme;
 
 
 
 
 
