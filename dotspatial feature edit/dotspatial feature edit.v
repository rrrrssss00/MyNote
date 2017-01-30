在进行要素编辑(不包括ADD，而是Edit)时，注意以下几点：
1：点图层在编辑前，要调用一下 
int adf = targetLayer.DrawingFilter.Count; 
蛋疼的BUG
 
2：面图层在编辑时，取到Feature后，不能直接
obj.BasicGeometry.Coordinates[0] = tmpCoord;
而是需要重新New一个Polygon，把Coordinate调整好后，再用：
Polygon tmpPoly = new Polygon(tmpLst);                   
obj.BasicGeometry = tmpPoly; 
 
3：点图层在编辑完成后，使用
targetSet.InitializeVertices();
可以将编辑后的效果在Map控件里刷新，但里面的数据还是原来的数据
（比如说，把一个点从0,0移到了10，10，InitializeVertices后，点显示在10，10，但是用选择工具去选择，是选择不到的）
还需要调用targetSet.UpdateExtent()以及
map.MapFrame.Invalidate();
;来重载一下图层数据
 
进行要素编辑时，似乎可以不修改目标图层的EditMode，（至少在点图层里是这样的）
但是，在编辑完成后，要调用这个：
editDataSet.InitializeVertices();
editLayer.AssignFastDrawnStates();
Map.Refresh();
Map.ResetBuffer();

4：FeatureSet 新建一个内存中的FeatureSet后，Save()方法是不可以使用的，只能使用SaveAs方法，但是从文件中打开的FeatureSet对像，是可以使用Save方法的

5.图层在编辑已有图层的的属性时，直接使用Save无法保存，需要添加一句
targetSet.AttributesPopulated = true;
才能保存
