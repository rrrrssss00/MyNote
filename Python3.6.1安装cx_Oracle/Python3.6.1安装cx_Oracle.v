本人电脑的安装环境
Windows7 - 64位版
Oracle11g - 32位版客户端
Python3.6.1 - 64位版
配置64位Oracle11g即时客户端
打开网址：http://www.oracle.com/technetwork/topics/winx64soft-089540.html
下载instantclient-basic-windows.x64-11.2.0.4.0.zip
解压文件至C:\instantclient_11_2（此instantclient_11_2文件可根据个人喜好随意放置）
安装cx_Oracle
下载cx_Oracle-6.0rc1-cp36-cp36m-win_amd64.whl(网址：https://pypi.python.org/pypi/cx_Oracle/6.0rc1)
进入CMD窗口，并CD到cx_Oracle文件所在目录
输入pip命令进行安装：
pip install cx_Oracle-6.0rc1-cp36-cp36m-win_amd64.whl
测试cx_Oracle
import os
os.environ['NLS_LANG'] = 'SIMPLIFIED CHINESE_CHINA.UTF8'
os.environ['path'] = 'C:/instantclient_11_2/'
import cx_Oracle
注意：1、Oracle数据库服务器端和Python编码方式不一致时会导致读取的中文文本乱码，可以通过设置NLS_LANG环境变量解决这一问题。
2、cx_Oracle模块会读取系统的path环境变量，寻找所需Oracle客户端文件，将path指向新下载的64位即时客户端，这样就可以解决系统中已有的Oracle11g - 32位版客户端与64位Python不兼容的冲突问题。

