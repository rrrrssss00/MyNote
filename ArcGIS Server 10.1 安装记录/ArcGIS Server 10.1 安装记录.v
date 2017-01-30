拿到了ArcGIS Server 10.1 的安装包，今天有时间上手安装试着用一下，记录过程如下：
 
1：基础环境，在虚拟机下安装的，使用的是win2008 Server r2sp1系统，
 
            由于10.1 Server是原生64位，无法在32位系统下安装，还为此捣腾了半天。。。。
            
            在安装前，使用“打开或关闭Windows功能”把.net framework 3.5.1 以及iis 7.0安装上
 
2：安装过程，很顺利，也非常快，没遇到什么问题，这个就不多写了
 
3：破解 -_-b，直接用10.0版本的Keygen生成ECP就行，不过注意，版本一栏里得自己填上101（原来没有，而且不能填10.1），生成就能够使用
 
4：生成网站：输入管理员的用户名和密码，定义好文件存储的位置，就可以生成网站了，过程中遇到了两个如下的问题：
 
            1)Failed to create the site. Failed to create the service 'System/CachingTools.GPServer'.
                    查了一下，这个问题多数是由于防火墙造成的，在防火墙设置里，将以下几个文件加入排除列表即可：                    
                    ArcGISServer.exe   <Install>\ArcGIS\Server\framework\etc\service\bin\ArcGISServer.exe
                    ArcSOC.exe         <Install>\ArcGIS\Server\bin\ArcSOC.exe
                    javaw.exe          <Install>\ArcGIS\Server\framework\runtime\jre\bin\javaw.exe
                    rmid.exe           <Install>\ArcGIS\Server\framework\runtime\jre\bin\rmid.exe
 
            2）Server failed to create the site： null
                    这个问题没有查到原因，重启系统，问题解决。。。
 
 
完成
 
    
 
 
