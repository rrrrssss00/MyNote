using System;
using System.Collections.Generic;
using System.Text;
using DDTek.Oracle;
using System.IO;
using System.Collections;
using System.Data;
 
namespace DDTekDBTool2
{ 
    /// <summary>数据库(Oracle)相关操作类,包含连接,查询,修改,SQL语句执行等</summary>
    public class DBTool
    {
        /// <summary>Oracle连接</summary>
        private static OracleConnection mCon = new OracleConnection();
 
        /// <summary>Oracle连接</summary>
        public static OracleConnection con
        { get { return mCon; } }
 
        /// <summary>Oracle数据库连接串</summary>
        private static string conString = "";
 
        /// <summary>Oracle数据库事务</summary>
        private static OracleTransaction trans = null;
 
        /// <summary>Oracle数据库命令</summary>
        private static OracleCommand comm = null;
 
        private DBTool()
        {
        }
 
        #region 数据库连接相关
         /// <summary>设置数据库连接串</summary>
        /// <param name="connectString">数据库连接串</param>
        public static void SetConnectString(string connectString)
        {
            conString = connectString;
        }
 
        /// <summary>连接数据库</summary>
        /// <returns>连接数据库是否成功</returns>
        public static bool Connect()
        {
            try
            {
                mCon = new OracleConnection(conString);
                mCon.Open();
 
                return true;
            }
            catch (Exception ex)
            {
                return false;
            }
        }
 
        /// <summary>断开与数据库之间的连接</summary>       
        public static void Disconnect()
        {
            try
            {
                if (mCon.State == ConnectionState.Open)
                {
                    mCon.Close();
                }
            }
            catch (Exception ex)
            {
                return;
            }
 
        }
 
        /// <summary>目前是否正在与数据连接</summary>
        /// <returns>是否连接数据库</returns>
        public static bool IsConnected()
        {
            if (mCon.State == System.Data.ConnectionState.Open)
                return true;
            else return false;
        }
        #endregion
 
        #region 数据库事务相关
        /// <summary>开启数据库事务</summary>
        /// <returns>是否成功开启数据库事务</returns>
        public static bool TransactionBegin()
        {
            try
            {
                //数据库业务初始化
                if (!IsConnected())
                    Connect();
 
                trans = con.BeginTransaction();
                comm = con.CreateCommand();
                comm.Transaction = trans;
                return true;
            }
            catch (Exception)
            {
                trans.Rollback();
                comm = null;
                trans = null;              
                return false;
            }          
        }
 
        /// <summary>回滚数据库事务</summary>
        /// <returns>是否成功回滚数据库事务</returns>
        public static bool TransactionRollback()
        {
            try
            {
                trans.Rollback();
                comm = null;
                trans = null;
                return true;
            }
            catch (Exception)
            {
                comm = null;
                trans = null;               
                return false;
            }
        }
 
        /// <summary>提交数据库事务</summary>
        /// <returns>是否成功提交数据库事务</returns>
        public static bool TransactionCommit()
        {
            try
            {
                trans.Commit();
                comm = null;
                trans = null;
                return true;
            }
            catch (Exception)
            {
                comm = null;
                trans = null;
                return false;
            }
        }
        #endregion
 
        #region 查询函数
        /// <summary>数据库通用查询</summary>
        /// <param name="sSql">查询SQL语句</param>
        /// <returns>查询得到的DataTable</returns>
        public static DataTable Query(string sSql)
        {
            try
            {               
                OracleDataAdapter mAdp = new OracleDataAdapter(sSql, mCon);
                if (trans != null) mAdp.SelectCommand.Transaction = trans;
                DataTable mDst = new DataTable();
                mAdp.Fill(mDst);
                return mDst; 
            }
            catch (Exception e)
            {
                return null;
            }
        }
 
