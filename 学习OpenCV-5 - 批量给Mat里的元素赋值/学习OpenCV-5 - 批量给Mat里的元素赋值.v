将预定义好的数组内容批量赋给Mat里元素，有2种方式，注意两种方式中，数组的元素类型均必须与Mat的元素类型一致
一个是使用Mat.SetTo函数进行赋值，这种方式好像只能从头开始赋，或者先取Mat的某行或某列，按该行或该列赋值
 Int16[] kernelBytes = new Int16[9] { 0, -1, 0, -1, 5, -1, 0, -1, 0 };
Mat kernel= new Mat(3,3, DepthType.Cv16S,1);
kernel.SetTo(kernelBytes);
//kernel.Row(0).SetTO(...)

一个是使用Marshal.Copy方法，内存拷贝赋值，这种方式可以从指定的任意位置开始赋值，比较灵活，但无法按列方向赋值，而且使用不当的时候会有一定的出错风险
这里注意，Copy的目标需要使用kernel.DataPointer来定位数据的指针，使用kernel.ElementSize来获取每一个元素占用的Byte数量
Int16[] kernelBytes = new Int16[9] { 0, -1, 0, -1, 5, -1, 0, -1, 0 };
Mat kernel= new Mat(3,3, DepthType.Cv16S,1);
//参数表：1--源数组，2--起始位置，3--目标指针，4--长度
System.Runtime.InteropServices.Marshal.Copy(kernelBytes, 0, kernel.DataPointer, 9);
//如果从任意位置起始，可以使用
//Marshal.Copye(kernelBytes,5,kernel.DataPointer+(1*kernel.Cols+2)*kernel.ElementSize,4);

