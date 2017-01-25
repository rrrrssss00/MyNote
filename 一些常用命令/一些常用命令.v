export :单独使用查看所有变量 ,带参数的话可以修改变量的值 ,如export $LANG=en_US.UTF-8
echo: 显示变量值 ,例如 echo $ORACLE_HOME
resource: 运行BAT ,例如: resource .bash_profile
su:切换用户
sudo:用管理员权限运行
 
apt-get : debian&ubuntu?在线安装
 
ls:列出目录下的文件及文件夹
    ls -a  列出所有文件,包括隐藏文件
    -S 根据文件大小排序  -t 根据文件修改时间排序
    -R 列出所有子目录
     | grep 筛选
 
mkdir 创建子目录
 
chmod +x:为文件添加可执行权限 ,(如果必要可以在前面加sudo)

ps -ef:列出当前进程  ps -ef | grep oracle 列出与oracle相关的进程

lsnrctl status：查看网络监听程序的状态

