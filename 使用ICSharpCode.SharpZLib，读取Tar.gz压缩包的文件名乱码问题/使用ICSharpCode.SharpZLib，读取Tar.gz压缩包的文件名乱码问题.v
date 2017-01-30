默认版本的库文件读取时会将tar包中的中文路径读成乱码，两种方案，
 
第一种方法，不改SharpZLib的源代码，将读出的Entry名称进行如下转换：
private string ParseName(string source)
{
byte[] sourceByte = new byte[source.Length];
for (int i = 0; i < source.Length; i++)
{
sourceByte[i] = (byte)source[i];
}
return Encoding.Default.GetString(sourceByte);
}
 
即可将其转化为正常，
注：SharpZLib中，是将byte[]数组中的每一个元素强制转化为char，然后再拼成string，所以会出现乱码，这里的处理是将其恢复原来的byte[]数组，再使用gb2312的编码解出来，得到中文
 
 
 
第二种方法，修改SharpZLib的源代码（有风险，未详细测试）
将TarHeader.cs中的ParseName函数改为下文所示，可解决这一问题：
 
static public String ParseName(byte[] header, int offset, int length)
        {
            if ( header == null ) {
                throw new ArgumentNullException("header");
            }
            if ( offset < 0 ) {
#if NETCF_1_0
                throw new ArgumentOutOfRangeException("offset");
#else
                throw new ArgumentOutOfRangeException("offset", "Cannot be less than zero");
#endif                
            }
            if ( length < 0 )
            {
#if NETCF_1_0
                throw new ArgumentOutOfRangeException("length");
#else
                throw new ArgumentOutOfRangeException("length", "Cannot be less than zero");
#endif                
            }
            if ( offset + length > header.Length )
            {
                throw new ArgumentException("Exceeds header size", "length");
            }
//StringBuilder result = new StringBuilder(length);
            
//for (int i = offset; i < offset + length; ++i) {
// if (header[i] == 0) {
// break;
// }
// result.Append((char)header[i]);
//}
            
//return result;
int tmpCount = 0;
for (int i = offset; i < offset + length; ++i)
{
if (header[i] == 0)
{
break;
}
else tmpCount++;
}
byte[] bytes = new byte[tmpCount];
for (int i = offset; i < offset+tmpCount; i++)
{
bytes[i] = header[i];
}
string res = System.Text.Encoding.Default.GetString(bytes);
return res;
        }
