C#异步编程
 

同步方法和异步方法的区别

同步方法调用在程序继续执行之前需要等待同步方法执行完毕返回结果
异步方法则在被调用之后立即返回以便程序在被调用方法完成其任务的同时执行其它操作
异步编程概览

.NET Framework 允许您异步调用任何方法。定义与您需要调用的方法具有相同签名的委托；公共语言运行库将自动为该委托定义具有适当签名
的 BeginInvoke 和 EndInvoke 方法。
BeginInvoke 方法用于启动异步调用。它与您需要异步执行的方法具有相同的参数，只不过还有两个额外的参数（将在稍后描述）。
BeginInvoke 立即返回，不等待异步调用完成。
BeginInvoke 返回 IasyncResult，可用于监视调用进度。
EndInvoke 方法用于检索异步调用结果。调用 BeginInvoke 后可随时调用 EndInvoke 方法；如果异步调用未完成，EndInvoke 将一直阻塞到
异步调用完成。EndInvoke 的参数包括您需要异步执行的方法的 out 和 ref 参数（在 Visual Basic 中为 <Out> ByRef 和 ByRef）以及由
BeginInvoke 返回的 IAsyncResult。
四种使用 BeginInvoke 和 EndInvoke 进行异步调用的常用方法。调用了 BeginInvoke 后，可以：
1.进行某些操作，然后调用 EndInvoke 一直阻塞到调用完成。
2.使用 IAsyncResult.AsyncWaitHandle 获取 WaitHandle，使用它的 WaitOne 方法将执行一直阻塞到发出 WaitHandle 信号，然后调用
EndInvoke。这里主要是主程序等待异步方法，等待异步方法的结果。
3.轮询由 BeginInvoke 返回的 IAsyncResult，IAsyncResult.IsCompeted确定异步调用何时完成，然后调用 EndInvoke。此处理个人认为与
相同。
4.将用于回调方法的委托传递给 BeginInvoke。该方法在异步调用完成后在 ThreadPool 线程上执行，它可以调用 EndInvoke。这是在强制装
换回调函数里面IAsyncResult.AsyncState(BeginInvoke方法的最后一个参数)成委托，然后用委托执行EndInvoke。
警告   始终在异步调用完成后调用 EndInvoke。
以上有不理解的稍后可以再理解。
 
例子

1）先来个简单的没有回调函数的异步方法例子
请再运行程序的时候，仔细看注释，对理解很有帮助。还有，若将注释的中的两个方法都同步，你会发现异步运行的速度优越性。
 
using System;

 namespace ConsoleApplication1
 {
     class Class1
     {
         //声明委托
         public delegate void AsyncEventHandler();
 
         //异步方法
         void Event1()
        {
            Console.WriteLine("Event1 Start");
            System.Threading.Thread.Sleep(4000);
            Console.WriteLine("Event1 End");
        }

        // 同步方法
        void Event2()
        {
            Console.WriteLine("Event2 Start");
            int i=1;
            while(i<1000)
            {
                i=i+1;
                Console.WriteLine("Event2 "+i.ToString());
            }
            Console.WriteLine("Event2 End");
        }

        [STAThread]
        static void Main(string[] args)
        {
            long start=0;
            long end=0;
            Class1 c = new Class1();
            Console.WriteLine("ready");
            start=DateTime.Now.Ticks;

            //实例委托
            AsyncEventHandler asy = new AsyncEventHandler(c.Event1);
            //异步调用开始，没有回调函数和AsyncState,都为null
            IAsyncResult ia = asy.BeginInvoke(null, null);
            //同步开始，
            c.Event2();
            //异步结束，若没有结束，一直阻塞到调用完成，在此返回该函数的return，若有返回值。

           
            asy.EndInvoke(ia);

            //都同步的情况。
            //c.Event1();
            //c.Event2();
           
            end =DateTime.Now.Ticks;
            Console.WriteLine("时间刻度差="+ Convert.ToString(end-start) );
            Console.ReadLine();
        }
    }
}


 


2）下面看有回调函数的WebRequest和WebResponse的异步操作。
 using System;
using System.Net;
using System.Threading;
using System.Text;
using System.IO;


// RequestState 类用于通过
// 异步调用传递数据
public class RequestState
{
    const int BUFFER_SIZE = 1024;
    public StringBuilder RequestData;
    public byte[] BufferRead;
    public HttpWebRequest Request;
    public Stream ResponseStream;
    // 创建适当编码类型的解码器
    public Decoder StreamDecode = Encoding.UTF8.GetDecoder();

    public RequestState()
    {
        BufferRead = new byte[BUFFER_SIZE];
        RequestData = new StringBuilder("");
        Request = null;
        ResponseStream = null;
    }
}

// ClientGetAsync 发出异步请求
class ClientGetAsync
{
    public static ManualResetEvent allDone = new ManualResetEvent(false);
    const int BUFFER_SIZE = 1024;

