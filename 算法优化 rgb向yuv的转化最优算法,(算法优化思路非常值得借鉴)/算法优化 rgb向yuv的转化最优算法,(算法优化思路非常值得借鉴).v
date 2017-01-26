         算法优化:rgb向yuv的转化最优算法,快得让你吃惊!
分类： 视频编解码 程序设计 2009-07-11 11:14 5162人阅读 评论(14) 收藏 举报
算法优化编译器systemmicrosofttable
朋友曾经给我推荐了一个有关代码优化的pdf文档《让你的软件飞起来》，看完之后，感受颇深。为了推广其，同时也为了自己加深印象，故将其总结为word文档。下面就是其的详细内容总结，希望能于己于人都有所帮助。
 
速度取决于算法
同样的事情，方法不一样，效果也不一样。比如，汽车引擎，可以让你的速度超越马车，却无法超越音速；涡轮引擎，可以轻松 超越音障，却无法飞出地球；如果有火箭发动机，就可以到达火星。
 
代码的运算速度取决于以下几个方面
1、  算法本身的复杂度，比如MPEG比JPEG复杂，JPEG比BMP图片的编码复杂。
2、  CPU自身的速度和设计架构
3、  CPU的总线带宽
4、  您自己代码的写法
本文主要介绍如何优化您自己的code，实现软件的加速。
 
先看看我的需求
我们一个图象模式识别的项目，需要将RGB格式的彩色图像先转换成黑白图像。
图像转换的公式如下：
Y = 0.299 * R + 0.587 * G + 0.114 * B;
图像尺寸640*480*24bit，RGB图像已经按照RGBRGB顺序排列的格式，放在内存里面了。
 
我已经悄悄的完成了第一个优化
以下是输入和输出的定义：
#define XSIZE 640
#define YSIZE 480
#define IMGSIZE XSIZE * YSIZE
typedef struct RGB
{
       unsigned char R;
       unsigned char G;
       unsigned char B;
}RGB;
struct RGB in[IMGSIZE]; //需要计算的原始数据
unsigned char out[IMGSIZE]; //计算后的结果
 
第一个优化
优化原则：图像是一个2D数组，我用一个一维数组来存储。编译器处理一维数组的效率要高过二维数组。
 
先写一个代码：
Y = 0.299 * R + 0.587 * G + 0.114 * B;
 
void calc_lum()
{
    int i;
    for(i = 0; i < IMGSIZE; i++)
    {
       double r,g,b,y;
       unsigned char yy;
        r = in[i].r;
        g = in[i].g;
        b = in[i].b;
        y = 0.299 * r + 0.587 * g + 0.114 * b;
        yy = y;
        out[i] = yy;
    }
}
这大概是能想得出来的最简单的写法了，实在看不出有什么毛病，好了，编译一下跑一跑吧。
第一次试跑
这个代码分别用vc6.0和gcc编译，生成2个版本，分别在pc上和我的embedded system上面跑。
速度多少？
在PC上，由于存在硬件浮点处理器，CPU频率也够高，计算速度为20秒。
我的embedded system，没有以上2个优势，浮点操作被编译器分解成了整数运算，运算速度为120秒左右。
 
去掉浮点运算
上面这个代码还没有跑，我已经知道会很慢了，因为这其中有大量的浮点运算。只要能不用浮点运算，一定能快很多。
 
Y = 0.299 * R + 0.587 * G + 0.114 * B;
这个公式怎么能用定点的整数运算替代呢？
0.299 * R可以如何化简？
Y = 0.299 * R + 0.587 * G + 0.114 * B;
Y = D + E + F;
D = 0.299 * R;
E = 0.587 * G;
F = 0.114 * B;
我们就先简化算式D吧！
RGB的取值范围都是0~255，都是整数，只是这个系数比较麻烦，不过这个系数可以表示为：0.299 = 299 / 1000;
所以 D = ( R * 299) / 1000;
Y = (R * 299 + G * 587 + B * 114) / 1000;
 
