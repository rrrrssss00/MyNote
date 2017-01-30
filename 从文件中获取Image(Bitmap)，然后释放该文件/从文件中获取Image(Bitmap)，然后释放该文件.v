public static Image ImageFromFileReleaseHandle(string filename)
{
FileStream fs = null;
try
{
fs = new FileStream(filename, FileMode.Open, FileAccess.Read);
return Image.FromStream(fs);
}
finally
{
fs.Close();
}
}
 
如果需要得到Bitmap：
 
public static Bitmap BitmapFromFileReleaseHandle(string filename)
{
FileStream fs = null;
try
{
fs = new FileStream(filename, FileMode.Open, FileAccess.Read);
return Image.FromStream(fs);
}
finally
{
fs.Close();
}
}
