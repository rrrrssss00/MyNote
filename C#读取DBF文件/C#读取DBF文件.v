using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
namespace shoufei
{


    /**/
    /// <summary>
    /// .dbf 文件的文件头信息类
    /// </summary>
    internal class DBFHeader
    {
        public const int DBFHeaderSize = 32;
        /**/
        /* 版本标志
                 0x02    FoxBASE  
                0x03    FoxBASE+/dBASE III PLUS，无备注  
                0x30    Visual FoxPro  
                0x43    dBASE IV SQL 表文件，无备注  
                0x63    dBASE IV SQL 系统文件，无备注  
                0x83    FoxBASE+/dBASE III PLUS，有备注  
                0x8B    dBASE IV 有备注  
                0xCB    dBASE IV SQL 表文件，有备注  
                0xF5    FoxPro 2.x（或更早版本）有备注  
                0xFB    FoxBASE  
    */
        public sbyte Version;
        /**/
        /* 最后更新年 */
        public byte LastModifyYear;
        /**/
        /* 最后更新月 */
        public byte LastModifyMonth;
        /**/
        /* 最后更新日 */
        public byte LastModifyDay;
        /**/
        /* 文件包含的总记录数 */
        public uint RecordCount;
        /**/
        /* 第一条记录的偏移值，这个值也可以表示文件头长度 */
        public ushort HeaderLength;
        /**/
        /* 记录长度，包括删除标志*/
        public ushort RecordLength;
        /**/
        /* 保留 */
        public byte[] Reserved = new byte[16];
        /**/
        /* 表的标志
                 0x01具有 .cdx 结构的文件
                0x02文件包含备注
                0x04文件是数据库（.dbc） 
                标志可OR 
    */
        public sbyte TableFlag;
        /**/
        /* 代码页标志 */
        public sbyte CodePageFlag;
        /**/
        /* 保留 */
        public byte[] Reserved2 = new byte[2];
    }
    internal class DBFField
    {
        public const int DBFFieldSize = 32;
        /**/
        /* 字段名称 */
        public byte[] Name = new byte[11];
        /**/
        /* 字段类型 C - 字符型  
                Y - 货币型  
                N - 数值型  
                F - 浮点型  
                D - 日期型  
                T - 日期时间型  
                B - 双精度型  
                I - 整型  
                L - 逻辑型 
                M - 备注型  
                G - 通用型  
                C - 字符型（二进制） 
                M - 备注型（二进制） 
                P - 图片型  
    */
        public sbyte Type;
        /**/
        /* 字段偏移量 */
        public uint Offset;
        /**/
        /* 字段长度 */
        public byte Length;
        /**/
        /* 浮点数小数部分长度 */
        public byte Precision;
        /**/
        /* 保留 */
        public byte[] Reserved = new byte[2];
        /**/
        /* dBASE IV work area id */
        public sbyte DbaseivID;
        /**/
        /* */
        public byte[] Reserved2 = new byte[10];
        /**/
        /* */
        public sbyte ProductionIndex;
    }
    /**/
    /// <summary>
    /// .dbf文件操作类
    /// </summary>
    public class DBFFile : IDisposable
    {
        private const string MSG_OPEN_FILE_FAIL = "不能打开文件{0}";

        private bool _isFileOpened;
        private byte[] _recordBuffer;
        private DBFField[] _dbfFields;
        private System.IO.FileStream _fileStream = null;
        private System.IO.BinaryReader _binaryReader = null;
        private string _fileName = string.Empty;
        private uint _fieldCount = 0;
        private int _recordIndex = -1;
        private uint _recordCount = 0;
        private DBFHeader _dbfHeader = null;
        private string _tableName = string.Empty;

        /**/
        /// <summary>
        /// 构造函数
        /// </summary>
        public DBFFile()
        {
        }

        /**/
        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="fileName"></param>
        public DBFFile(string fileName)
        {
            if (null != fileName && 0 != fileName.Length)
                this._fileName = fileName;
        }

