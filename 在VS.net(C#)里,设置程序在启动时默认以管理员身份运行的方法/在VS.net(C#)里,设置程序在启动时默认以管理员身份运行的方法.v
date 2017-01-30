在VS2008及VS2010中,方法比较简单:
<1>.在项目中“新建项”，选择“应用程序清单”(.manifest)，自己命名文件名称，
<2>.打开建立的清单文件，扩展名为.manifest，查看代码.我们可以看到有注释说明UAC选项，我们需要更改的是这个节点的内容：
    <requestedExecutionLevel level="asInvoker" uiAccess="false" />将asInvoker,更改为requireAdministrator
<3>.打开项目属性，将“应用程序-资源”中的“清单”一项选择为你创建的清单文件
<4>.再生成一次即可
 
在VS2005里则比较麻烦,没有测试过,将网上解决方案拷贝如下:
<1>看在Properties下是否有app.manifest这个文件；如没有，右击工程在菜单中选择“属性”，出现界面,在"安全性选项卡中, 在界面中勾选“启用ClickOnce安全设置”后，在Properties下就有自动生成app.manifest文件。打开app.manifest文件，在<security>下加入
    <requestedPrivileges>
        <requestedExecutionLevel level="requireAdministrator" cess="false"/>
    </requestedPrivileges>，
    重新编译即可，
