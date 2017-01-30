分布式部署 ArcSDE 和 Oracle 服务

    作者：Flyingis

    ArcEngine、ArcIMS或ArcGIS Server开发时，SDE和Oracle数据库部署在一台服务器上早已是家常便饭，像我的notebook就是一锅出，什么都有，用起来方便，甚至不少最终产品部署的时候都是如此，考虑更多的是webserver集群，Oracle双机热备等等，SDE和Oracle就凑合放在一块了。那么，什么时候需要将两者分开呢？分散服务负载是一种考虑，经典服务器配置理论就是一台服务器一个核心服务，不仅分散服务器的负载，还便于压力测试，方便调试与维护，或是在不同的操作系统平台上进行安装配置，如Oracle数据库在Solaris系统，SDE安装在Windows2003或Suse10企业版上，具体应该如何配置呢？下面给出教条一二三，针对ArcSDE9.x和Oracle9i/10g：

1.首先应该将Oracle安装在单独服务器上并进行dbca，正常监听和启动服务。
2.在SDE服务器上安装Oracle Network Software，以便在SDE服务器上执行sql操控远程Oracle服务器，相对于SDE服务器是Oracle服务器的一个客户端。
3.根据不同的操作系统安装SDE，post时需要做一点调整，在Windows平台上，需手工创建sde服务，因为post无法为远程SDE服务器创建sde服务。
sdeservice -o create -d ORACLE10G,ORACLE_SID -i esri_sde -p password -n
    注意，后面要加上参数"-n"！Windows平台上不能分布式部署SDE8.x。

    环境变量设置：

    SDE服务器只有写入相应的环境变量后，才能让Oracle Network Software找到Oracle服务。Windows系统中，需要设置SDEHOME\etc\dbinit.sde，加入set LOCAL=netservicename，在sde服务创建后写入。Unix系统要在环境变量中添加TWO_TASK，和Oracle双机安装SDE一样，当然少不了TNS_ADMIN。SDE服务启动时，giomgr进程会读取dbinit.sde里的变量值，它们会覆盖.cshrc 和.profile中的值，这里需要注意。
 
 
注意:使用sdemin -o start启动服务,这样如果有相关的错误信息,会从命令行显示,便于调试
