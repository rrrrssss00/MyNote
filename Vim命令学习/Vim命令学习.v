Ctrl-W 窗口分隔操作:  接hjkl:在窗口间移动 
   接n-/n=(n为数字):调整窗口大小
    :split :vsplit    分屏显示
c:与d命令基本相同,但删除后进行插入模式
r:替换单个字符
R:进入替换模式,一直替换,直到按下ESC
:noh 取消当前的高亮显示
J:合并行

光标：hjkl
翻页：
Ctrl_F，Ctrl_B：前后翻一页 （Forward,Backward）
Ctrl_D,Ctrl_U：前后翻半页（Down,Up）
 
滚屏：
z 回车：将光标所在行放在屏幕最上方
zz:将光标所在行放在屏幕中间
zb:将光标所在行放在屏幕下方
 
复制，粘贴和删除：
x为删除（实时执行，可以前方接数字，xn为删除后方x个字符，xN为删除前方x个字符）
y为复制，yy为复制行，xyy为复制之后的x行，y后面还可以接$,0等，复制光标到行首或行尾
d为剪切或删除，用法可参考y
p为粘贴
 
跳转：
'' ``：在最近的两个位置之间跳转
Ctrl-O，Ctrl-I，向前/向后跳转
 
书签:
:marks:显示所有书签
:delmarks:删除书签
m? 设置一个书签 ?可以是所有数字和大小写字母
' 或 ` 加书签名称,跳转到该书签
 
类似^M与^@之类特殊字符的输入在英文输入状态下,先按Ctrl-Q(本来是Ctrl-v,这个键在Windows下被重定向了),再按Ctrl-M(或相应的其它)
 
多文件操作:
    :ls 列出当前在编辑的所有文件
    :bn 切换到下一个文件
    :bp 切换到前一个文件
    :n# 切换到后面第#个文件
    :b# 切换到列表中的第#个文件
 
代码折叠:
    zc 折叠
    zo 展开
 
宏:
    q* 开始录制宏,*为宏名称
    q 录制结束
    @* 调用宏,*为宏名称
 
缩进:
    == 缩进当前行
    n==缩进当前行及包括当前行在内的后n行
    shift+>>:当前行向后缩进
    shift+<<:当前行向前缩进
 
跳转:
    [{ 跳转到当前所在函数的前花括号处(不在{}内的无效),同理可使用[(
    ]} 跳转到当前所在函数的后花括号处(不在{}内的无效),同理可使用])
    % 跳转到匹配的括号处
 
选择指定的内容(或括号中的内容):
    vi* *为选择的对象,不包括括号
        vi{ 或 vi} 选择当前所在{}内的内容
        vi[ 或 vi] 选择当前所在[]内的内容
        vi( 或 vi) 选择当前所在()内的内容
        vis,vib,vip,viw 选择当前所在的句子,Block,段落,单词
    va* 同vi*,但不包括两端的括号以及一些空格,字符之类的内容
 
寄存器
    :reg 查看寄存器
 
标记和跳转：
    m*:设置标记（*为a-z）
    :marks 查看所有标记
    '*  或 `* ：跳转到该标记
    :delmarks *   删除对应的标记
 
 
 

