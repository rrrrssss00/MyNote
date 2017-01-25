gVim中可以对英文和中文分别设置显示的字体(其实是设置单字节字符和双字节字符分别显示)
 
分别使用
:set guifont=
:set guifontwide=
语句来设置
 
但是,guifontwide的设置只有在 encoding=utf-8 时才能生效
所以,在这两条语句之前,需要先设置encoding
 
设置了encoding之后,菜单栏以及命令行中的显示又会出现乱码,所以,还需要对这些进行重新设置:
 
总体的字体相关设置如下面的代码,将其添加到vimrc中即可,例子中,英文字体使用Menlo,中文字体使用幼圆(粗体)
"以下为解决中文显示问题,以及相应带来的提示及菜单乱码问题
set encoding=utf-8 " 设置vim内部使用的字符编码,原来是cp936
lang messages zh_CN.UTF-8 " 解决consle输出乱码 
"解决菜单乱码 
source $VIMRUNTIME/delmenu.vim 
source $VIMRUNTIME/menu.vim
 
set guifont=Menlo:h13:cANSI
set guifontwide=幼圆:b:h13:cGB2312

