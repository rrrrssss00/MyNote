【原创】System.Data.SQLite内存数据库模式

2014-01-23 22:40 by xiexiuli, ... 阅读, ... 评论, 收藏, 编辑
对于很多嵌入式数据库来说都有对于的内存数据库模式，SQLite也不 例外。内存数据库常常用于极速、实时的场景，一个很好的应用的场景是富客户端的缓存数据，一般富客户端的缓存常常需要分为落地和非落地两种，而反应到 SQLite上就是主要两种模式，一种是文件类型的数据库，一种是内存模式的。而我们常常需要做的是系统启动初从文件数据库加载到内存数据库，然后在系统 退出或定时的将内存数据回写到文件数据库。这种导入和导出操作，在C#版本的SQLite库中已经原生进行了支持。而C版本中实际上对应了三个函数，你可 以参照SQLite Online Backup API 。 
其实本人在查找SQLite的内存模式和文件模式相互备份资料的时候，发现关于使用System.Data.SQLite.dll来进行两种模式相互备份的例子比较少，而且在国内的许多网站上找不到可以直接复用的代码，即时找到了也总是夹杂着很多C版本的实现，总是让人有些摸不着头脑。虽然如此，功夫不负有心人，在stackoverflow上找到了自己想要的代码，通过反编译看System.Data.SQLite.dll看SQLiteConnection中有一个方法BackupDatabase(......)，通过它可以实现数据库间的备份。
BackupDatabase(......)方法的反编译的源码如下：
// The method in System.Data.SQLite.SQLiteConnection
        public void BackupDatabase(SQLiteConnection destination, string destinationName, string sourceName, int pages, SQLiteBackupCallback callback, int retryMilliseconds)
        {
            //省略参数检查和连接状态检查代码
            //
            SQLiteBase sql = this._sql;
            if (sql == null)
            {
                throw new InvalidOperationException("Connection object has an invalid handle.");
            }
            SQLiteBackup sQLiteBackup = null;
            try
            {
                sQLiteBackup = sql.InitializeBackup(destination, destinationName, sourceName);
                bool flag;
                while (sql.StepBackup(sQLiteBackup, pages, out flag) && (callback == null || callback(this, sourceName, destination, destinationName, pages, sql.RemainingBackup(sQLiteBackup), sql.PageCountBackup(sQLiteBackup), flag)))
                {
                    if (flag && retryMilliseconds >= 0)
                    {
                        Thread.Sleep(retryMilliseconds);
                    }
                    if (pages == 0)
                    {
                        break;
                    }
                }
            }
            catch (Exception ex)
            {
                if ((this._flags & SQLiteConnectionFlags.LogBackup) == SQLiteConnectionFlags.LogBackup)
                {
                    SQLiteLog.LogMessage(0, string.Format(CultureInfo.CurrentCulture, "Caught exception while backing up database: {0}", new object[]
			{
				ex
			}));
                }
                throw;
            }
            finally
            {
                if (sQLiteBackup != null)
                {
                    sql.FinishBackup(sQLiteBackup);
                }
            }
        }
从上面这段代码我们可以简单的看出，实际上备份还是通过InitializeBackup，StepBackup，FinishBackup这三个方法来实现。这三个方法分别对应的本地方法是sqlite3_backup_init，sqlite3_backup_step，sqlite3_backup_finish；关于这个三个方法的说明可以参考SQLite Online Backup API 。 
接下来，将直接贴代码来展示如何在C#中使用System.Data.SQLite.dll来进行SQLite文件数据库与内存数据库相互备份。
//
//  软件版权： http://xiexiuli.cnblogs.com/
//  作者：     xiexiuli
//  创建时间： 2014-01-20
//  功能说明： SQLite内存数据库模式的管理器
//  修改历史：
//  
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SQLite;
using System.IO;

