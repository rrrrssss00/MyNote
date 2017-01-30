示例代码如下：
注意，如果需要设置EnvironmentVariables，需要先将UseShellExecute设为False 

 System.Diagnostics.Process p = new System.Diagnostics.Process();
            p.StartInfo.FileName = Path.Combine(tmpPath+"bin", "mfe_app.exe");//需要启动的程序名
            p.StartInfo.Arguments = "rgfgrid.dll rgfgrid";//启动参数
            p.StartInfo.UseShellExecute = false;
            p.StartInfo.EnvironmentVariables["WL_PLUGINS_HOME"] = tmpPath;
            p.StartInfo.EnvironmentVariables["EXECDIR"] = tmpPath;
            p.Start();//启动
