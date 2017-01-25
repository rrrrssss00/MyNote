set nocompatible
source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin
colo freya
 
"以下为解决中文显示问题,以及相应带来的提示及菜单乱码问题
set encoding=utf-8 " 设置vim内部使用的字符编码,原来是cp936
lang messages zh_CN.UTF-8 " 解决consle输出乱码 
"解决菜单乱码 
source $VIMRUNTIME/delmenu.vim 
source $VIMRUNTIME/menu.vim
 
 
set guifont=Menlo:h13:cANSI
set guifontwide=幼圆:b:h13:cGB2312
set nu
set lines=30
set columns=100
 
"不保存备份文件
set nobackup
 
"字典补全功能
set dictionary-=$VIM/commonDic.txt dictionary+=$VIM/commonDic.txt
set complete-=k complete+=k
 
"隐藏菜单及工具栏
set guioptions-=T
"set guioptions-=m
 
"去掉欢迎界面
set shortmess=atI
 
set diffexpr=MyDiff()
function MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let eq = ''
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      let cmd = '""' . $VIMRUNTIME . '\diff"'
      let eq = '"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
endfunction

