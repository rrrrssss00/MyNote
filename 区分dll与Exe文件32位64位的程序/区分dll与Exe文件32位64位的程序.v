区分dll文件32位64位的程序让我倍感迷惑
上面说到的数据库无法启动的这种情况，已经遇到了不止一次了。每次遇到这种问 题，我都想能不能有个工具可以检查System32和SysWow64文件夹中的dll程序是不是对应的64位和32位程序。据我所知只有dumpbin 可以查看一个dll文件是32位还是64位，但它明显不是我想要的工具，因为每次只能查看一个文件。
好吧，自己动手，丰衣足食，既然没有这种工具，那就来写一个吧，好在判断dll文件是32位还是64位也不是很难。
Windows系统下，exe、dll文件都可以称为PE文件，他们有相同的文件格式，称为PE文件格式。
PE文件的第一个部分是IMAGE_DOS_HEADER，大小为64B，对于检查32位64位来说，有一个重要的成员e_lfanew，这个成员的值为IMAGE_NT_HEADERS的偏移。
IMAGE_DOS_HEADER的定义如下：
typedef struct _IMAGE_DOS_HEADER
{//（注：最左边是文件头的偏移量。）
+0h  WORD e_magic         //Magic DOS signature MZ(4Dh 5Ah)         DOS可执行文件标记
+2h  WORD e_cblp          //Bytes on last page of file  
+4h  WORD e_cp            //Pages in file
+6h  WORD e_crlc          //Relocations
+8h  WORD e_cparhdr       //Size of header in paragraphs
+0ah WORD e_minalloc      //Minimun extra paragraphs needs
+0ch WORD e_maxalloc      //Maximun extra paragraphs needs
+0eh WORD e_ss            //intial(relative)SS value                DOS代码的初始化堆栈SS
+10h WORD e_sp            //intial SP value                         DOS代码的初始化堆栈指针SP
+12h WORD e_csum          //Checksum
+14h WORD e_ip            //intial IP value                         DOS代码的初始化指令入口[指针IP]
+16h WORD e_cs            //intial(relative)CS value                DOS代码的初始堆栈入口
+18h WORD e_lfarlc        //File Address of relocation table
+1ah WORD e_ovno          //Overlay number
+1ch WORD e_res[4]        //Reserved words
+24h WORD e_oemid         //OEM identifier(for e_oeminfo)
+26h WORD e_oeminfo       //OEM information;e_oemid specific 
+29h WORD e_res2[10]      //Reserved words
+3ch DWORD e_lfanew       //Offset to start of PE header            指向PE文件头
} IMAGE_DOS_HEADER;
IMAGE_NT_HEADERS的定义如下：
typedef struct _IMAGE_NT_HEADERS 
{ 
+0h  DWORD                     Signature;
+4h  IMAGE_FILE_HEADER         FileHeader;
+18h IMAGE_OPTIONAL_HEADER32   OptionalHeader;
} IMAGE_NT_HEADERS;
Signature 字段：在一个有效的 PE 文件里，Signature 字段被设置为00004550h，ASCII 码字符是“PE00”。标志这 PE 文件头的开始。“PE00” 字符串是 PE 文件头的开始，DOS 头部的 e_lfanew 字段正是指向这里。
IMAGE_FILE_HEADER 结构定义：
typedef struct _IMAGE_FILE_HEADER 
{
+04h  WORD  Machine;                        // 运行平台
+06h  WORD  NumberOfSections;               // 文件的区块数目
+08h  DWORD TimeDateStamp;                  // 文件创建日期和时间
+0Ch  DWORD PointerToSymbolTable;           // 指向符号表(主要用于调试)
+10h  DWORD NumberOfSymbols;                // 符号表中符号个数(同上)
+14h  WORD  SizeOfOptionalHeader;           // IMAGE_OPTIONAL_HEADER32 结构大小
+16h  WORD  Characteristics;                // 文件属性
} IMAGE_FILE_HEADER;
其中Machine字段表示可执行文件的目标CPU类型：
IMAGE_FILE_MACHINE_I386         0x014c   x86
IMAGE_FILE_MACHINE_IA64         0x0200   Intel Itanium
IMAGE_FILE_MACHINE_AMD64        0x8664  x64
这样不是很直观，上张图来看一下：

有了这些，我们就可以通过程序来判断32位、64位了，代码如下：
public static bool IsPE32(string path)
{
    FileStream file = File.OpenRead(path);
    //移动到e_lfanew的位置处
    stream.Seek(0x40 - 4, SeekOrigin.Begin);
    byte[] buf = new byte[4];
    stream.Read(buf, 0, buf.Length);
    //根据e_lfanew的值计算出Machine的位置
    int pos = BitConverter.ToInt32(buf,0) + 4;
    stream.Seek(pos, SeekOrigin.Begin);
    buf = new byte[2];
    stream.Read(buf, 0, buf.Length);
    //得到Machine的值，0x14C为32位，0x8664为64位
    Int16 machine = BitConverter.ToInt16(buf, 0);
    if (machine == 0x14C)
    {
        return true;
    }
    else
    {
        return false;
    }
}
最核心的功能完成了，剩下的就是界面和遍历文件夹了，效果图：


来源： <http://www.cnblogs.com/hbccdf/p/dllchecktoolandsyswow64.html>
 