这一下，能快多少呢？
Embedded system上的速度为45秒；
PC上的速度为2秒；
0.299 * R可以如何化简
Y = 0.299 * R + 0.587 * G + 0.114 * B;
Y = (R * 299 + G * 587 + B * 114) / 1000;
这个式子好像还有点复杂，可以再砍掉一个除法运算。
前面的算式D可以这样写：
0.299=299/1000=1224/4096
所以 D = (R * 1224) / 4096
Y=(R*1224)/4096+(G*2404)/4096+(B*467)/4096
再简化为：
Y=(R*1224+G*2404+B*467)/4096
这里的/4096除法，因为它是2的N次方，所以可以用移位操作替代，往右移位12bit就是把某个数除以4096了。
 
void calc_lum()
{
    int i;
    for(i = 0; i < IMGSIZE; i++)
    {
       int r,g,b,y;
        r = 1224 * in[i].r;
        g = 2404 * in[i].g;
        b = 467 * in[i].b;
        y = r + g + b;
        y = y >> 12; //这里去掉了除法运算
        out[i] = y;
    }
}
这个代码编译后，又快了20%。
虽然快了不少，还是太慢了一些，20秒处理一幅图像，地球人都不能接受。
 
仔细端详一下这个式子！
Y = 0.299 * R + 0.587 * G + 0.114 * B;
Y=D+E+F;
D=0.299*R;
E=0.587*G;
F=0.114*B;
 
RGB的取值有文章可做，RGB的取值永远都大于等于0，小于等于255，我们能不能将D，E，F都预先计算好呢？然后用查表算法计算呢？
我们使用3个数组分别存放DEF的256种可能的取值，然后。。。
 
查表数组初始化
int D[256],F[256],E[256];
void table_init()
{
    int i;
    for(i=0;i<256;i++)
    {
        D[i]=i*1224; 
        D[i]=D[i]>>12;
        E[i]=i*2404; 
        E[i]=E[i]>>12; 
        F[i]=i*467; 
        F[i]=F[i]>>12;
    }
}
void calc_lum()
{
    int i;
    for(i = 0; i < IMGSIZE; i++)
    {
       int r,g,b,y;
        r = D[in[i].r];//查表
        g = E[in[i].g];
        b = F[in[i].b];
        y = r + g + b;
        out[i] = y;
    }
}
 
这一次的成绩把我吓出一身冷汗，执行时间居然从30秒一下提高到了2秒！在PC上测试这段代码，眼皮还没眨一下，代码就执行完了。一下提高15倍，爽不爽？
继续优化
很多embedded system的32bit CPU，都至少有2个ALU，能不能让2个ALU都跑起来？
 
void calc_lum()
{
    int i;
    for(i = 0; i < IMGSIZE; i += 2) //一次并行处理2个数据
    {
       int r,g,b,y,r1,g1,b1,y1;
        r = D[in[i].r];//查表 //这里给第一个ALU执行
        g = E[in[i].g];
        b = F[in[i].b];
        y = r + g + b;
        out[i] = y;
        r1 = D[in[i + 1].r];//查表 //这里给第二个ALU执行
        g1 = E[in[i + 1].g];
        b1 = F[in[i + 1].b];
        y = r1 + g1 + b1;
        out[i + 1] = y;
    }
}
2个ALU处理的数据不能有数据依赖，也就是说：某个ALU的输入条件不能是别的ALU的输出，这样才可以并行。
这次成绩是1秒。
 
查看这个代码
int D[256],F[256],E[256]; //查表数组
void table_init()
{
    int i;
    for(i=0;i<256;i++)
    {
        D[i]=i*1224; 
        D[i]=D[i]>>12;
        E[i]=i*2404; 
        E[i]=E[i]>>12; 
        F[i]=i*467; 
        F[i]=F[i]>>12;
    }
}
到这里，似乎已经足够快了，但是我们反复实验，发现，还有办法再快！
可以将int D[256],F[256],E[256]; //查表数组
更改为
unsigned short D[256],F[256],E[256]; //查表数组
 