    public static void Main(string[] args)
    {

        if (args.Length < 1)
        {
            showusage();
            return;
        }

        // 从命令行获取 URI
        Uri HttpSite = new Uri(args[0]);

        // 创建请求对象
        HttpWebRequest wreq = (HttpWebRequest)WebRequest.Create(HttpSite);

        // 创建状态对象
        RequestState rs = new RequestState();

        // 将请求添加到状态，以便它可以被来回传递
        rs.Request = wreq;

        // 发出异步请求
        IAsyncResult r = (IAsyncResult)wreq.BeginGetResponse(new AsyncCallback(RespCallback), rs);

        // 将 ManualResetEvent 设置为 Wait，
        // 以便在调用回调前，应用程序不退出
        allDone.WaitOne();
    }

    public static void showusage()
    {
        Console.WriteLine("尝试获取 (GET) 一个 URL");
        Console.WriteLine("\r\n用法：:");
        Console.WriteLine("ClientGetAsync URL");
        Console.WriteLine("示例：:");
        Console.WriteLine("ClientGetAsync http://www.microsoft.com/net/");
    }

    private static void RespCallback(IAsyncResult ar)
    {
        // 从异步结果获取 RequestState 对象
        RequestState rs = (RequestState)ar.AsyncState;

        // 从 RequestState 获取 HttpWebRequest
        HttpWebRequest req = rs.Request;

        // 调用 EndGetResponse 生成 HttpWebResponse 对象
        // 该对象来自上面发出的请求
        HttpWebResponse resp = (HttpWebResponse)req.EndGetResponse(ar);

        // 既然我们拥有了响应，就该从
        // 响应流开始读取数据了
        Stream ResponseStream = resp.GetResponseStream();

        // 该读取操作也使用异步完成，所以我们
        // 将要以 RequestState 存储流
        rs.ResponseStream = ResponseStream;

        // 请注意，rs.BufferRead 被传入到 BeginRead。
        // 这是数据将被读入的位置。
        IAsyncResult iarRead = ResponseStream.BeginRead(rs.BufferRead, 0, BUFFER_SIZE, new AsyncCallback(ReadCallBack), rs);
    }


    private static void ReadCallBack(IAsyncResult asyncResult)
    {
        // 从 asyncresult 获取 RequestState 对象
        RequestState rs = (RequestState)asyncResult.AsyncState;

        // 取出在 RespCallback 中设置的 ResponseStream
        Stream responseStream = rs.ResponseStream;

        // 此时 rs.BufferRead 中应该有一些数据。
        // 读取操作将告诉我们那里是否有数据
        int read = responseStream.EndRead(asyncResult);

        if (read > 0)
        {
            // 准备 Char 数组缓冲区，用于向 Unicode 转换
            Char[] charBuffer = new Char[BUFFER_SIZE];

            // 将字节流转换为 Char 数组，然后转换为字符串
            // len 显示多少字符被转换为 Unicode
            int len = rs.StreamDecode.GetChars(rs.BufferRead, 0, read, charBuffer, 0);
            String str = new String(charBuffer, 0, len);

            // 将最近读取的数据追加到 RequestData stringbuilder 对象中，
            // 该对象包含在 RequestState 中
            rs.RequestData.Append(str);


            // 现在发出另一个异步调用，读取更多的数据
            // 请注意，将不断调用此过程，直到
            // responseStream.EndRead 返回 -1
            IAsyncResult ar = responseStream.BeginRead(rs.BufferRead, 0, BUFFER_SIZE, new AsyncCallback(ReadCallBack), rs);
        }
        else
        {
            if (rs.RequestData.Length > 1)
            {
                // 所有数据都已被读取，因此将其显示到控制台
                string strContent;
                strContent = rs.RequestData.ToString();
                Console.WriteLine(strContent);
            }

            // 关闭响应流
            responseStream.Close();

            // 设置 ManualResetEvent，以便主线程可以退出
            allDone.Set();
        }
        return;
    }
}

 


在这里有回调函数，且异步回调中又有异步操作。
首先是异步获得ResponseStream，然后异步读取数据。
这个程序非常经典。从中可以学到很多东西的。我们来共同探讨。
 
总结

上面说过，.net framework 可以异步调用任何方法。所以异步用处广泛。
在.net framework 类库中也有很多异步调用的方法。一般都是已Begin开头End结尾构成一对，异步委托方法，外加两个回调函数和AsyncState参数，组成异步操作 的宏观体现。所以要做异步编程，不要忘了委托delegate、Begin，End，AsyncCallBack委托，AsyncState实例(在回调 函数中通过IAsyncResult.AsyncState来强制转换)，IAsycResult(监控异步），就足以理解异步真谛了。

来源： <http://www.cnblogs.com/ericwen/archive/2008/03/12/1101801.html>
 
