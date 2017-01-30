DotSpatial_65997的插件机制：

1：该版本的插件主要在两个目录下，Application Extensions和Plugins
    插件分为两类，一类为APP（功能性），一类为Data Extension（数据驱动）
2：加载插件的方法为：在窗体中加入一个AppManager,然后使用appmanager.LoadExtensions()方法加载插件
    在该方法中以下代码为主要加载代码：
        _catalog = GetCatalog();

        CompositionContainer = new CompositionContainer(_catalog);

        try
        {
            IDataManager dataManager = DataManager.DefaultDataManager;
            CompositionContainer.ComposeParts(this, dataManager, this.SerializationManager);
        }
        catch (CompositionException compositionException)
        {
            Trace.WriteLine(compositionException.Message);
            throw;
        }
    其中，GetCatalog一句为读取所有插件及相关列表（这个我也不是很明白，反正都插件列表都读进去了，还有一些其它的东西），然后try里面的语句是加载插件（包括APP和Data Extension都加载了）
    在之后的代码中ActivateAllExtensions();一句将所有插件都激活

3：这个版本里，APP类插件的设计思路是这样：在AppManager中添加了三个控件区：DockManager，HeaderControl，ProgressHandler，所有插件通过继承Extension接口，然后可以直接访问到这三个控件区，可以在Extension的Active函数其中添加工具按钮或菜单栏之类的东西，免去了开发者在界面设计方面的工作。
    但是相应地添加了一些限定：在LoadExtension的时候会检测这三个控件区是否可用（这里还不能手动给这三个控件区赋值，必须用特定的方法，具体可以参考其自带DemoMap里MainForm中 private static ContainerControl Shell;相关内容），如果不可用，会直接给出报错，还会提示下载一些什么东西。。。非常麻烦，检查的代码有两部分，
    一个在DotSpatial.Plugins.ExtensionManager.SatisfyImportsOnStartupExtension.cs中的Active函数里

        bool isDockManagerNeeded = App.CompositionContainer.GetExportedValues<IDockManager>().Count() == 0;
        bool isHeaderControlNeeded = App.CompositionContainer.GetExportedValues<IHeaderControl>().Count() == 0;
        bool isStatusControlNeeded = App.CompositionContainer.GetExportedValues<IStatusControl>().Count() == 0;

        if (isDockManagerNeeded && isHeaderControlNeeded && isStatusControlNeeded)
        {
            App.UpdateProgress("Downloading a Ribbon extension...");
            packages.Install("DotSpatial.Plugins.Ribbon");

            App.UpdateProgress("Downloading a DockManager extension...");
            packages.Install("DotSpatial.Plugins.DockManager");

            App.UpdateProgress("Downloading a MenuBar extension...");
            packages.Install("DotSpatial.Plugins.MenuBar");
            packages.Install("DotSpatial.Plugins.Measure");
            packages.Install("DotSpatial.Plugins.TableEditor");

            App.RefreshExtensions();
        }
    前三句判断AppManager在GetCatalog时是否获取到了这三个控件区，如果没有的话，会提示下载，然后执行一些不知道干什么的代码。想跳过这个检测的话，有两个方法，1：可以将if中的内容全部注释掉，不影响使用，最多在插件加载时报错，不会引起程序崩溃，2：可以将DotSpatial.Plugins.ExtensionManager.dll从Application Extensions目录中删除掉，就不会有这个问题了
    另一个检查代码在AppManager类里，是这个函数：
        public bool EnsureRequiredImportsAreAvailable()
        {
            DockManager = GetRequiredImport<IDockManager>();
            HeaderControl = GetRequiredImport<IHeaderControl>();
            ProgressHandler = GetRequiredImport<IStatusControl>();

            if (DockManager == null || HeaderControl == null || ProgressHandler == null)
                return false;

            return true;
        }
    这个函数在ActivateAllExtensions中调用，原理也类似，判断AppManager里是否有这三个控件区，缺少一个的话就返回错误，之后不Active所有插件，想跳过这个检查，可以在外部对AppManager的这三个变量赋值，然后把这个函数改为：
        public bool EnsureRequiredImportsAreAvailable()
        {
            if(DockManager == null) DockManager = GetRequiredImport<IDockManager>();
            if(HeaderControl == null)HeaderControl = GetRequiredImport<IHeaderControl>();
            if(ProgressHandler == null) ProgressHandler = GetRequiredImport<IStatusControl>();

            //if (DockManager == null || HeaderControl == null || ProgressHandler == null)
            //    return false;

            return true;
        }

4：说了这么多，其实还是感觉这个机制不是很方便，最后采用的方法：在添加DotSpatial至自己的项目后，Data Extension保留，其它所有APP类的插件全部删除，然后按照上面说的方法跳过AppManager中的检测。至于插件中实现的方法，一般用不到，实在要用的话，将代码改写一下，直接拷到项目中使用。
