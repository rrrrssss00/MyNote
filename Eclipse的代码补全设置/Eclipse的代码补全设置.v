默认情况下,只有在用户输入.这个字符的时候,才会进行代码的自动补全,这种情况下,如果要输入try / catch代码块或foreach等,就比较麻烦了

用户需要自动补全时,需要按Alt+/的快捷键,那么怎么开启自动的代码补全呢?

在Eclipse下
 1.打开Eclipse，然后“window”→“Preferences”   (窗口 - 首选项)
2.选择“java”，展开，“Editor”，选择“Content Assist”。(Java - 编辑器 - 内容辅助)
3.选择“Content Assist”(内容辅助)，然后看到右边，右边的“Auto-Activation”(自动激活)下面的“Auto Activation triggers for java”(Java的自动激活触发器)这个选项。其实就是指触发代码提示的就是“.”这个符号.
4.“Auto Activation triggers for java”(Java的自动激活触发器)这个选项，在“.”后加abcdef...wyz这26个字母，那么以后不管输入什么字母,都可以自动开启代码补全了。然后“apply”，点击“OK”。

来源： <http://blog.csdn.net/yushuwai2010/article/details/11856129>
 
