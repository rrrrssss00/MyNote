文件系统中的文件只能覆盖文件中的内容，不能插入

覆盖方法如下：
            FileStream fs = new FileStream("aaaa.txt", FileMode.Open, FileAccess.ReadWrite);
            StreamWriter sw = new StreamWriter(fs, Encoding.Default);
            fs.Seek(0, SeekOrigin.Begin);
            sw.Write("1111");
            sw.Close();
            fs.Close();
