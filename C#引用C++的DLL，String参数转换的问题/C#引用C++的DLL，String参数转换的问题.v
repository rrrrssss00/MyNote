在引用DLL中的函数时，可以在函数的参数前加上转换声明，如下例：
 [DllImport(("mpr.dll")]
        public static extern int WNetGetConnection([MarshalAs(UnmanagedType.LPTStr)] string localName,[MarshalAs(UnmanagedType.LPTStr)] string localName);
    
