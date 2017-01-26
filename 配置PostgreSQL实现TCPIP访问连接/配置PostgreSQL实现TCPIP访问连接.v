配置PostgreSQL实现TCP/IP访问连接

分类： 数据库 2007-09-20 16:21 1296人阅读 评论(4) 收藏 举报
自己的机器上装了PostgreSQL，也想让其他机器来共享我的数据库，那就需要做一下配置先~ 这里针对Windows下安装的PostgreSQL 8.2来说的，较低版本可能配置文件不尽相同~ 
1- 找到PostgreSQL的安装目录，进入data文件夹，打开postgresql.conf文件，修改listen_addresses，如下：

# - Connection Settings -

listen_addresses = 'localhost,123.123.123.123'        # what IP address(es) to listen on; 
                    # comma-separated list of addresses;
                    # defaults to 'localhost', '*' = all
                    # (change requires restart)
port = 5432                # (change requires restart)

注意：这里的'123.123.123.123'改称你的IP。

2- 也是在data文件夹下，打开pg_hba.conf文件，修改如下：

# TYPE  DATABASE    USER        CIDR-ADDRESS          METHOD

# IPv4 local connections:
host      all         all                 127.0.0.1/32          md5
host      all       postgres         123.123.0.0/16      password

# IPv6 local connections:
#host    all         all         ::1/128               md5

注意：这里的'123.123.0.0/16'是你允许访问你的数据库的网络,如果需要对全IP实现访问，就设为 0.0.0.0/0，password是指连接连接数据库时需要密码；postgres是指用户名，all是指所有数据库~

3- 到控制面板-管理工具-服务中，重新启动PostgreSQL服务
来源： <http://blog.csdn.net/shuaiwang/article/details/1793294>
 