        /// <summary>数据库精确查询 示例:DBTool.QueryExact("表名","字段1,字段2,字段3","'值1','值2','值3'")</summary>
        /// <param name="sTab">要查询的表</param>
        /// <param name="sQueryField">查询条件的字段值</param>
        /// <param name="sValue">查询条件的值</param>
        /// <returns>查询结果DataTable</returns>
        public static DataTable QueryExact(string sTab, string sQueryField, string sValue)
        {
            return Query("select * from " + sTab + " where " + sQueryField + " = '" + sValue + "'");
        }
 
        /// <summary>数据库精确查询 示例:DBTool.QueryExact("表名","返回字段","字段1,字段2,字段3","'值1','值2','值3'")</summary>
        /// <param name="sTab">要查询的表</param>
        /// <param name="sReturnField">返回的字段</param>
        /// <param name="sQueryField">查询条件的字段值</param>
        /// <param name="sValue">查询条件的值</param>
        /// <returns>查询结果DataTable</returns>
        public static DataTable QueryExact(string sTab, string sReturnField, string sQueryField, string sValue)
        {
            return Query("select " + sReturnField + " from " + sTab + " where " + sQueryField + " = '" + sValue + "'");
        }
 
        /// <summary>数据库精确查询 示例:DBTool.QueryExact("表名","返回字段","字段1,字段2,字段3","'值1','值2','值3'","排序字段")</summary>
        /// <param name="sTab">要查询的表</param>
        /// <param name="sReturnField">返回的字段</param>
        /// <param name="sQueryField">查询条件的字段值</param>
        /// <param name="sValue">查询条件的值</param>
        /// <param name="sOrder">返回时的排序字段</param>
        /// <returns>查询结果DataTable</returns>
        public static DataTable QueryExact(string sTab, string sReturnField, string sQueryField, string sValue, string sOrder)
        {
            return Query("select " + sReturnField + " from " + sTab + " where " + sQueryField + " = '" + sValue + "' order by " + sOrder);
        }
 
        /// <summary>字段唯一值查询</summary>
        /// <param name="sTab">要查询的表</param>
        /// <param name="sField">查询唯一值的字段</param>
        /// <returns>查询结果DataTable</returns>
        public static DataTable QueryDistinct(string sTab, string sField)
        {
            return Query("select distinct " + sField + " from " + sTab + " where " + sField + " is not null");
        }
 
        /// <summary>表行数查询</summary>
        /// <param name="sTab">要查询的表</param>
        /// <returns>查询结果行数</returns>
        public static int QueryRowCount(string sTab)
        {
            DataTable tmp = Query("select count(*) from " + sTab);
            if (tmp == null)
            {
                return 0;
            }
            else
            {
                int tmpInt = 0;
                int.TryParse(tmp.Rows[0][0].ToString(), out tmpInt);
                return tmpInt;
            }
 
        }
        #endregion
 
        #region 记录的增删改函数
        /// <summary>向数据库某表中插入一行 示例:DBTool.Insert("表名","字段1,字段2,字段3","'值1','值2','值3'")</summary>
        /// <param name="sTab">欲插入行的表</param>
        /// <param name="sField">欲插入行的字段</param>
        /// <param name="sValue">新值</param>
        /// <returns>命令影响的行数</returns>
        public static int Insert(string sTab, string sField, string sValue)
        {
            string sSql = "insert into " + sTab + "(" + sField + ") values(" + sValue + ")";
 
            if (trans == null)
            {
                OracleCommand mCmd = new OracleCommand(sSql, mCon);
                try
                {
                    return mCmd.ExecuteNonQuery();
                }
                catch (Exception)
                {
                    return 0;
                }
            }
            else
            {
                comm.CommandText = sSql;
                try
                {
                    return comm.ExecuteNonQuery();
                }
                catch (Exception)
                {
                    return 0;
                }
            }
        }
 
