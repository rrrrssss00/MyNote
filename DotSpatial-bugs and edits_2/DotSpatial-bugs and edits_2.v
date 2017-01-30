1：74729版本GDALImageProvider错误
新版本（74729）中，GdalImageProvider及相关代码进行了修改，老版本中能够正常打开的文件无法正确打开
解决方法，

1：将老版本中的GdalImageProvider及相关的代码改名（改为GdalImageProvider2），拷入新版本中，参考附件三个文件

2：修改新版本GdalRasterProvider 的构造函数，去掉后缀名绑定，改为如下样子
public GdalRasterProvider()
        {
            // Add ourself in for these extensions, unless another provider is registered for them.
            //string[] extensions = { ".tif", ".tiff", ".adf" };
            //foreach (string extension in extensions)
            //{
            //    if (!DataManager.DefaultDataManager.PreferredProviders.ContainsKey(extension))
            //    {
            //        DataManager.DefaultDataManager.PreferredProviders.Add(extension, this);
            //    }
            //}
        }

3：修改拷入的GdalImageProvider2的构造函数，加入后缀名绑定
public GdalImageProvider2()
        {
            string[] extensions = { ".tif", ".tiff", ".adf" };
            foreach (string extension in extensions)
            {
                if (!DotSpatial.Data.DataManager.DefaultDataManager.PreferredProviders.ContainsKey(extension))
                {
                    DotSpatial.Data.DataManager.DefaultDataManager.PreferredProviders.Add(extension, this);
                }
            }
        }
