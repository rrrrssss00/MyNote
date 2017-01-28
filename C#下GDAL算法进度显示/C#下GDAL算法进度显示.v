以生成金字塔为例，在C#下，可以用以下代码：
 
if(ds.BuildOverviews(args[1], levels, new Gdal.GDALProgressFuncDelegate(ProgressFunc), "Sample Data") != (int)CPLErr.CE_None)
{
    MessageBox.Show("error");
    return;
}
 
其中ProgressFunc为一个函数，可以将进度显示的代码放在其中，定义如下：
 
public static int ProgressFunc(double Complete, IntPtr Message, IntPtr Data)
    {
        Console.Write("Processing ... " + Complete * 100 + "% Completed.");
if (Message != IntPtr.Zero)
            Console.Write(" Message:" + System.Runtime.InteropServices.Marshal.PtrToStringAnsi(Message));
if (Data != IntPtr.Zero)
            Console.Write(" Data:" + System.Runtime.InteropServices.Marshal.PtrToStringAnsi(Data));

        Console.WriteLine("");
return 1;
    }
 
 
其中，Data一值，一般情况下就是输入的“Sample Data"
