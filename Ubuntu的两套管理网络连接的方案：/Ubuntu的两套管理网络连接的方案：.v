原来Linux里面有两套管理网络连接的方案：
1、/etc/network/interfaces（/etc/init.d/networking）
2、Network-Manager
两套方案是冲突的，不能同时共存。
第一个方案适用于没有X的环境，如：服务器；或者那些完全不需要改动连接的场合。
第二套方案使用于有桌面的环境，特别是笔记本，搬来搬去，网络连接情况随时会变的。
－－－－－－－－－－－－－
他们两个为了避免冲突，又能共享配置，就有了下面的解决方案：
1、当Network-Manager发现/etc/network/interfaces被改动的时候，则关闭自己（显示为未托管），除非managed设置成真。
2、当managed设置成真时，/etc/network/interfaces，则不生效。

