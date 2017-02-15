很简单，新建一个Mat，直接可以在初始化时就定义其为另一个Mat的子集
Mat srcMat = new Mat(imgpath);
Mat subMat = new Mat(srcMat,new Rectangle(0,0,10,10));



