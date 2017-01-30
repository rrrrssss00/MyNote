Shp文件属性表读取时，与中文相关的步骤大致有：
1：
首先，Dotspatial会读取属性表的表头，包含字段名称，类型等，这时如果字段名称有中文的话会出错，需要修改Data.AttributeTable.cs文件的ReadTableHeader()函数，将
// read the field name
char[] buffer = reader.ReadChars(11);
 
改成：
 
 int length = 11;
byte[] byteContent = reader.ReadBytes(11);
if (byteContent.Length < length)
{
    length = byteContent.Length;
}
char[] buffer = new char[length];
Encoding.Default.GetChars(byteContent, 0, length, buffer, 0);
 
2-1：
然后读取实际内容时，有两种情况，第一种情况就是全部读取，注意默认加载Shp文件时是不会全部读取属性表的，可以通过调用下面的语句来尝试全部加载
DataTable tab = ((Shapefile)featureset).Attributes.Table；
全部加载后，再读取其中某些要素的属性时，会自动去已加载的Table里找，不需要再读取了
 
这种情况下，需要修改的代码为（都在Data.AttributeTable.cs中）：
变量声明里：
   private char[] _characterContent;
改为：
    private byte[] _characterContent; 
 
GetRowOffsets()函数中:
    _characterContent = new char[length];
     Encoding.Default.GetChars(byteContent, 0, length, _characterContent, 0);
改为：
     _characterContent = byteContent; //读取中文问题 by wyz
 
ReadTableRowFromChars()函数中:
    // read the data.
    char[] cBuffer = new char[currentField.Length];
    Array.Copy(_characterContent, start, cBuffer, 0, currentField.Length);
    start += currentField.Length;
改为：
    byte[] bBuffer = new byte[currentField.Length];
    Array.Copy(_characterContent, start, bBuffer, 0, currentField.Length);
    start += currentField.Length;
 
    char[] cBuffer = new char[currentField.Length];
    cBuffer = Encoding.Default.GetChars(bBuffer);
 
2-2：
第二种情况，这个也是默认的情况，加载Shp文件时Dotspatial不会去全部读取属性表，只是在需要的时候（例如在程序中使用DataRow dr = featureset.GetFeature(0).DataRow;获取一条记录)，再去读取指定部分的属性表（某指定行或指定的若干行）
 
这种情况下，需要修改Data.AttributeTable.cs中ReadTableRow()函数：
start += currentField.Length;
改为：
//这里由于Char的长度和Byte的长度不一样，而字段长度是按Byte长度算的，
//如果按这个长度截Char数组，会产生问题（实际上就是start +=的数错了）by wyz
byte[] tmpBytes = Encoding.Default.GetBytes(cBuffer);
byte[] tmpBytes2 = new byte[currentField.Length];
Array.Copy(tmpBytes, tmpBytes2, currentField.Length);
char[] cBuffer2 = Encoding.Default.GetChars(tmpBytes2);
start += cBuffer2.Length;
 
3：
Shp文件中，如果向字段中写入中文，下一行中会出现错位等现象，该行的显示也有问题，需要修改Data.AttributeTable.cs文件中
Write(string text, int length)函数：
 
            text = text.PadRight(length, ' ');         
            string dbaseString = text.Substring(0, length);
            byte[] bytes = Encoding.Default.GetBytes(dbaseString.ToCharArray());
改为：
            byte[] tmpBytes = Encoding.Default.GetBytes(text.ToCharArray());        //原字符串序列化后的二进制流
            int tmpLength = length - tmpBytes.Length;           //原字符串要加多少个空格才能对应上字段宽度
            byte[] bytes = new byte[length];
            if (tmpLength < 0)                          //如果字符串序列化以后比字段宽度要长，那么截取一下
            {
                Array.Copy(tmpBytes, bytes, length);
            }
            else
            {
                string dbaseString = text.PadRight(text.Length + tmpLength, ' ');
                bytes = Encoding.Default.GetBytes(dbaseString.ToCharArray());
            }
 
4：
Shp文件中，如果属性表的字段名有中文，那么在向Shp中写数据或修改数据时，字段名会变成乱码，需要进行的修改为：
Data.AttributeTable.cs中，
public void WriteHeader(BinaryWriter writer)
函数里，将原有的
                for (int j = 0; j < 11; j++)
                {
                    if (currentField.ColumnName.Length > j)
                        writer.Write((byte)currentField.ColumnName[j]);
                    else writer.Write((byte)0);
                }
改为：
 
 byte[] tmpBytes =  Encoding.Default.GetBytes(currentField.ColumnName);
                writer.Write(tmpBytes);
                if (tmpBytes.Length < 11)
                    for (int i = 0; i < 11-tmpBytes.Length; i++)
                        writer.Write((byte)0);
