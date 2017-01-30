 用VS2005制作MSI安装包时，发现自动生成的快捷方式会有问题。和手工创建的快捷方式不同，其创建的快捷方式属性中的”目标”项不定位到可执行文件本身，而是目录。导致一些兼容问题，比如在蛙灵桌面上就打不开… 而且据说删除软件相关的文件后，点击快捷方式会弹出安装界面，保证软件的完整性。这显然很麻烦，解决方法如下：
这个是VS自己的问题，微软的帮助和支持网站上已经指出并提出了解决方案。但是网站上的解决方案讲的并不清楚。
简单的解决方案为：
1.先去下载msi编辑软件orca，可以去这里下载：http://www.52z.com/soft/10568.Html
2.启动orca。
3.在“文件”菜单中上, 单击“打开”。
4.在“打开”对话框找到包含YourApplicationSetup.msi文件的文件夹。
5.单击YourApplicationSetup.msi文件，然后单击“打开”。
6.在“表”窗格中，单击“shortcut”。
7.在右窗格中，选择在“Name”列中对应“YourApplication.exe”值的行，点击该行的“Target”列，VS安装程序生成的快捷方式对应的值为“DefaultFeature”，将其改为“[TARGETDIR]\YourApplication.exe”。
8.在“文件”菜单上点击“保存”，然后退出orca编辑器。
 
参考资料：http://topic.csdn.net/u/20090310/15/f7909ba4-1100-49a1-ad97-53b77f0dbf85.html
http://support.microsoft.com/kb/830612/en-us