namespace LongThinking.Data
{ 
    /// <summary>
    /// SQLite内存数据库模式的处理器
    /// </summary>
    public class SQLiteMemoryManager : IDisposable
    {
        /// <summary>
        /// 每个内存数据库都保持一个自己的连接
        /// </summary>
        private SQLiteConnection _globalConnection;

        #region 构造函数
        public SQLiteMemoryManager()
        {
            var str = "Data Source=:memory:;Version=3;New=True;";
            _globalConnection = new SQLiteConnection(str);
            _globalConnection.Open();
        }
        #endregion 

        #region 备份数据库
        /// <summary>
        /// 备份数据库 
        /// </summary>
        /// <param name="dbFileConnectString">指定到文件数据库路径的连接串</param>
        /// <param name="isFileToMemory">
        /// 是否是文件数据库备份到内存数据库；
        /// isFileToMemory为true指的是从文件数据库导入到当前内存数据库；
        /// isFileToMemory为false指的是从当前内存数据库导出到文件数据库。
        /// </param>
        public void BackupDatabase(string dbFileConnectionString, bool isFileToMemory)
        {
            using (SQLiteConnection dbfileConnection = new SQLiteConnection(dbFileConnectionString))
            {
                this.BackupDatabase(dbfileConnection, isFileToMemory);
            }
        }

        /// <summary>
        /// 备份数据库
        /// </summary>
        /// <param name="dbPath">指定到文件数据库的文件全路径</param>
        /// <param name="password">文件数据库密码</param>
        /// <param name="isFileToMemory">
        /// 是否是文件数据库备份到内存数据库；
        /// isFileToMemory为true指的是从文件数据库导入到当前内存数据库；
        /// isFileToMemory为false指的是从当前内存数据库导出到文件数据库。
        /// </param>
        public void BackupDatabase(string dbPath, string password, bool isFileToMemory)
        { 
            string dbFileConnectString = "Data Source=" + dbPath + ";Pooling=true;FailIfMissing=false;Password=" + password;
            using (SQLiteConnection dbfileConnection = new SQLiteConnection(dbFileConnectString))
            {
                this.BackupDatabase(dbfileConnection, isFileToMemory);
            }
        }

        /// <summary>
        /// 备份数据库
        /// </summary>
        /// <param name="dbfileConnection">文件数据库的连接，该连接状态需要是打开的或者是未打开过；关闭状态的连接，默认会帮你打开</param>
        /// <param name="isFileToMemory">
        /// 是否是文件数据库备份到内存数据库；
        /// isFileToMemory为true指的是从文件数据库导入到当前内存数据库；
        /// isFileToMemory为false指的是从当前内存数据库导出到文件数据库。
        /// </param>
        public void BackupDatabase(SQLiteConnection dbfileConnection, bool isFileToMemory)
        {
            //如果连接是关闭状态就打开
            if (dbfileConnection.State == ConnectionState.Closed)
            {
                dbfileConnection.Open();
            }

            if (isFileToMemory)
            {
                dbfileConnection.BackupDatabase(_globalConnection, "main", "main", -1, null, 0);
            }
            else
            {
                _globalConnection.BackupDatabase(dbfileConnection, "main", "main", -1, null, 0);
            }
        }

        #endregion

        #region 销毁
        ~SQLiteMemoryManager()
        {
            this.Dispose(true);
        }

        public void Dispose()
        {
            this.Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected void Dispose(bool disposing)
        {
            if (disposing)
            {
                if (_globalConnection != null)
                {
                    _globalConnection.Dispose();
                }
            }
        }
        #endregion
    }
}
　　上面的代码我已经删除很多数据操作的方法，等我测试完那些操作方法将提供完整版的类和工程供大家下载。
 
参考：
http://www.sqlite.org/backup.html
http://stackoverflow.com/questions/17298988/system-data-sqlite-backupdatabase-throws-not-an-error

来源： <http://www.cnblogs.com/xiexiuli/p/DB_SQLite_Backup_CSharp.html>
 

