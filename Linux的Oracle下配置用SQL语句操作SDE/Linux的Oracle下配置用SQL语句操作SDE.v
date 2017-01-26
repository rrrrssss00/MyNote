主要注意的包括以下几点（9.3为例）：
1：有没有安装库，比如我们的情况，Oracle部署在单独的服务器上，而ArcSDE服务部署在另外一台服务器上，这样，Oracle的服务器上没有安装ArcSDE的库文件，这样肯定是无法直接使用SQL语句操作SDE的，需要在Linux服务器上安装一个相应版本的SDE，或直接将以下几个文件拷贝到#Oracle_HOME下的Lib文件夹中，（$SDEHOME/libpe.so, $SDEHOME/libsg.so, and $SDEHOME/libst_shapelib），参考：
I was working on a sticky problem of which I had a hard time resolving so I figured I would write up my issue and my solution.
Recently, we were running a ST_INTERSECTION query on a spatial dataset using ESRI SDE’s ST_GEOMETRY. In Oracle 11.2.0.2, the ST_INTERSECTION query hit the following error stack:
ORA-29902: error in executing ODCIIndexStart() routine
ORA-28578: protocol error during callback from an external procedure
ORA-6512: at "SDE.ST_GEOMETRY_SHAPELIB_PKG", line 943
ORA-6512: at "SDE.SPX_UTIL", line 2960
ORA-6512: at "SDE.SPX_UTIL", line 3221
ORA-6512: at "SDE.ST_DOMAIN_METHODS", line 293
ORA-6512: at line 194
Now line 194 in our code contained the query using the ST_INTERSECTION operator. I could find plenty of hits on Google and Metalink related to the ORA-29902 error. And plenty of hits on the ORA-28578 error. But I could not find any hits on both the 29902 and the 28578 error together. So I had very little to go on. Every hit I looked at was not representative of my specific problem.
The ORA-29902 error is basically saying that there is an error when trying to start the evaluation of an operator (ST_INTERSECTION in my case). It is the ORA-28578 error that is the root cause. I arrived at the conclusion that Oracle was not able to load the SDE external library routines.
To make our life easier, we just drop $SDEHOME/libpe.so, $SDEHOME/libsg.so, and $SDEHOME/libst_shapelib.so into $ORACLE_HOME/lib so that ST_GEOMETRY external procedure calls do not need additional configuration. This method has worked fine for us to date. However, I recently upgraded a development database from Oracle 11.1.0.7 to 11.2.0.2. The troublesome code worked just fine in our 11.1 database but failed with the above errors in our 11.2 database. So do we have a problem with the higher version?
I verified that I had the proper SDE library files in $ORACLE_HOME. I checked the file permissions on these files. Even though I did not need to do so in prior versions, I explicitly configured EXTPROC in the Listener and bounced the Listener. All to no resolution of my problem.
Somewhere in my search of the answer, I stumbled on a config file that I needed to modify to get this to work. In the $ORACLE_HOME/hs/admin, you need to make sure you have the following line:
SET EXTPROC_DLLS=ANY
By default, Oracle 11.2.0.2 just has “SET EXTPROC_DLLS=” with no value. By setting this to ANY, you let Oracle allow any external libraries to be accessed. In Oracle 11.1.0.7, the default value is ANY. I have not seen it documented anywhere that there is a change in this default value from 11.1 to 11.2. So hopefully, by blogging this solution, it will help someone else in the future.

来源： <http://www.peasland.net/?p=67>
 
2.库文件的版本是不是正确，注意Oracle的版本和SDE库文件版本是否对应，SDE版本是否正确，32位和64位是否正确
例如，如何32位与64位弄错了，会报类似“wrong ELF class: ELFCLASS32”，这种错误

3.库文件的设置是否正确，用select * from dba_libraries查询库的设置，看是否有ST_SHAPELIB这个库设置，而且需要看它的路径是否正确，如果不正确，可以用create or replace library ST_SHAPELIB is '/*******/***/***' 这个语句来设置一下，参考以下几篇
http://forums.arcgis.com/threads/73476-ST_GEOMETRY-problem-on-Oracle-RDBMS-11g-R2-11.2.0.3
http://support.esri.com/es/knowledgebase/techarticles/detail/33003
http://resources.arcgis.com/en/help/main/10.1/index.html#//002n00000091000000


