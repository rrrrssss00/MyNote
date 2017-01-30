IMapFunction 或 MapFuntion
这是面向Map控件的工具，类似于Engine中的ITool，用户可以通过重载并重写其中的方法定义其基本鼠标事件
 
主要需要重写的方法包括：OnActive，OnDeactive，OnMouseDown，OnMouseMove等
调用时，只需要 map1.ActivateMapFunction(new MapFunctions.AddPolygon(map1)); 即可
 
需要注意的是：
1:在重写了某个事件处理方法后，最好调用一下父类的相应函数，例：
protected override void OnMouseMove(GeoMouseArgs e)
{
 
    base.OnMouseMove(e);
}
 
2:在构造函数里，需要将Map控件传进来，不然无法运行，例：
public AddPolygon(IMap inMap) :base(inMap)
{
    YieldStyle = YieldStyles.LeftButton;
}
 
3:有个YieldStyle属性，这个属性定义了这个Function将占用哪些按钮，比如LeftButton,RightButton，KeyBoard，Scroll等等，在新的工具激活时，会检查新工具与旧工具是否有占用冲突，有占用冲突的话，则将旧工具Deactive掉，所以这个属性需要在构造函数里定义一下，见上例
