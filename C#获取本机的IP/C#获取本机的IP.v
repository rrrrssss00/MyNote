常用 的方法:
1:
IPAddress[] ips = Dns.GetHostAddresses(Dns.GetHostName());
2.
NetworkInterface[] interfaces = NetworkInterface.GetAllNetworkInterfaces();
foreach (NetworkInterface ni in interfaces)
{
if (ni.NetworkInterfaceType == NetworkInterfaceType.Ethernet || ni.NetworkInterfaceType == NetworkInterfaceType.Wireless80211)
{
foreach (UnicastIPAddressInformation ip in ni.GetIPProperties().UnicastAddresses)
{
if (ip.Address.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork)
{
return ip.Address.ToString();
}
}
}
}
这两种方法都是读取本机所有可用的网卡对应的IP,返回结果可能有多个,不能找到当前激活的网卡
 
下面两种方法都可以找到实际激活的IP:
1:
string result = RunApp("route", "print", true);
Match m = Regex.Match(result, @"0.0.0.0\s+0.0.0.0\s+(\d+.\d+.\d+.\d+)\s+(\d+.\d+.\d+.\d+)");
if (m.Success)
{
return m.Groups[2].Value;
}
else return "";
 
public static string RunApp(string filename, string arguments, bool recordLog)
{
try
{
if (recordLog)
{
Trace.WriteLine(filename + " " + arguments);
}
Process proc = new Process();
proc.StartInfo.FileName = filename;
proc.StartInfo.CreateNoWindow = true;
proc.StartInfo.Arguments = arguments;
proc.StartInfo.RedirectStandardOutput = true;
proc.StartInfo.UseShellExecute = false;
proc.Start();
using (System.IO.StreamReader sr = new System.IO.StreamReader(proc.StandardOutput.BaseStream, Encoding.Default))
{
string txt = sr.ReadToEnd();
sr.Close();
if (recordLog)
{
Trace.WriteLine(txt);
}
if (!proc.HasExited)
{
proc.Kill();
}
return txt;
}
}
catch (Exception ex)
{
Trace.WriteLine(ex);
return ex.Message;
}
}
 
2.
try
{
System.Net.Sockets.TcpClient c = new System.Net.Sockets.TcpClient();
c.Connect("www.baidu.com", 80);
string ip = ((System.Net.IPEndPoint)c.Client.LocalEndPoint).Address.ToString();
c.Close();
return ip;
}
catch (Exception)
{
return "";
}
