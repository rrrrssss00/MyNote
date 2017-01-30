IRasterClassifyColorRampRenderer 的一些注意点

1:IRasterClassifyColorRampRenderer 的Break设置方法
IRasterClassifyColorRampRenderer这个接口是ArcEngine里对单波段栅格影像进行分类渲染的接口,这里的Break(也就是分断点)的设置有点奇怪,很容易用错,研究了一下,用法是这样的.

一个简单的例子,一个0-255的波段图像,要分为三类,0-85,85-170,170-255,那么这个断点其实有四个,分别是0,85,170,255

代码应该类似这样:
 
IRasterClassifyColorRampRenderer ccr = ...
 
.....
 
.....
 
ccr.set_Break(0,0);
ccr.set_Label(0,"0-85");
ccr.set_Symbol(0,tmpSymbol1);
 
ccr.set_Break(1,85);
ccr.set_Label(1,"85-170");
ccr.set_Symbol(1,tmpSymbol2);
 
ccr.set_Break(2,170);
ccr.set_Label(2,"170-255");
ccr.set_Symbol(2,tmpSymbol3);
 
ccr.set_Break(3,255);
 
2.Renderer生效前的一些调用
在用语句使Renderer生效前,需要调用这样一些语句,不然经常会出些奇怪的问题:
IRasterClassifyColorRampRenderer ccr = .....

//这几句奇怪的语句,要调用一下
 ((IRasterRenderer)ccr).Raster = tarLyr.Raster;
 ccr.ClassCount = 4;
 ((IRasterRenderer)ccr).Update();

//再进行赋值和计算
ccr.set_Break...
ccr.set_Label...

 tarLyr.Renderer = ccr as IRasterRenderer;
 map.Refresh(esriViewDrawPhase.esriViewAll);
 toc.Update();
