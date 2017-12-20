当把某图层从地图控件中移除（使用map1.Layers.Remove或RemoveAt函数）时，不触发绑定的ItemRemove事件
方法：
这个应该是Dotspatial的内部分代码有问题，在移除图层时没有自动调用Layer类的OnRemoveItem函数，需要手动调用，但这个函数是protected，无法调用，只能使用曲线的方法：
在Layer类中，有一个ContextMenuItems属性，里面是在Legend里右键点击图层时显示的菜单，其中有一个菜单项是Remove Layer，这个是Layer类内部的属性，能够调用OnRemoveItem方法，可以通过这个来移除图层，相当于手动在Legend控件里右键点击，并在弹出菜单中选择Remove Layer
代码为：
map1.Layers.RemoveAt(0)
改为：
for (int j = 0; j <  ((Layer)map1.Layers[i]).ContextMenuItems.Count; j++)
{
    if (((Layer)map1.Layers[i]).ContextMenuItems[j].Name == "Remove Layer" || ((Layer)map1.Layers[i]).ContextMenuItems[j].Name == "移除图层")
    {
	((Layer)map1.Layers[i]).ContextMenuItems[j].ClickHandler(null, null);
    }
}
