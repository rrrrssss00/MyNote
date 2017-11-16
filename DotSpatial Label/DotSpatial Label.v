１：显示 Ｌａｂｅｌ（会覆盖原来ＡｄｄＬａｂｅｌ添加的Ｌａｂｅｌ）
MapPointLayer tmpPntLayer = (MapPointLayer)map1.Layers[0];
 map1.AddLabels(tmpPntLayer, "[str1]", new Font("宋体", 8), Color.Black);

 以上是简单的Label添加方式，还有更复杂的方法，可以控制更多的属性，例如：
  ILabelSymbolizer tmpLabelSym = new LabelSymbolizer();
  tmpLabelSym.FontColor = Color.Red;
  tmpLabelSym.FontSize = 10;
  tmpLabelSym.Orientation = ContentAlignment.TopCenter;
  tmpLabelSym.OffsetY = 9;
  ((IMapPointLayer)layer).AddLabels("[name]", "",tmpLabelSym,"");
  
  也可以尝试这种方式

   private void AddLabels(IFeatureLayer lyrlayer)
        {
            IMapLabelLayer labelLayer = new MapLabelLayer();
            ILabelCategory category = labelLayer.Symbology.Categories[0];
            category.Expression = "[Label]";
            //category.Symbolizer.Orientation = ContentAlignment.TopLeft;
            category.Symbolizer.FontSize = 8;
            category.Symbolizer.FontColor = Color.Black;
            category.Symbolizer.OffsetY = 12;
            category.Symbolizer.BackColorEnabled = true;
            category.Symbolizer.BackColor = Color.White;
            lyrlayer.ShowLabels = true;
            lyrlayer.LabelLayer = labelLayer;
        }
 
２：控制Ｌａｂｅｌ是否可见
tmpPntLayer.ShowLabels = !tmpPntLayer.ShowLabels;
 
３：清除Ｌａｂｅｌ
map1.ClearLabels(tmpPntLayer);

4：部分情况下，Label显示不全，可以使用下面的语句强制显示
 ((FeatureLayer)tmpPntLayer).LabelLayer.CreateLabels();
