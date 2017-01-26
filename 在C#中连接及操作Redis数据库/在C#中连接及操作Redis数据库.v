1：redis下载
在https://github.com/MSOpenTech/redis/releases    中下载编译好的WINDOWS版本REDIS服务端

2：C#连接组件
在https://github.com/ServiceStack/ServiceStack.Redis/releases    中下载组件，编译好的DLL文件位于压缩包的build\release\MonoDevelop目录下

3：基本操作可以参考 http://blog.csdn.net/qiujialongjjj/article/details/16945569 这个系列

4：关于基础连接组件中不支持SCAN命令的问题，可以参考 http://blog.bossma.cn/csharp/nservicekit-redis-support-scan-solution/

5：关于Pipeline的用法，可以参考http://www.cnblogs.com/me-sa/archive/2012/03/13/redis-in-action.html

C#组件在使用Pipeline时，尤其是在迭代使用时，经常会遇见循环出错或不返回值的情况，下面有一个成功的示例，可参考

List<string> keyLst = GetList();
byte[] geoNameBytes = GetBytes("geo");
Dictionary<string,byte[]> resVals = new Dictionary<string,byte[]>();
ServiceStack.Redis.Pipline.IRedisPipeline ipi = client.CreatePipeline();
for(int i=0;i<keyLst.Count;i++)
{
    ipi.QueueCommand(r=>((RedisClient)r).HGet(keyLst[j],geoNameBytes),x=>resVals.Add(keyLst[j],x));
}
ipi.Flush();

