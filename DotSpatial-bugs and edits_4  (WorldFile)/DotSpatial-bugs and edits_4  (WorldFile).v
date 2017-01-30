1：63608版本Data.WorldFile中存在的问题
影像文件的WorldFile 中，六个值顺序与ArcGIS不太一致，进行了修改（主要在Open函数中）
原代码：
 public void Open()
        {
            if (File.Exists(_fileName))
            {
                StreamReader sr = new StreamReader(_fileName);
                _affine = new double[6];
                _affine[1] = NextValue(sr); // Dx                
                _affine[2] = NextValue(sr); // Skew X
                _affine[4] = NextValue(sr); // Skew Y
                _affine[5] = NextValue(sr); // Dy
                _affine[0] = NextValue(sr); // Top Left X
                _affine[3] = NextValue(sr); // Top Left Y
                sr.Close();
            }
        }

修改后：
 public void Open()
        {
            if (File.Exists(_fileName))
            {
                StreamReader sr = new StreamReader(_fileName);
                _affine = new double[6];
                _affine[1] = NextValue(sr); // Dx
                //wyz 20160123 :这里两个值的位置好像反了，结果与ArcGIS显示不一样
                //_affine[2] = NextValue(sr); // Skew X
                //_affine[4] = NextValue(sr); // Skew Y
                _affine[4] = NextValue(sr); // Skew X
                _affine[2] = NextValue(sr); // Skew Y
                _affine[5] = NextValue(sr); // Dy
                _affine[0] = NextValue(sr); // Top Left X
                _affine[3] = NextValue(sr); // Top Left Y
                sr.Close();
            }
        }

同理，在Save函数中也进行相应的调整
修改前：
 public void Save()
        {
            if (File.Exists(_fileName)) File.Delete(_fileName);
            StreamWriter sw = new StreamWriter(_fileName);
            sw.WriteLine(_affine[1].ToString(CultureInfo.InvariantCulture));  // Dx
            sw.WriteLine(_affine[2].ToString(CultureInfo.InvariantCulture));  // Skew X
            sw.WriteLine(_affine[4].ToString(CultureInfo.InvariantCulture));  // Skew Y
            sw.WriteLine(_affine[5].ToString(CultureInfo.InvariantCulture));  // Dy
            sw.WriteLine(_affine[0].ToString(CultureInfo.InvariantCulture));  // Top Left X
            sw.WriteLine(_affine[3].ToString(CultureInfo.InvariantCulture));  // Top Left Y
            sw.Close();
        }
修改后：
 public void Save()
        {
            if (File.Exists(_fileName)) File.Delete(_fileName);
            StreamWriter sw = new StreamWriter(_fileName);
            sw.WriteLine(_affine[1].ToString(CultureInfo.InvariantCulture));  // Dx
            //wyz160123:顺序问题，与ArcGIS不一致
            //sw.WriteLine(_affine[2].ToString(CultureInfo.InvariantCulture));  // Skew X
            //sw.WriteLine(_affine[4].ToString(CultureInfo.InvariantCulture));  // Skew Y
            sw.WriteLine(_affine[4].ToString(CultureInfo.InvariantCulture));  // Skew Y
            sw.WriteLine(_affine[2].ToString(CultureInfo.InvariantCulture));  // Skew X
            sw.WriteLine(_affine[5].ToString(CultureInfo.InvariantCulture));  // Dy
            sw.WriteLine(_affine[0].ToString(CultureInfo.InvariantCulture));  // Top Left X
            sw.WriteLine(_affine[3].ToString(CultureInfo.InvariantCulture));  // Top Left Y
            sw.Close();
        }