        /**/
        /// <summary>
        /// 清理所有正在使用的资源。
        /// </summary>
        protected virtual void Dispose(bool disposing)
        {
            if (disposing)
            {
                this._recordBuffer = null;
                this._dbfHeader = null;
                this._dbfFields = null;

                if (this.IsFileOpened && null != this._fileStream)
                {
                    this._fileStream.Close();
                    this._binaryReader.Close();
                }
                this._fileStream = null;
                this._binaryReader = null;

                this._isFileOpened = false;
                this._fieldCount = 0;
                this._recordCount = 0;
                this._recordIndex = -1;
            }
        }

        /**/
        /// <summary>
        /// 打开dbf文件
        /// </summary>
        /// <returns></returns>
        public bool Open()
        {
            try
            {
                return this.Open(null);
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        /**/
        /// <summary>
        /// 打开dbf文件
        /// </summary>
        /// <param name="fileName"></param>
        /// <returns></returns>
        public bool Open(string fileName)
        {
            if (null != fileName)
                this._fileName = fileName;

            bool ret = false;

            try
            {
                if (!this.OpenFile())
                {
                    // 不能打开dbf文件，抛出不能打开文件异常
                    throw new Exception(string.Format(MSG_OPEN_FILE_FAIL, this._fileName));
                }

                // 读取文件头信息
                ret = this.ReadFileHeader();

                // 读取所有字段信息
                if (ret)
                    ret = this.ReadFields();

                // 分配记录缓冲区
                if (ret && null == this._recordBuffer)
                {
                    this._recordBuffer = new byte[this._dbfHeader.RecordLength];

                    if (null == this._recordBuffer)
                        ret = false;
                }

                // 如果打开文件或读取信息不成功，关闭dbf文件
                if (!ret)
                    this.Close();
            }
            catch (Exception e)
            {
                throw e;
            }

            // 设置当前记录索引为
            this._recordIndex = -1;

            // 返回打开文件并且读取信息的成功状态
            return ret;
        }
        /// <summary>
        /// 将字段类型转换为系统数据类型
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        private Type FieldTypeToColumnType(sbyte type)
        {
            switch (type)
            {
                // C - 字符型、字符型（二进制）
                case (sbyte)'C':
                    return typeof(System.String);

                // Y - 货币型
                case (sbyte)'Y':
                    return typeof(System.Decimal);    // 虽然dbf中'Y'长度为64位，但是Double的精度不够，所以指定Decimal

                // N - 数值型
                case (sbyte)'N':
                    return typeof(System.Decimal);    // dbf中'N'的精度可以达到19，所以用Decimal

                // F - 浮点型
                case (sbyte)'F':
                    return typeof(System.Decimal);    // dbf中'F'的精度可以达到19，所以用Decimal

                // D - 日期型
                case (sbyte)'D':
                    return typeof(System.DateTime);

                // T - 日期时间型
                case (sbyte)'T':
                    return typeof(System.DateTime);

                // B - 双精度型
                case (sbyte)'B':
                    return typeof(System.Double);

                // I - 整型
                case (sbyte)'I':
                    return typeof(System.Int32);

                // L - 逻辑型
                case (sbyte)'L':
                    return typeof(System.Boolean);

                // M - 备注型、备注型（二进制）
                case (sbyte)'M':
                    return typeof(System.String);

                // G - 通用型
                case (sbyte)'G':
                    return typeof(System.String);

                // P - 图片型
                case (sbyte)'P':
                    return typeof(System.String);

                // 缺省字符串型
                default:
                    return typeof(System.String);

            }
        }
        /**/
        /// <summary>
        /// 获取dbf表文件对应的DataSet
        /// </summary>
        /// <returns></returns>
        public System.Data.DataSet GetDataSet()
        {
            // 确保文件已经打开
            if (!this.IsFileOpened || (this.IsBOF && this.IsEOF))
                return null;

            // 构造表格
            System.Data.DataSet ds = new System.Data.DataSet();
            System.Data.DataTable dt = new System.Data.DataTable(this._tableName );

            try
            {
                // 添加表格列
                for (uint i = 0; i < this._fieldCount; i++)
                {
                    System.Data.DataColumn col = new System.Data.DataColumn();
                    string colText = string.Empty;

                    // 获取并设置列标题
                    if (this.GetFieldName(i, ref colText))
                    {
                        col.ColumnName = colText;
                        col.Caption = colText;
                    }

                    // 设置列类型
                    col.DataType = FieldTypeToColumnType(this._dbfFields[i].Type);
                   

                    // 添加列信息
                    dt.Columns.Add(col);
                }

                // 添加所有的记录信息
                this.MoveFirst();

                while (!this.IsEOF)
                {
                    // 创建新记录行
                    System.Data.DataRow row = dt.NewRow();

                    // 循环获取所有字段信息，添加到新的记录行内
                    for (uint i = 0; i < this._fieldCount; i++)
                    {
                        string temp = string.Empty;

                        // 获取字段值成功后才添加到记录行中
                        if (this.GetFieldValue(i, ref temp))
                        {
                            // 如果获取的字段值为空，设置DataTable里字段值为DBNull
                            //                            if (string.Empty != temp)
                            row[(int)i] = temp;
                            //                            else
                            //                                row[(int)i] = System.DBNull.Value;
                        }

                    }

                    // 添加记录行
                    dt.Rows.Add(row);

                    // 后移记录
                    this.MoveNext();
                }
            }
            catch (Exception e)
            {
                throw e;
            }

            ds.Tables.Add(dt);
            return ds;
        }

        /**/
        /// <summary>
        /// 获取相应索引序号处的字段名称
        /// </summary>
        /// <param name="fieldIndex"></param>
        /// <param name="fieldName"></param>
        /// <returns></returns>
        public bool GetFieldName(uint fieldIndex, ref string fieldName)
        {
            // 确保文件已经打开
            if (!this.IsFileOpened)
                return false;

            // 索引边界检查
            if (fieldIndex >= this._fieldCount)
            {
                fieldName = string.Empty;
                return false;
            }

            try
            {
                // 反解码
                fieldName = System.Text.Encoding.Default.GetString(this._dbfFields[fieldIndex].Name);
                //去掉末尾的空字符标志
                int i = fieldName.IndexOf('\0');
                if (i > 0)
                {
                    fieldName = fieldName.Substring(0, i);
                }
                return true;
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        /**/
        /// <summary>
        /// 获取相应索引序号处的字段文本值
        /// </summary>
        /// <param name="fieldIndex"></param>
        /// <param name="fieldValue"></param>
        /// <returns></returns>
        public bool GetFieldValue(uint fieldIndex, ref string fieldValue)
        {
            // 安全性检查
            if (!this.IsFileOpened || this.IsBOF || this.IsEOF || null == this._recordBuffer)
                return false;

            // 字段索引超过最大值
            if (fieldIndex >= this._fieldCount)
            {
                fieldValue = string.Empty;
                return false;
            }

            try
            {
                // 从记录缓冲区中获取对应字段的byte[]

                //uint offset = this._dbfFields[fieldIndex].Offset;
                uint offset = 0;
                if (offset == 0)
                {
                    for (int i = 0; i < fieldIndex; i++)
                    {
                        offset += this._dbfFields[i].Length;
                    }
                }
                byte[] tmp = GetSubBytes(this._recordBuffer, offset, this._dbfFields[fieldIndex].Length);


                //
                // 开始byte数组的反解码过程
                //
                if (((sbyte)'I') == this._dbfFields[fieldIndex].Type)
                {
                    // 整形字段的反解码过程
                    int num1 = Byte2Int32(tmp);
                    fieldValue = num1.ToString();
                }
                else if (((sbyte)'B') == this._dbfFields[fieldIndex].Type)
                {
                    // 双精度型字段的反解码过程
                    double num1 = Byte2Double(tmp);
                    fieldValue = num1.ToString();
                }
                else if (((sbyte)'Y') == this._dbfFields[fieldIndex].Type)
                {
                    //
                    // 货币型字段的反解码过程
                    // 货币型存储的时候应该是将字段值放大10000倍，变成long型存储
                    // 所以先将byte数组恢复成long类型数值，然后缩小10000倍。
                    //
                    long num1 = Byte2Int64(tmp);
                    fieldValue = (((decimal)num1) / 10000).ToString();
                }
                else if (((sbyte)'D') == this._dbfFields[fieldIndex].Type)
                {
                    //
                    // 日期型字段的反解码过程
                    //
                    DateTime date1 = Byte2Date(tmp);

                        fieldValue = date1.ToString();

                }
                else if (((sbyte)'T') == this._dbfFields[fieldIndex].Type)
                {
                    //
                    // 日期时间型字段的反解码过程
                    //
                    DateTime date1 = Byte2DateTime(tmp);

                        fieldValue = date1.ToString();

                }
                else
                {
                    // 其他字段值与字符存储方式类似，直接反解码成字符串就可以
                    fieldValue = System.Text.Encoding.Default.GetString(tmp);
                }

                // 消除字段数值的首尾空格
                fieldValue = fieldValue.Trim();

                // 如果本子段类型是数值相关型，进一步处理字段值
                if (((sbyte)'N') == this._dbfFields[fieldIndex].Type ||    // N - 数值型
                    ((sbyte)'F') == this._dbfFields[fieldIndex].Type)    // F - 浮点型
                {
                    if (0 == fieldValue.Length)
                        // 字段值为空，设置为0
                        fieldValue = "0";
                    else if ("." == fieldValue)
                        // 字段值为"."，也设置为0
                        fieldValue = "0";
                    else
                    {
                        // 将字段值先转化为Decimal类型然后再转化为字符串型，消除类似“.000”的内容
                        // 如果不能转化则为0
                        try
                        {
                            fieldValue = System.Convert.ToDecimal(fieldValue).ToString();
                        }
                        catch (Exception)
                        {
                            fieldValue = "0";
                        }
                    }
                }
                // 逻辑型字段
                else if (((sbyte)'L') == this._dbfFields[fieldIndex].Type)    // L - 逻辑型
                {
                    if ("T" != fieldValue)
                        fieldValue = "false";
                    else
                        fieldValue = "true";
                }
                // 日期型字段
                else if (((sbyte)'D') == this._dbfFields[fieldIndex].Type ||    // D - 日期型
                    ((sbyte)'T') == this._dbfFields[fieldIndex].Type)    // T - 日期时间型
                {
                    // 暂时不做任何处理
                }

                return true;
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        /**/
        /// <summary>
        /// 获取buf的子数组
        /// </summary>
        /// <param name="buf"></param>
        /// <param name="startIndex"></param>
        /// <param name="length"></param>
        /// <returns></returns>
        private static byte[] GetSubBytes(byte[] buf, uint startIndex, long length)
        {
            // 参数检查
            if (null == buf)
            {
                throw new ArgumentNullException("buf");
            }
            if (startIndex >= buf.Length)
            {
                throw new ArgumentOutOfRangeException("startIndex");
            }
            if (0 == length)
            {
                throw new ArgumentOutOfRangeException("length", "参数length必须大于0");
            }
            if (length > buf.Length - startIndex)
            {
                // 子数组的长度超过从startIndex起到buf末尾的长度时，修正为剩余长度
                length = buf.Length - startIndex;
            }

            byte[] target = new byte[length];

            // 逐位复制
            for (uint i = 0; i < length; i++)
            {
                target[i] = buf[startIndex + i];
            }

            // 返回buf的子数组
            return target;
        }

        /**/
        /// <summary>
        /// byte数组存储的数值转换为int32类型
        /// </summary>
        /// <param name="buf"></param>
        /// <returns></returns>
        private static int Byte2Int32(byte[] buf)
        {
            // 参数检查
            if (null == buf)
            {
                // 参数为空
                throw new ArgumentNullException("buf");
            }
            if (4 != buf.Length)
            {
                // 如果参数buf的长度不为4，抛出参数异常
                throw new ArgumentException("函数Byte2Int32(byte[])的参数必须是长度为4的有效byte数组", "buf");
            }

            // byte[] 解码成 int
            return (int)((((buf[0] & 0xff) | (buf[1] << 8)) | (buf[2] << 0x10)) | (buf[3] << 0x18));
        }

        /**/
        /// <summary>
        /// byte数组存储的数值转换为int64类型
        /// </summary>
        /// <param name="buf"></param>
        /// <returns></returns>
        private static long Byte2Int64(byte[] buf)
        {
            // 参数检查
            if (null == buf)
            {
                // 参数为空
                throw new ArgumentNullException("buf");
            }
            if (8 != buf.Length)
            {
                // 如果参数buf的长度不为4，抛出参数异常
                throw new ArgumentException("函数Byte2Int64(byte[])的参数必须是长度为8的有效byte数组", "buf");
            }

            // byte[] 解码成 long
            uint num1 = (uint)(((buf[0] | (buf[1] << 8)) | (buf[2] << 0x10)) | (buf[3] << 0x18));
            uint num2 = (uint)(((buf[4] | (buf[5] << 8)) | (buf[6] << 0x10)) | (buf[7] << 0x18));

            return (long)(((ulong)num2 << 0x20) | num1);
        }

        /**/
        /// <summary>
        /// byte数组存储的数值转换为double类型
        /// </summary>
        /// <param name="buf"></param>
        /// <returns></returns>
        private static double Byte2Double(byte[] buf)
        {
            // 参数检查
            if (null == buf)
            {
                // 参数为空
                throw new ArgumentNullException("buf");
            }
            if (8 != buf.Length)
            {
                // 如果参数buf的长度不为8，抛出参数异常
                throw new ArgumentException("函数Byte2Double(byte[])的参数必须是长度为8的有效byte数组", "buf");
            }

            double num1 =0;
            unsafe
            {    // 在unsafe环境下使用指针
                fixed (byte* numRef1 = buf)
                {
                    num1 = *((double*)numRef1);
                }
            }

            return num1;
        }

        /**/
        /// <summary>
        /// byte数组存储的数值转换为只包含日期的DateTime类型
        /// </summary>
        /// <param name="buf"></param>
        /// <returns></returns>
        private static DateTime Byte2Date(byte[] buf)
        {
            // 参数检查
            if (null == buf)
            {
                // 参数为空
                throw new ArgumentNullException("buf");
            }
            if (8 != buf.Length)
            {
                // 如果参数buf的长度不为8，抛出参数异常
                throw new ArgumentException("函数Byte2DateTime(byte[])的参数必须是长度为8的有效byte数组", "buf");
            }

            try
            {
                string str1 = System.Text.Encoding.Default.GetString(buf);
                str1 = str1.Trim();
                if (str1.Length < 8)
                {
                    return new DateTime();
                } 
                int year = int.Parse(str1.Substring(0, 4));
                int month = int.Parse(str1.Substring(4, 2));
                int day = int.Parse(str1.Substring(6, 2));
                return new DateTime(year, month, day);
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        /**/
        /// <summary>
        /// byte数组存储的数值转换为DateTime类型
        /// byte数组为8位，前32位存储日期的相对天数，后32位存储时间的总毫秒数
        /// </summary>
        /// <param name="buf"></param>
        /// <returns></returns>
        private static DateTime Byte2DateTime(byte[] buf)
        {
            // 参数检查
            if (null == buf)
            {
                // 参数为空
                throw new ArgumentNullException("buf");
            }
            if (8 != buf.Length)
            {
                // 如果参数buf的长度不为8，抛出参数异常
                throw new ArgumentException("函数Byte2DateTime(byte[])的参数必须是长度为8的有效byte数组", "buf");
            }

            try
            {
                byte[] tmp = GetSubBytes(buf, 0, 4);
                tmp.Initialize();
                // 获取天数
                int days = Byte2Int32(tmp);

                // 获取毫秒数
                tmp = GetSubBytes(buf, 4, 4);
                int milliSeconds = Byte2Int32(tmp);

                // 在最小日期时间的基础上添加刚获取的天数和毫秒数，得到日期字段数值
                DateTime dm1 = DateTime.MinValue;
                dm1 = dm1.AddDays(days - 1721426);
                dm1 = dm1.AddMilliseconds((double)milliSeconds);

                return dm1;
            }
            catch
            {
                 return new DateTime() ;
            }
        }

        /**/
        /// <summary>
        /// 获取对应字段的文本值
        /// </summary>
        /// <param name="fieldName"></param>
        /// <param name="fieldValue"></param>
        /// <returns></returns>
        public bool GetFieldValue(string fieldName, string   fieldValue)
        {
            // 确认目标文件已经打开
            if (!this.IsFileOpened)
                return false;

            if (this.IsBOF || this.IsEOF)
                return false;

            if (null == this._recordBuffer || null == fieldName || 0 == fieldName.Length)
                return false;

            // 获取字段名称的索引
            int fieldIndex = GetFieldIndex(fieldName);

            if (-1 == fieldIndex)
            {
                fieldValue = string.Empty;
                return false;
            }

            try
            {
                // 返回根据字段索引获取的字段文本值
                return GetFieldValue((uint)fieldIndex, ref fieldValue);
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        /**/
        /// <summary>
        /// 获取当前纪录的文本值
        /// </summary>
        /// <param name="record"></param>
        /// <returns></returns>
        public bool GetRecordValue(ref string record)
        {
            // 安全性检查
            if (!this.IsFileOpened || this.IsBOF || this.IsEOF || null == this._recordBuffer)
                return false;

            try
            {
                // 反解码
                record = System.Text.Encoding.Default.GetString(this._recordBuffer);

                return true;
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        /**/
        /// <summary>
        /// 将纪录指针移动到第一条记录
        /// </summary>
        public void MoveFirst()
        {
            // 确认目标文件已经打开
            if (!this.IsFileOpened)
                return;

            if (this.IsBOF && this.IsEOF)
                return;

            // 重新设置当前记录的索引
            this._recordIndex = 0;

            try
            {
                // 读取当前记录信息
                ReadCurrentRecord();
            }
            catch (Exception e)
            {
                throw e;
            }

            return;
        }

        /**/
        /// <summary>
        /// 将记录指针前移一个记录
        /// </summary>
        public void MovePrevious()
        {
            // 确认目标文件已经打开
            if (!this.IsFileOpened)
                return;

            if (this.IsBOF)
                return;

            // 重新设置当前记录的索引
            this._recordIndex -= 1;

            try
            {
                // 读取当前记录信息
                ReadCurrentRecord();
            }
            catch (Exception e)
            {
                throw e;
            }

            return;
        }

        /**/
        /// <summary>
        /// 将记录指针后移一个记录
        /// </summary>
        public void MoveNext()
        {
            // 确认目标文件已经打开
            if (!this.IsFileOpened)
                return;

            if (this.IsEOF)
                return;

            // 重新设置当前记录的索引
            this._recordIndex += 1;

            try
            {
                // 读取当前记录信息
                ReadCurrentRecord();
            }
            catch (Exception e)
            {
                throw e;
            }

            return;
        }

        /**/
        /// <summary>
        /// 将记录指针移动到最后一条记录
        /// </summary>
        public void MoveLast()
        {
            // 确认目标文件已经打开
            if (!this.IsFileOpened)
                return;

            if (this.IsBOF && this.IsEOF)
                return;

            // 重新设置当前记录的索引
            this._recordIndex = (int)this._recordCount - 1;

            try
            {
                // 读取当前记录信息
                ReadCurrentRecord();
            }
            catch (Exception e)
            {
                throw e;
            }

            return;
        }

        /**/
        /// <summary>
        /// 关闭dbf文件
        /// </summary>
        public void Close()
        {
            this.Dispose(true);
        }

        /**/
        /// <summary>
        /// 根据字段名称获取字段的索引值
        /// </summary>
        /// <param name="fieldName"></param>
        /// <returns></returns>
        private int GetFieldIndex(string fieldName)
        {
            // 确认文件已经打开
            if (!this.IsFileOpened)
                return -1;

            // 字段名称有效性检查
            if (null == fieldName || 0 == fieldName.Length)
                return -1;

            int index = -1;
            string dest;

            fieldName = fieldName.Trim();

            // 查找所有字段名称信息，查找与fieldName匹配的项目
            for (uint i = 0; i < this._fieldCount; i++)
            {
                dest = System.Text.Encoding.Default.GetString(this._dbfFields[i].Name);
                dest = dest.Trim();

                // 检查当前字段名称与指定的字段名称是否匹配
                if (fieldName.Equals(dest))
                {
                    index = (int)i;
                    break;
                }
            }

            return index;
        }

        /**/
        /// <summary>
        /// 打开dbf文件
        /// </summary>
        /// <returns></returns>
        private bool OpenFile()
        {
            // 如果文件已经打开，则先关闭然后重新打开
            if (this.IsFileOpened)
            {
                this.Close();
            }

            // 校验文件名
            if (null == this._fileName || 0 == this._fileName.Length)
            {
                return false;
            }

            this._isFileOpened = false;

            try
            {
                // 打开dbf文件，获取文件流对象
                this._fileStream = File.Open(this._fileName, FileMode.Open, FileAccess.Read, FileShare.Read);
                // 使用获取的文件流对象构造二进制读取器对象
                this._binaryReader = new BinaryReader(this._fileStream, System.Text.Encoding.Default);

                this._isFileOpened = true;
                this._tableName = System.IO.Path.GetFileNameWithoutExtension(this._fileName);
            }
            catch (Exception e)
            {
                throw e;
            }

            return this._isFileOpened;
        }

        /**/
        /// <summary>
        /// 读取当前记录信息
        /// </summary>
        private void ReadCurrentRecord()
        {
            // 确认目标文件已经打开
            if (!this.IsFileOpened)
            {
                return;
            }

            if (this.IsBOF && this.IsEOF)
            {
                return;
            }

            try
            {
                this._fileStream.Seek(this._dbfHeader.HeaderLength + this._dbfHeader.RecordLength * this._recordIndex+1, SeekOrigin.Begin);
                this._recordBuffer = this._binaryReader.ReadBytes(this._dbfHeader.RecordLength);
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        /**/
        /// <summary>
        /// 从dbf文件中读取所有字段信息
        /// </summary>
        /// <returns></returns>
        private bool ReadFields()
        {
            // 确认目标文件已经打开
            if (!this.IsFileOpened)
                return false;

            // 必须存在文件头对象信息
            if (null == this._dbfHeader)
                return false;

            // 尝试构造字段信息对象数组
            if (null == this._dbfFields)
                this._dbfFields = new DBFField[this._fieldCount];

            try
            {
                // 定位字段信息结构区起点
                this._fileStream.Seek(DBFHeader.DBFHeaderSize, SeekOrigin.Begin);

                // 读取所有字段信息
                for (int i = 0; i < this._fieldCount; i++)
                {
                    this._dbfFields[i] = new DBFField();
                    this._dbfFields[i].Name = this._binaryReader.ReadBytes(11);
                    this._dbfFields[i].Type = this._binaryReader.ReadSByte();
                    this._dbfFields[i].Offset = this._binaryReader.ReadUInt32();
                    this._dbfFields[i].Length = this._binaryReader.ReadByte();
                    this._dbfFields[i].Precision = this._binaryReader.ReadByte();
                    this._dbfFields[i].Reserved = this._binaryReader.ReadBytes(2);
                    this._dbfFields[i].DbaseivID = this._binaryReader.ReadSByte();
                    this._dbfFields[i].Reserved2 = this._binaryReader.ReadBytes(10);
                    this._dbfFields[i].ProductionIndex = this._binaryReader.ReadSByte();
                }
            }
            catch (Exception e)
            {
                throw e;
            }

            return true;
        }

        /**/
        /// <summary>
        /// 从dbf文件中读取文件头信息
        /// </summary>
        /// <returns></returns>
        private bool ReadFileHeader()
        {
            // 确认目标文件已经打开
            if (!this.IsFileOpened)
                return false;

            // 尝试构造新的dbf文件头对象
            if (null == this._dbfHeader)
                this._dbfHeader = new DBFHeader();

            try
            {
                this._dbfHeader.Version = this._binaryReader.ReadSByte();//第1字节
                this._dbfHeader.LastModifyYear = this._binaryReader.ReadByte();//第2字节
                this._dbfHeader.LastModifyMonth = this._binaryReader.ReadByte();//第3字节
                this._dbfHeader.LastModifyDay = this._binaryReader.ReadByte();//第4字节
                this._dbfHeader.RecordCount = this._binaryReader.ReadUInt32();//第5-8字节
                this._dbfHeader.HeaderLength = this._binaryReader.ReadUInt16();//第9-10字节
                this._dbfHeader.RecordLength = this._binaryReader.ReadUInt16();//第11-12字节
                this._dbfHeader.Reserved = this._binaryReader.ReadBytes(16);//第13-14字节
                this._dbfHeader.TableFlag = this._binaryReader.ReadSByte();//第15字节
                this._dbfHeader.CodePageFlag = this._binaryReader.ReadSByte();//第16字节
                this._dbfHeader.Reserved2 = this._binaryReader.ReadBytes(2);////第17-18字节
            }
            catch (Exception e)
            {
                throw e;
            }

            // 设置记录数目
            this._recordCount = this._dbfHeader.RecordCount;
            uint fieldCount = (uint)((this._dbfHeader.HeaderLength - DBFHeader.DBFHeaderSize - 1) / DBFField.DBFFieldSize);
            this._fieldCount = 0;

            // 由于有些dbf文件的文件头最后有附加区段，但是有些文件没有，在此使用笨方法计算字段数目
            // 就是测试每一个存储字段结构区域的第一个字节的值，如果不为0x0D，表示存在一个字段
            // 否则从此处开始不再存在字段信息
            try
            {
                for (uint i = 0; i < fieldCount; i++)
                {
                    // 定位到每个字段结构区，获取第一个字节的值
                    this._fileStream.Seek(DBFHeader.DBFHeaderSize + i * DBFField.DBFFieldSize, SeekOrigin.Begin);
                    byte flag = this._binaryReader.ReadByte();

                    // 如果获取到的标志不为0x0D，则表示该字段存在；否则从此处开始后面再没有字段信息
                    if (0x0D != flag)
                        this._fieldCount++;
                    else
                        break;
                }
            }
            catch (Exception e)
            {
                throw e;
            }

            return true;
        }


        #region properties
        /// <summary>
        /// 获取当前导入的数据文件在DataSet中的表名
        /// 也就是数据文件去掉扩展名后的文件名
        /// </summary>

        public string TableName
        {
            get
            {
                return this._tableName;
            }
        }
        /**/
        /// <summary>
        /// 获取当前记录是否被删除
        /// </summary>
        public bool IsRecordDeleted
        {
            get
            {
                if (!this.IsFileOpened)
                    return false;

                if (this.IsBOF || this.IsEOF)
                    return false;

                // 只有记录缓冲的第一个字节的值为删除标志（0x2A）才表示当前纪录被删除了
                if (0x2A == this._recordBuffer[0])
                    return true;
                else
                    return false;
            }
        }

        /**/
        /// <summary>
        /// 获取记录长度
        /// </summary>
        public uint RecordLength
        {
            get
            {
                if (!this.IsFileOpened)
                    return 0;

                return this._dbfHeader.RecordLength;
            }
        }

        /**/
        /// <summary>
        /// 获取字段数目
        /// </summary>
        public uint FieldCount
        {
            get
            {
                if (!this.IsFileOpened)
                    return 0;

                return this._fieldCount;
            }
        }

        /**/
        /// <summary>
        /// 获取记录数目
        /// </summary>
        public uint RecordCount
        {
            get
            {
                if (!this.IsFileOpened)
                    return 0;

                return this._recordCount;
            }
        }

        /**/
        /// <summary>
        /// 获取是否记录指针已经移动到记录最前面
        /// </summary>
        public bool IsBOF
        {
            get
            {
                return (-1 == this._recordIndex);
            }
        }

        /**/
        /// <summary>
        /// 获取是否记录指针已经移动到记录最后面
        /// </summary>
        public bool IsEOF
        {
            get
            {
                return ((uint)this._recordIndex == this._recordCount);
            }
        }

        /**/
        /// <summary>
        /// 获取dbf文件是否已经被打开
        /// </summary>
        private bool IsFileOpened
        {
            get
            {
                return this._isFileOpened;
            }
        }

        #endregion
        #region IDisposable 成员

        void System.IDisposable.Dispose()
        {
            // TODO:  添加 DBFFile.System.IDisposable.Dispose 实现
            this.Dispose(true);
        }

        #endregion
    }

}

