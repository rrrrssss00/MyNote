手上有一个其它人用DevExpress 12.1.4做的界面（VS2010)，由于手上有11.1.6的重编译版本，不想重新安装12.1.4了，而且重编译版本不需要安装，开发和部署上都很方便，所以想把12.1.4做的界面转到11.1.6上。以这个转换（12.1.4到11.1.6）为例说明一下，注意这个转换只适用于比较近的版本，如果版本相差过大，DLL文件中的类及变量名变动太大，是不行的。

1：首先，打开项目文件，将原来的DevExpress 12.1.4的引用DLL全部移除，添加对应的11.1.6的版本。

2：尝试编译，会报licenses.licx错误，将这个文件删除即可。

3：再尝试编译，会报各个窗体对应的.resx文件错误，主要是记录了控件的版本信息。例如：
 <data name="ribbonImageCollection.ImageStream" type="DevExpress.Utils.ImageCollectionStreamer, DevExpress.Utils.v12.1" mimetype="application/x-microsoft.net.object.bytearray.base64">

这种只记录了DLL文件的版本，要将DevExpress.Utils.v12.1改成DevExpress.Utils.v11.1

4：resx中还有一种情况：
<assembly alias="DevExpress.Utils.v12.1" name="DevExpress.Utils.v12.1, Version=12.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" />

这种不仅记录了DLL的版本（DevExpress.Utils.v12.1），还记录了库的版本（12.1.4.0)以及公钥（PublicKeyToken）
这种情况下，三个都需要进行相应的改动，
将DLL版本改为DevExpress.Utils.v11.1，将库版本改为11.1.6.0，将PublicKeyToken改为11.1.6对应的值：df0645c64b6ed9e5

注：公钥（PublicKeyToken）的值是在编译过程中生成的，并不是一定的，所以需要查看一下DLL文件的公钥，可以在VS命令行工具下执行：
sn -T xxx\xxx\xx.dll 
命令来查看DLL文件的公钥值，再修改RESX文件
