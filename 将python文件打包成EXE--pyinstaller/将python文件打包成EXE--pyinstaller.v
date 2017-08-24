版本：本文中使用的版本是python 3.6,pyinstaller 3.2.1

1.安装pyinstaller:在http://www.pyinstaller.org/downloads.html下载安装包，由于Python版本为3.6，目前只能下载ZIP格式的包，Beta版本
	下载完成之后，进行安装，安装过程中，可能会报缺少一些依赖组件，逐个去https://pypi.python.org/pypi下载安装即可
2.按教程所说，目前pyinstaller只支持32位python，这个有待确认
3.使用命令行编译EXE：pyinstaller -F -w (-i image.ico)youdaotranslate.py；-F表示打包成一个文件 -w不显示命令行 -i表示图标，图标格式是.ico（括号中可以不要）
4.完成编译后，即可拷贝至其它机器上运行，按本文使用的程序版本，只能用于win7SP1，Win2008SP1以上版本，以下版本会报“无法定位输入点ucrtbase.terminate于动态链接库api-ms-win-crt-runtime-|1-1-0.dll上”之类的错误，无法运行，如果是Win7SP1以上版本，可以安装VC2015 Redistributable试试
