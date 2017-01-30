一、概述
首先，ViEmu试用版在安装时会记录安装的时间，用于判断是否已经过了限制的时间，这个时间记录在注册表中
以本人的机器（WIN7X64）为例，它记录在
HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{B9CDA4C6-C44F-438B-B5E0-C1B39EA864C4}的InprocServr32中，其值为
{1E26DF1F-98A2-A32A-F628-91FDEA8AF123}
（注，这两个ID在对于不同的ViEmu版本，在不同的机器上可能是不一样的）
 
这里有两个ID，一个我们称之为目录ID，在本文的例子中，其值为{B9CDA4C6-C44F-438B-B5E0-C1B39EA864C4}，这个应该是与ViEmu的版本有关，对于某个特定的版本，这个值是一定的，
第二个我们称之为时间ID，在本文的例子中，其值为{1E26DF1F-98A2-A32A-F628-91FDEA8AF123}，这里边就记录了安装的时间
 
二、方法
知道了这两个ID，那么解除30天限制的方法就很简单了，
第一个方法是解析出编码的机制，这样就能了解时间ID的真实含义，进而对其修改，实现解除限制的目的
第二个方法更简单粗暴，直接将HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{目录ID}    这个注册表项删除即可（如果不是64位的系统，应为：HKEY_CLASSES_ROOT\CLSID\{目录ID}）
（注：网上还有其它文章提到，在删除该注册表项时需要同时删除C:\Users\用户名\AppData\Local\Identities目录下一个名称里带{}的文件夹，这个可以尝试一下，
本人没有进行这一操作）
（注2：第一种方法比较复杂，需要解析出编码对应的代码，有兴趣的话可以再尝试，下文中只介绍第二种方法）
 
三、步骤
现在，我们只需要找到目录ID的具体值就可以了
首先，我们需要找到所ViEmu的VSHub.dll，目录ID记录在这个DLL文件里边，要找到这个文件可以用以下几种方法：
            1：将下载的ViEmuVS2010-3.0.??.vsix后缀名改为zip，用压缩软件打开后，即可在压缩包中找到该DLL
            2：若已经安装完成，在本地硬盘中查找VSHub.dll即可，WIN7系统下，该文件一般在C:\Users\用户名\AppData\Local\Microsoft\VisualStudio\10.0\Extensions\Symnum Systems SLU\ViEmu\3.0.?? 里
 
第二，使用Reflector（.net的反编译器，可以在网上下载）打开该DLL，找到VSHub命名空间下的Hub类，找到Initialize(RegistryKey)方法并点击进入，在对应的代码中，找到
ViEmuProt.InitializeLicenseStuff(this.m_productData);这一句代码，如下图所示：

（注：Initialize这个方法是在ViEmuTen.dll 中的ViEmuTenPackage类的Initialize方法中被调用的，这个是VS的插件机制，这里不再详述）
 
第三步：点击进入ViEmuProt.InitializeLicenseStuff这个方法，找到其中的vep_WriteTrialPeriodControlItemsIfFirstTime(_productData)函数，如下图所示（这个函数就是写注册表的函数）

 
第四步，再次点击进入该函数，如下图：

红色框所示的函数即为写注册表的函数，可以看到，这个CreateSubKey(name)函数中对应的name参数就是我们需要的目录ID，那么这个ID是怎么来的呢？
可以看到，这个参数是通过函数的第一条语句得到的（图中蓝色框）
（注：图中紫色框即为编码的机制，如果对上文提到的第一种方法有兴趣，可以从这里进入对应的代码，研究一下）
 
第五步：
点击进入GenerateTrialControlRegKeyName(_productData)函数（上图蓝框），如下图所示：

VS插件对应的product是0，所以，目录ID就是最下边那个{B9CDA4C6-C44F-438B-B5E0-C1B39EA864C4}
 
