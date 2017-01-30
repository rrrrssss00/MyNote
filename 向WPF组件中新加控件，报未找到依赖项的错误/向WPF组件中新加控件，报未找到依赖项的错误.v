在向WPF工具箱中添加DevExpress.Xpf.Charts.v11.1.dll对应控件时出现了该错误，
是因为这个DLL需要两个依赖DLL，需要将其注册以全局程序缓存（c:\Windows\assembly）中，在命令行中使用gacutil –I <assembly name>即可
 
很奇怪，如果是WinForm使用Dev控件的话，是不需要注册的，这里是否可以理解为这两个是不同的体系，无法直接