        /// <summary>
        /// 删除数据库中某表中的某些行 示例:int rowNum = DBTool.Delete("表名","字段名1 || 字段名2 || 字段名3","值1值2值3")    
        /// </summary> 
        /// <param name="sTab">欲删除行的所在表</param>
        /// <param name="sKey">欲删除行的特征字段/字段组合</param>
        /// <param name="sKeyValue">欲删除行的特征字段/字段组合对应的值</param>
        /// <returns>命令影响的行数</returns>
        /// 
        public static int Delete(string sTab, string sKey, string sKeyValue)
        {
            string sSql = "delete from " + sTab + " where " + sKey + "='" + sKeyValue + "'";
 
            return Execute(sSql);
        }
 
        /// <summary>更新数据库中某表中的某些值</summary>
        /// <param name="sTab">欲修改的表</param>       
        /// <param name="sKey">欲修改的值所在行的特征字段/字段组合</param>
        /// <param name="sKeyValue">欲修改的值所在的特征字段/字段组合对应的值</param>
        /// <param name="sFld">欲修改值的所在字段</param>
        /// <param name="sValue">新值</param>
        /// <returns>命令影响的行数</returns>
        public static int Update(string sTab, string sKey, string sKeyValue, string sFld, string sValue)
        {
            string sSql = "update " + sTab + " set " + sFld + "='" + sValue + "' where " + sKey + "='" + sKeyValue + "'";
 
            return Execute(sSql);
        }
 
        /// <summary>更新数据库中某表中的时间值</summary>
        /// <param name="sTab">欲修改的表</param>       
        /// <param name="sKey">欲修改的值所在行的特征字段/字段组合</param>
        /// <param name="sKeyValue">欲修改的值所在的特征字段/字段组合对应的值</param>
        /// <param name="sFld">欲修改时间的所在字段</param>
        /// <param name="sValue">新值</param>
        /// <returns>命令影响的行数</returns>
        public static int UpdateTime(string sTab, string sKey, string sKeyValue, string sFld, string sValue)
        {
            string sSql = "update " + sTab + " set " + sFld + "=to_date('" + sValue + "','yyyy-mm-dd') where " + sKey + "='" + sKeyValue + "'";
 
            return Execute(sSql);
        }
 
         /// <summary>执行sql语句</summary>
        /// <param name="sSql">欲执行的语句</param>
        /// <returns>是否成功执行</returns>
        public static int Execute(string sSql)
        {
            if (trans == null)
            {
                OracleCommand mCmd = new OracleCommand(sSql, mCon);
                try
                {
                    return mCmd.ExecuteNonQuery();
                }
                catch (System.Exception)
                {
                    return 0;
                }
            }
            else
            {
                comm.CommandText = sSql;
                try
                {
                    return comm.ExecuteNonQuery();
                }
                catch (Exception)
                {
                    return 0;
                }
            }
        }
        #endregion
 
        #region 功能函数
        /// <summary>将文件转为Byte数组</summary>
        /// <param name="sPath">转换的文件路径</param>
        /// <returns>转换结果</returns>
        private static byte[] GetBlob(string sPath)
        {
            FileStream fs = new FileStream(sPath, FileMode.Open, FileAccess.Read);
            BinaryReader br = new BinaryReader(fs);
            byte[] blob = br.ReadBytes((int)fs.Length);
            br.Close();
            fs.Close();
            return blob;
        }
 
        /// <summary>将Byte数组写到磁盘文件上</summary>
        /// <param name="sPath">写到的的文件路径</param>
        /// <param name="blob">要写到文件的Byte数组</param>
        private static void WriteBlob(string sPath, byte[] blob)
        {
            FileStream fs = new FileStream(sPath, FileMode.Create, FileAccess.Write);
            fs.Write(blob, 0, blob.Length);
            fs.Close();
        }
        #endregion
 
