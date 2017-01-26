MongoDB设置访问权限、设置用户
MongoDB已经使用很长一段时间了，基于MongoDB的数据存储也一直没有使用到权限访问（MongoDB默认设置为无权限访问限制），今天特地花了一点时间研究了一下，研究成果如下：
注：研究成果基于Windows平台
其它详细的权限设置命令可参考：http://docs.mongodb.org/manual/reference/security/

MongoDB在本机安装部署好后
1. 输入命令：show dbs，你会发现它内置有两个数据库，一个名为admin，一个名为local。local好像没啥用，如果哪位在使用过程中发现了这个local表的用途，希望能够留言提醒，那我们就专心来说说admin表
2. 输入命令：use admin，你会发现该DB下包含了一个system.user表，呵呵，没错，这个表就等同于MsSql中的用户表，用来存放超级管理员的，那我们就往它里面添加一个超级管理员试试看
注：在不同数据库里添加用户之后，该用户的权限及拥有数据库是不同的，比如在admin下添加的用户为root，其它数据库下添加的用户为该数据库的Owner，在system.user表中有详细的记录
例如：> db.system.users.find()
{ "_id" : "system.wyz2", "user" : "wyz2", "db" : "system", "credentials" : { "MONGODB-CR" : "56d9f25f4be8d334158cd1ae8eb370af" }, "roles" : [ { "role" : "dbOwner", "db" : "system" } ] }
{ "_id" : "aa.wyz", "user" : "wyz", "db" : "aa", "credentials" : { "MONGODB-CR": "d3ee5f6e20a6163a395d4720316c253b" }, "roles" : [ { "role" : "dbOwner", "db" : "aa" } ] }
{ "_id" : "admin.sa", "user" : "sa", "db" : "admin", "credentials" : { "MONGODB-CR" : "75692b1d11c072c6c79332e248c4f699" }, "roles" : [ { "role" : "root", "db": "admin" } ] }
3. 输入命令：db.addUser('sa','sa')，这里我添加一个超级管理员用户，username为sa，password也为sa，即然我们添 加了超级管理员，那咱们就来测试下，看看咱们再次连接MongoDB需不需要提示输入用户名、密码，我们先退出来(ctrl+c)
4. 输入命令：use admin
5. 输入命令：show collections，查看该库下所有的表，你会发现，MongoDB并没有提示你输入用户名、密码，那就奇怪了，这是怎么回事呢？在文章最开始提到了，
MongoDB默认设置为无权限访问限制，即然这样，那我们就先把它设置成为需要权限访问限制，咱们再看看效果，怎么设置呢？
6. 在注册表中，找到MongoDB的节点，在它的ImgPath中，我们修改一下，加入 -auth，如下所示：
"D:\Program Files\mongodb\bin\mongod" -dbpath  e:\work\data\mongodb\db  -logpath  e:\work\data\mongodb\log -auth -service
7. 输入命令：use admin
8. 输入命令：show collections，呵呵，我们发现无法查看该库下的表了，提示："$err" : "unauthorized db:admin lock type:-1 client:127.0.0.1"，很明显，提示没有权限，看来关键就在于这里，我们在启动MongoDB时，需要加上-auth参数，这样我们设置的权限才能生效，好，接下来我们使用刚刚之前设置的用户名、密码来访问
9. 输入命令：db.auth('sa','sa')，输出一个结果值为1，说明这个用户匹配上了，如果用户名、密码不对，会输入0
10. 输入命令：show collections，呵呵，结果出来了，到这里，权限设置还只讲到一多半，接着往下讲，我们先退出来(ctrl+c)
11. 输入命令：mongo TestDB，我们尝试连接一个新的库（无论这个库是否存在，如果不存在，往该库中添加数据，会默认创建该库），然后，我们想看看该库中的表
12. 输入命令：show collections，好家伙，没权限，我们输入上面创建的用户名、密码
13. 输入命令：db.auth('sa','sa')，输入结果0，用户不存在，这下有人可能就不明白了，刚刚前面才创建，怎么会不存在呢？原因在于：当我们单独访问MongoDB的数据库时，需要权限访问的情况下，用户名密码并非超级管理员，而是该库的system.user表中的用户，注意，我这里说的是单独访问的情况，什么是不单独访问的情况呢？接下来再讲，现在咋办，没权限，那我们就尝试给库的system.user表中添加用户
14. 输入命令：db.addUser('test','111111')，哇靠，仍然提示没有权限，这可咋办，新的数据库使用超级管理员也无法访问，创建用户也没有权限，呵呵，别急，即然设定了超级管理员用户，那它就一定有权限访问所有的库
15. 输入命令：use admin
16. 输入命令：db.auth('sa','sa')
17. 输入命令：use TestDB
18. 输入命令：show collections，哈哈，一路畅通无阻，我们发现可以利用超级管理员用户访问其它库了，呵呵，这个就是不单独访问的 情况，不难发现，我们是先进入admin库，再转到其它库来的，admin相当于是一个最高级别官员所在区域，如果你是个地产商，想在地方弄个大工程做 做，你想不经过那些高级官员就做，这是行不通的，你需要先去到他们那里，送点礼，再顺着下到地方，工程你就可以拿到手了，此言论仅为个人观点，不代表博客 园；即然工程拿到手了，就要开始建了，那我们不至于每加块砖、添个瓦都得去和那帮高级官员打招呼吧，所以我们得让这个工程合法化，咱们得把相关的手续和证 件弄齐全，不至于是违建
19. 输入命令：db.addUser('test','111111')，我们给TestDB库添加一个用户，以后每次访问该库，我都使用刚刚创建的这个用户，我们先退出（ctrl+c）
20. 输入命令：mongo TestDB
21. 输入命令：show collections，提示没有权限
22. 输入命令：db.auth('test','111111')，输出结果1，用户存在，验证成功
23. 输入命令：show collections，没再提示我没有权限，恭喜您，成功了
好累啊！一口气写完，呵呵
注：当需要使用权限才能访问MongoDB时，如果需要查看MongoDB中所有的库，我们只能通过超级管理员权限，输入命令show dbs来查看了。

来源： <http://www.cnblogs.com/zengen/archive/2011/04/23/2025722.html>
 