这是因为编译器处理int类型和处理unsigned short类型的效率不一样。
再改动
inline void calc_lum()
{
    int i;
    for(i = 0; i < IMGSIZE; i += 2) //一次并行处理2个数据
    {
       int r,g,b,y,r1,g1,b1,y1;
        r = D[in[i].r];//查表 //这里给第一个ALU执行
        g = E[in[i].g];
        b = F[in[i].b];
        y = r + g + b;
        out[i] = y;
        r1 = D[in[i + 1].r];//查表 //这里给第二个ALU执行
        g1 = E[in[i + 1].g];
        b1 = F[in[i + 1].b];
        y = r1 + g1 + b1;
        out[i + 1] = y;
    }
}
将函数声明为inline，这样编译器就会将其嵌入到母函数中，可以减少CPU调用子函数所产生的开销。
这次速度：0.5秒。
 
其实，我们还可以飞出地球的！
如果加上以下措施，应该还可以更快：
1、  把查表的数据放置在CPU的高速数据CACHE里面；
2、  把函数calc_lum()用汇编语言来写
 
其实，CPU的潜力是很大的
1、  不要抱怨你的CPU，记住一句话：“只要功率足够，砖头都能飞！”
2、  同样的需求，写法不一样，速度可以从120秒变化为0.5秒，说明CPU的潜能是很大的！看你如何去挖掘。
3、  我想：要是Microsoft的工程师都像我这样优化代码，我大概就可以用489跑windows XP了！
 
以上就是对《让你的软件飞起来》的摘录，下面，我将按照这位牛人的介绍，对RGB到YCbCr的转换算法做以总结。
 
Y =   0.299R + 0.587G + 0.114B
 U = -0.147R - 0.289G + 0.436B
 V =  0.615R - 0.515G - 0.100B
 
 
#deinfe SIZE 256
#define XSIZE 640
#define YSIZE 480
#define IMGSIZE XSIZE * YSIZE
typedef struct RGB
{
       unsigned char r;
       unsigned char g;
       unsigned char b;
}RGB;
struct RGB in[IMGSIZE]; //需要计算的原始数据
unsigned char out[IMGSIZE * 3]; //计算后的结果
 
unsigned short Y_R[SIZE],Y_G[SIZE],Y_B[SIZE],U_R[SIZE],U_G[SIZE],U_B[SIZE],V_R[SIZE],V_G[SIZE],V_B[SIZE]; //查表数组
void table_init()
{
    int i;
    for(i = 0; i < SIZE; i++)
    {
        Y_R[i] = (i * 1224) >> 12; //Y对应的查表数组
        Y_G[i] = (i * 2404) >> 12; 
        Y_B[i] = (i * 467)  >> 12;
        U_R[i] = (i * 602)  >> 12; //U对应的查表数组
        U_G[i] = (i * 1183) >> 12; 
        U_B[i] = (i * 1785) >> 12;
        V_R[i] = (i * 2519) >> 12; //V对应的查表数组
        V_G[i] = (i * 2109) >> 12; 
        V_B[i] = (i * 409)  >> 12;
    }
}
 
inline void calc_lum()
{
    int i;
    for(i = 0; i < IMGSIZE; i += 2) //一次并行处理2个数据
    {     
        out[i]               = Y_R[in[i].r] + Y_G[in[i].g] + Y_B[in[i].b]; //Y
        out[i + IMGSIZE]     = U_B[in[i].b] - U_R[in[i].r] - U_G[in[i].g]; //U
        out[i + 2 * IMGSIZE] = V_R[in[i].r] - V_G[in[i].g] - V_B[in[i].b]; //V
 
        out[i + 1]                = Y_R[in[i + 1].r] + Y_G[in[i + 1].g] + Y_B[in[i + 1].b]; //Y
        out[i  + 1 + IMGSIZE]     = U_B[in[i + 1].b] - U_R[in[i + 1].r] - U_G[in[i + 1].g]; //U
        out[i  + 1 + 2 * IMGSIZE] = V_R[in[i + 1].r] - V_G[in[i + 1].g] - V_B[in[i + 1].b]; //V
    }
}
 
根据牛人的观点，这种算法应该是非常快的了，以后可直接使用了。^_^

来源： <http://blog.csdn.net/wxzking/article/details/4339650>
 
