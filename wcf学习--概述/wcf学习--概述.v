最近想起学习Silverlight，其中WCF又是不可少的内容，所以开始学习WCF
 
WCF的简介见百度：http://baike.baidu.com/view/1140438.htm
我觉得其实WCF可以理解为WebService的升级版，能够通过配置兼容WebService，同时又拥有一些WebService不具备的优势，比如：
    1）WCF可以不依赖于IIS（在VS环境下）；
    2）WCF 支持多种通信协议 Http/Https 、TCP/UDP、MSMQ、命名管道、对等网、消息可达性、事务流等
    3）WCF 安全性要强：支持对称安全、非对称安全、消息安全、传输安全、SSL 流安全、Windows 流安全等。
    4）WCF支持多种格式化方式。DataContractSerializer、XmlSerializer、  DataContractJsonSerializer 等
    5）……
 
按照我的理解，一个最基本的WCF服务应该包括这些部分：
1）契约（CONTRACT）
WCF使用契约来定义“服务端”与“客户端”之间“服务”及“数据”等内容的格式，一般来说，主要包括服务契约，数据契约，消息契约，错误契约等，
契约的声明应当是建立WCF服务的第一步
 
2）服务的功能实现（Service）
实现WCF服务中的具体功能，
以实例应用为例，需要在SilverLight中调用WCF服务访问Oracle数据库，那么就需要实现访问数据库的功能，以及根据用户传入的参数，返回结果的功能
 
3）寄宿（Host)
Service中，仅有功能的实现，但要使得WCF服务能够被网络上的其它客户端访问到，还需要经过一个寄宿的过程，通过这个过程，WCF将获得一个可访问的地址，能够被其它程序所访问。
除地址之外，在寄宿过程中，还可以配置WCF的许多属性（服务描述 Service Description），比如通信协议，服务类型等
WCF不仅可以通过IIS来寄宿服务，还可以通过其它方法，例如将WCF寄宿到EXE中，执行EXE文件来开启WCF服务
 
4）客户端访问（Client）
通过寄宿这一过程，WCF获得了一个可访问的服务地址，客户端可以通过访问这个服务地址，调用其中的功能
