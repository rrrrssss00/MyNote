首先安装Linux ,这里选择的是Ubuntu的Server版,12.04.2,细节就不详细描述了
 
然后安装JDK以及Eclipse,步骤如下:
1. 安装JDK
　　ubuntu 11.04系统自带的Java环境是openjdk，最好使用sunjdk（具体原因不明，网上教程基本都是这样的），因此先去官方网站（ http://www.oracle.com/technetwork/java/javase/downloads/index.html）下载“ Java SE 6 Update 26 ”的JDK安装包：
Linux x86 - Self Extracting Installer （81.20 MB） jdk-6u26-linux-i586.bin
1.1. 下载好后开始安装JDK，在终端里输入：
cd Downloads/
sudo cp jdk-6u26-linux-i586.bin /opt
cd /opt
sudo chmod +x jdk-6u26-linux-i586.bin
1.2. 解压缩安装包进行安装。
sudo ./jdk-6u26-linux-i586.bin
1.3. 接下来要配置环境变量，修改profile文件。
sudo gedit /etc/profile
在文本中添加以下代码：
# Sun JDK profile
export JAVA_HOME=/opt/jdk1.6.0_26
export JRE_HOME=/opt/jdk1.6.0_26/jre
export CLASSPATH=.:$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH:$HOME/bin
1.4. 还要修改另外一个文件environment：
sudo gedit /etc/environment
在文本中添加以下代码：
# Sun JDK environment
export JAVA_HOME=/opt/jdk1.6.0_26
export JRE_Home=/opt/jdk1.6.0_26/jre
export CLASSPATH=.:$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib
1.5. 手动配置JDK。
sudo update-alternatives --install /usr/bin/java java /opt/jdk1.6.0_26/bin/java 300
sudo update-alternatives --install /usr/bin/javac javac /opt/jdk1.6.0_26/bin/javac 300
1.6. 让系统使用我们安装的JDK。
sudo update-alternatives --config java
1.7. 验证安装JDK是否成功。
java –version
将会看到下面的信息。
java version "1.6.0_26"
Java(TM) SE Runtime Environment (build 1.6.0_26-b03)
Java HotSpot(TM) Server VM (build 20.1-b02, mixed mode)
2. 安装Eclipse。
2.1. 首先解压缩下载好的压缩包，在终端中输入：
tar -zxvf eclipse-SDK-3.6.2-linux-gtk.tar.gz
sudo mv eclipse /opt/
sudo gedit /usr/share/applications/Eclipse.desktop
在文本中填入：
[Desktop Entry]
Name=Eclipse
Comment=Eclipse IDE
Exec=/opt/eclipse/eclipse
Icon=/opt/eclipse/icon.xpm
Terminal=false
Type=Application
Categories=Application;Development;
2.2 eclipse安装结束。
来源： <http://www.cnblogs.com/williamwue/archive/2011/06/23/2088315.html>
 
 
 

