WIN7下使用.net(C#)监视剪贴板
最近需要做一个小程序,需要常驻后台,监视剪贴板变化并提取内容,
在网上查了一些资料,先采用SetClipboardViewer方法实现,具体原理可以参考http://www.cnblogs.com/jht/archive/2006/03/20/354088.html,我的程序中使用的是http://code.google.com/p/clipboardviewer/提供的ClipboardChangeNotifier.cs类,比较方便,类代码见附件,使用方法为:
主窗体初始化时:
    ClipboardChangeNotifier clipChange = new ClipboardChangeNotifier();
    clipChange.ClipboardChanged += new EventHandler(clipChange_ClipboardChanged);
    clipChange.AssignHandle(this.Handle);
    clipChange.Install();
主窗体退出时:
    clipChange.Uninstall();
 
此程序在XP下运行正常,但是后来在WIN7下使用时遇到了一些问题,经常会在屏幕保护程序或系统休眠后,不再实时监视剪贴板,具体原因不明,后来查了下资料,有人建议使用AddClipboardFormatListener这个API函数,MSDN(http://msdn.microsoft.com/en-us/library/windows/desktop/ms649033%28v=vs.85%29.aspx)上提到该API函数只能用于Vista及以上版本,经测试,程序工作正常
 
代码比SetClipboardViewer方法简单:
首先声明API函数
    [DllImport("user32.dll")]
        public static extern bool AddClipboardFormatListener(IntPtr hwnd);
 
        [DllImport("user32.dll")]
        public static extern bool RemoveClipboardFormatListener(IntPtr hwnd);
 
        private static int WM_CLIPBOARDUPDATE = 0x031D;
 
窗体初始化时添加对剪贴板的监视:
    AddClipboardFormatListener(this.Handle);
 
窗体关闭时移除对剪贴板的监视:
    RemoveClipboardFormatListener(this.Handle);
 
接收到剪贴板更新的消息时,读取剪贴板内容:
    protected override void DefWndProc(ref Message m)
        {
            if (m.Msg == WM_CLIPBOARDUPDATE)
            {
                UpdateClipValueList();
            }
            else
            {
                base.DefWndProc(ref m);
            }
        }