        #region BLOB相关
        /// <summary>插入一条含Blob（仅一个该类型的字段）字段的记录</summary>
        /// <param name="sTab">欲插入记录的表</param>
        /// <param name="sKeyField">该行除BLOB字段外其它字段的字段名</param>
        /// <param name="sKeyValue">该行除BLOB字段外其它字段的值</param>
        /// <param name="sBlobField">BLOB字段的字段名</param>
        /// <param name="sPath">要放入BLOB字段对应的本地文件</param>
        /// <returns>命令影响的行数</returns>
        public static int InsertRowWithBlob(string sTab, string sKeyField, string sKeyValue, string sBlobField, string sPath)
        {
            if (sPath == "") return 0;
            byte[] blob = GetBlob(sPath);
 
            if (trans == null)
            {
                OracleCommand mCmd = new OracleCommand("insert into " + sTab + " (" + sKeyField + "," + sBlobField + ") values(" + sKeyValue + ",?)", mCon);
                mCmd.Parameters.Add("m", OracleDbType.Blob, blob.Length).Value = blob;
                try
                {
                    return mCmd.ExecuteNonQuery();
                }
                catch (Exception)
                {
                    return 0;
                }
            }
            else
            {
                comm.CommandText = "insert into " + sTab + " (" + sKeyField + "," + sBlobField + ") values(" + sKeyValue + ",?)";
                comm.Parameters.Add("m", OracleDbType.Blob, blob.Length).Value = blob;
                try
                {
                    return comm.ExecuteNonQuery();
                }
                catch (Exception)
                {
                    return 0;
                }
            }
        }
 
        /// <summary>修改一条记录中的BLOB字段值</summary>
        /// <param name="sTab">欲修改记录的表</param>
        /// <param name="sKeyField">该行除BLOB字段外特征字段的字段名/字段名组合</param>
        /// <param name="sKeyValue">该行除BLOB字段外特征字段对应的字段值</param>
        /// <param name="sBlobField">BLOB字段的字段名</param>
        /// <param name="sPath">要修改的BLOB字段对应的本地文件路径</param>
        /// <returns>命令影响的行数</returns>
        public static int UpdateBlobToDb(string sTab, string sKeyField, string sKeyValue, string sBlobField, string sPath)
        {
            if (sPath == "") return 0;
            byte[] blob = GetBlob(sPath);
 
            if (trans == null)
            {
                OracleCommand mCmd = new OracleCommand("update " + sTab + " set " + sBlobField + " = ? where " + sKeyField + " = '" + sKeyValue + "'", mCon);
                mCmd.Parameters.Add(":mBlob", OracleDbType.Blob, blob.Length).Value = blob;
                try
                {
                    return mCmd.ExecuteNonQuery();
                }
                catch (System.Exception)
                {
                    return 0;
                }
            }
            else
            {
                comm.CommandText = "update " + sTab + " set " + sBlobField + " = ? where " + sKeyField + " = '" + sKeyValue + "'";
                comm.Parameters.Add("m", OracleDbType.Blob, blob.Length).Value = blob;
                try
                {
                    return comm.ExecuteNonQuery();
                }
                catch (Exception)
                {
                    return 0;
                }
            }
        }
 
        /// <summary>将一条记录中的BLOB字段值保存到本地文件</summary>
        /// <param name="sTab">记录所在表</param>
        /// <param name="sKeyField">该行除BLOB字段外特征字段的字段名/字段名组合</param>
        /// <param name="sKeyValue">该行除BLOB字段外特征字段对应的字段值</param>
        /// <param name="sBlobField">BLOB字段的字段名</param>
        /// <param name="sPath">要保存到的本地文件路径</param>
        public static void SaveBlobToFile(string sTab, string sKeyField, string sKeyValue, string sBlobField, string sPath)
        {
            try
            {
                DataTable mTab = Query("select " + sBlobField + " from " + sTab + " where " + sKeyField + "='" + sKeyValue + "'");
                byte[] blob = (byte[])mTab.Rows[0][0];
                WriteBlob(sPath, blob);
            }
            catch (Exception)
            {
                //throw ex;
            }
        }
        #endregion
 
    }
}

