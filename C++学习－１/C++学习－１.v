1. 对于所有本地Ｃ＋＋的程序，都需要设置CharacterSet，设成Not Set,关闭使用Unicode库（待验证）

2. 如果出现“LINK : fatal error LNK1123：转换到 COFF 期间失败: 文件无效或损坏”错误时，修改方式为（VS2010）：
	1）修改项目的属性，在“配置属性-清单工具-输入和输出-嵌入清单”修改为否
	2）（改了这个上面那个可以不用改）系统最近多次更新，出现了两个版本的cvtres.exe。而系统变量里将这俩都引用了，编译的时候，不知道用哪个了，导致出错；一般出现在C:\Windows\Microsoft.NET\Framework\v4.0.30319\cvtres.exe，另一个在你安装VS的软件目录..\Microsoft Visual Studio 10.0\vc\bin\cvtres.exe，删掉一个版本更老的就行了
