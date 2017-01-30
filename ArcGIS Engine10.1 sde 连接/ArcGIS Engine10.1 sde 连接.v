讨论两个关键问题1、如何连接数据库 2、如何创建.sde文件。
1、连接sde数据库
在10.1中数据库的连接默认为直连，但是对于以前的代码没有任何影响，如下面的代码（如果你用的是sde10的32位数据库，连接方法和以前一样，直接用代码连接；如果你用的是64位的数据库，请将32位的数据库客户端放到安装Engine的bin目录下）：
public IWorkspace GetSDEWorkspace(String _pServerIP, String _pInstance, String _pDatabase, String _pUser, String _pPassword, String _pVersion)
        {
            IWorkspace pWkspace = null;
            ESRI.ArcGIS.Geodatabase.IWorkspaceFactory2 workspaceFactory = null;
            ESRI.ArcGIS.esriSystem.IPropertySet pPropertySet = new ESRI.ArcGIS.esriSystem.PropertySetClass();
            pPropertySet.SetProperty("SERVER", _pServerIP);
            pPropertySet.SetProperty("INSTANCE", _pInstance);
            pPropertySet.SetProperty("DATABASE", _pDatabase);
            pPropertySet.SetProperty("USER", _pUser);
            pPropertySet.SetProperty("PASSWORD", _pPassword);
            pPropertySet.SetProperty("VERSION", _pVersion);
            workspaceFactory = (ESRI.ArcGIS.Geodatabase.IWorkspaceFactory2)new ESRI.ArcGIS.DataSourcesGDB.SdeWorkspaceFactoryClass();
            try
            {
                pWkspace = workspaceFactory.Open(pPropertySet, 0);
            }
            catch (Exception EX)
            {
                //MessageBox.Show(EX.ToString());
            }
            return pWkspace;
        }
只是在传入参数的时候注意_pInstance一般的格式为：sde：postgresql:localhost等。
2、创建.sde文件
    要创建.sde文件需要用到IWorkspaceFactory 的Create方法（也可以使用ArcToolBox里的工具，参考另一篇文章《ArcGIS 10.1中的Desktop连接ArcSDE》），该方法要有数据库连接的参数信息，在这里我用的是Postgresql数据库，代码如下：
//创建.sde文件并连接数据库
        IWorkspace SDEConnect(string FolderPath, string FileName, String _pServerIP, String _pInstance, String _pUser, String _pPassword, String _pVersion, string _pDatabase, bool _pTrue)
        {
            string pSDEPath = System.IO.Path.Combine(FolderPath, FileName);
            IWorkspaceFactory pWSFactory = new SdeWorkspaceFactoryClass();
            IWorkspace pWorkspace = null;
            if (!File.Exists(pSDEPath))
            {
                IWorkspaceName pWSName = pWSFactory.Create(FolderPath, FileName, GetPropertySet(_pServerIP, _pInstance, _pUser, _pPassword, _pVersion, _pDatabase, _pTrue), 0);
            }
            
                  pWorkspace = pWSFactory.OpenFromFile(pSDEPath, 0);
                  return pWorkspace;
        }
//最后一个参数表示直连还是服务连接
        public IPropertySet GetPropertySet(String _pServerIP, String _pInstance, String _pUser, String _pPassword, String _pVersion, string _pDatabase, bool _pTrue)
       
            {
               
                ESRI.ArcGIS.esriSystem.IPropertySet pPropertySet = new ESRI.ArcGIS.esriSystem.PropertySetClass();
                pPropertySet.SetProperty("SERVER", _pServerIP);
                pPropertySet.SetProperty("USER", _pUser);
                pPropertySet.SetProperty("PASSWORD", _pPassword);
                pPropertySet.SetProperty("VERSION", _pVersion);
                if (_pTrue)
                {
                    if (_pInstance.Contains(":"))
                    {
                        pPropertySet.SetProperty("INSTANCE", _pInstance);
                        pPropertySet.SetProperty("database", _pDatabase);
                    }
                    else
                    {
                        MessageBox.Show("直连字符串不对！");
                    }
                }
                else
                {
                    pPropertySet.SetProperty("INSTANCE", _pInstance);
                }
                return pPropertySet;
            }
        
直连
IWorkspace pSDE = SDEConnect("C:\\", "sde.sde", "localhost", "sde:postgresql:localhost", "sde", "sde", "sde.DEFAULT", "sde", true);
服务连接：
IWorkspace pSDE = SDEConnect("C:\\", "service.sde", "localhost", "5151", "sde", "sde", "sde.DEFAULT", "sde", false);

来源： <http://blog.csdn.net/esrichinacd/article/details/8561183>
 
