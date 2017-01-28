Grid shift files are used when reprojecting between coordinate systems that have different datums.

FME supports conversions between coordinate systems using different datums. Many datum transformations are not mathematically definable and require the use of grid of shifts. If you attempt to make a datum transformation of this kind without the appropriate grid shift file in place FME will abort the translation.

也就是说，两个基准面转换时，当无法用严密的数据模型（七参数）来描述时，就需要用到Grid shift files，按我的理解，应该就是一系统已知的坐标对，可以使用插值或拟合的方式完成坐标转换


七参，就是两个空间坐标系之间的旋转，平移和缩放，这三步就会产生必须的七个参数，平移有三个变量Dx，Dy，DZ；旋转有三个变量，再加上一个尺度缩放，这样就可以把一个空间坐标系转变成需要的目标坐标系了，这就是七参的作用。

如果说你要转换的坐标系XYZ三个方向上是重合的，那么我们仅通过平移就可以实现目标，平移只需要三个参数，并且现在的坐标比例大多数都是一致的，缩放比默认为一，这样就产生了三参数，三参就是七参的特例，旋转为零，尺度缩放为一
 
