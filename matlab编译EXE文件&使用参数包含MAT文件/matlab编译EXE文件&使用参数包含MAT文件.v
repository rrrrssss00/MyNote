两种方式，
第一种使用命令行方式
1.设置编译器类型
	mbuild -setup
2.编译
	mcc -m test.m

注：可以使用参数-a 来添加一些自动分析不出来的外部文件，例如.fig,.mat或使用feval调用的m文件等，例如 
	mcc -m test.m -a icon.mat

第二种使用Matlab自带的Package工具，在主窗体的APPS页面下，点击Package App，有图形化界面操作
