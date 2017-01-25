vim可以根据用户字义的字典来进行自动补全
 
1）字典：VIM使用的字典即为一系列的单词，在一个文本文件中每行一个即可，如果写在同一行中，VIM会根据isKeyWord中的分隔符自动拆分，如果在补全时需要一些特殊的字符，例如输入pr，希望补全后能出现printf.(，那么不仅需要在字典中添加printf.(，还需要在isKeyWord中将符号.和符号(加入，方法为在vimrc文件中加入
set iskeyword+=.,(
2)使用：字典编写好后，在vimrc文件中加入这样一行代码（将路径换成字典文件的路径）
set dictionary-=$VIM/dic.txt dictionary+=$VIM/dic.txt
然后在输入模式下，输入单词的一部分，再按下<Ctrl-X><Ctrl-K>，即可弹出自动补全选项，若有多个选项，可使用Ctrl-N及Ctrl-P上下选择
3）快捷键：如果觉得<Ctrl-X><Ctrl-K>组合键太麻烦，那么也可以直接将字典补全添加到默认补全列表中，在vimrc中添加下面的代码
set complete-=k complete+=k
在输入模式下，输入单词的一部分，再按下<Ctrl-N>即可开始自动补全
 
若习惯于使用Tab键补全，这里有一个智能Tab补全的代码，将其添加到vimrc中即可，它会根据上下文自动选择补全模式：
 
inoremap <tab> <c-r>=Smart_TabComplete()<CR>
function! Smart_TabComplete()
  let line = getline('.')                         " current line

  let substr = strpart(line, -1, col('.')+1)      " from the start of the current
                                                  " line to one character right
                                                  " of the cursor
  let substr = matchstr(substr, "[^ \t]*$")       " word till cursor
  if (strlen(substr)==0)                          " nothing to match on empty string
    return "\<tab>"
  endif
  let has_period = match(substr, '\.') != -1      " position of period, if any
  let has_slash = match(substr, '\/') != -1       " position of slash, if any
  if (!has_period && !has_slash)
    return "\<C-X>\<C-P>"                         " existing text matching
  elseif ( has_slash )
    return "\<C-X>\<C-F>"                         " file matching
  else
    return "\<C-X>\<C-O>"                         " plugin matching
  endif
endfunction

