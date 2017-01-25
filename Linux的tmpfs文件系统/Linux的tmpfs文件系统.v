Linux的tmpfs文件系统

博客分类：
linux技术
 
前几天发现服务器的内存(ram)和swap使用率非常低，于是就想这么多的资源

不用岂不浪费了？google了一下，认识了tmpfs，总的来说tmpfs是一种虚拟内存文件系统

正如这个定义它最大的特点就是它的存储空间在VM里面，这里提一下VM(virtual memory)

，VM是由linux内核里面的vm子系统管理的东东，现在大多数操作系统都采用了虚拟内存

管理机制?更详细的说明请参考<<UnderStanding The Linux Virtual Memory Manager>)

linux下面VM的大小由RM(Real Memory)和swap组成,RM的大小就是物理内存的大小，而Swap

的大小是由你自己决定的。Swap是通过硬盘虚拟出来的内存空间，因此它的读写速度相对

RM(Real Memory）要慢许多，我们为什么需要Swap呢？当一个进程申请一定数量的内存时

，如内核的vm子系统发现没有足够的RM时，就会把RM里面的一些不常用的数据交换到Swap

里面，如果需要重新使用这些数据再把它们从Swap交换到RM里面。 如果你有足够大的物理

内存，根本不需要划分Swap分区。

     通过上面的说明，你该知道tmpfs使用的存储空间VM是什么了吧？ 前面说过VM由

RM+Swap两部分组成，因此tmpfs最大的存储空间可达（The size of RM + The size of

Swap）。 但是对于tmpfs本身而言，它并不知道自己使用的空间是RM还是Swap，这一切

都是由内核的vm子系统管理的。


     怎样使用tmpfs呢？

     #mount  -t tmpfs -o size=20m  tmpfs  /mnt/tmp

     上面这条命令分配了上限为20m的VM到/mnt/tmp目录下，用df命令查看一下，确实

/mnt/tmp挂载点显示的大小是20m，但是tmpfs一个优点就是它的大小是随着实际存储的

容量而变化的，换句话说，假如/mnt/tmp目录下什么也没有，tmpfs并不占用VM。上面的

参数20m只是告诉内核这个挂载点最大可用的VM为20m，如果不加上这个参数，tmpfs默认

的大小是RM的一半，假如你的物理内存是128M，那么tmpfs默认的大小就是64M，

    
     tmpfs有没有缺点呢?

     当然有，由于它的数据是在VM里面，因此断电或者你卸载它之后，数据就会立即丢

失，这也许就是它叫tmpfs的原故。不过这其实不能说是缺点。那tmpfs到底有什么用呢？

     tmpfs的用途

     由于tmpfs使用的是VM，因此它比硬盘的速度肯定要快，因此我们可以利用这个优点

使用它来提升机器的性能。


      #mount -t tmpfs  -o size=2m   tmpfs  /tmp

      上面这条命令分配了最大2m的VM给/tmp。    

       由于/tmp目录是放临时文件的地方，因此我们可以使用tmpfs来加快速度，由于

没有挂载之前/tmp目录下的文件也许正在被使用，因此挂载之后系统也许有的程序不能

正常工作。没有关系，只要在/etc/fstab里面加上下面的语句

      tmpfs    /tmp      tmpfs   size=2m    0   0

重启电脑之后就一切OK了。

         
      强列建议你看看下面这篇文章。

      http://www-128.ibm.com/developerworks/cn/linux/filesystem/l-fs3/


      另外还可以参考

      2.6内核里面的Documentation/filesystems/tmpfs.txt
 
例子：
linux下用tmpfs加速你的WEB服务器

使用tmpfs,我把他消化后用来实现虚拟磁盘来存放squid的缓存文件和php的seesion。速度快不少哦！
默 认系统就会加载/dev/shm ，它就是所谓的tmpfs，有人说跟ramdisk（虚拟磁盘），但不一样。象虚拟磁盘一样，tmpfs 可以使用您的 RAM，但它也可以使用您的交换分区来存储。而且传统的虚拟磁盘是个块设备，并需要一个 mkfs 之类的命令才能真正地使用它，tmpfs 是一个文件系统，而不是块设备；您只是安装它，它就可以使用了。

tmpfs有以下优势：

1.动态文件系统的大小，
2.tmpfs 的另一个主要的好处是它闪电般的速度。因为典型的 tmpfs 文件系统会完全驻留在 RAM 中，读写几乎可以是瞬间的。
3.tmpfs 数据在重新启动之后不会保留，因为虚拟内存本质上就是易失的。所以有必要做一些脚本做诸如加载，绑定的操作。
好了讲了一些大道理，大家看的烦了吧，还是讲讲我的应用吧：）
首先在/dev/stm建个tmp文件夹，然后与实际/tmp绑定
mkdir /dev/shm/tmp
chmod 1777 /dev/shm/tmp
mount --bind /dev/shm/tmp /tmp
1.squid的缓存目录设置
vi /etc/squid/squid.conf

修改成
cache_dir ufs /tmp 256 16 256
这里的第一个256表示使用256M内存，我觉得高性能LINUX双效防火墙HOWTO使用ramdisk的方法还不如直接使用tmpfs，至少每次启动不用mkfs，还可以动态改变大小。
然后重启一下服务，ok，现在所有的squid缓存文件都保存倒tmpfs文件系统里了，很快哦。
2.对php性能的优化
对于一个访问量大的以apache＋php的网站，可能tmp下的临时文件都会很多，比如seesion或者一些缓存文件，那么你可以把它保存到tmpfs文件。
保存seesion的方法很简单了只要修改php.ini就行了，由于我已经把/dev/stm/tmp与/tmp绑定，所以不改写也行，至于php程序产生的缓存文件那只能改自己的php程序了：）

来源： <http://futureinhands.iteye.com/blog/1507863>
 

