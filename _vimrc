set nocompatible
source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin

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
"以上为默认内容

"判断操作系统
if(has("win32") || has("win95") || has("win64") || has("win16"))
    let g:iswindows=1
else
    let g:iswindows=0
endif

set nu!
syntax on 
syntax enable
colorscheme solarized
set tags=tags;
set autochdir 
let Tlist_Show_One_File=1
let Tlist_Exit_OnlyWindow=1 
let g:winManagerWindowLayout='FileExplorer|TagList'
nmap wm :WMToggle<cr> 
let g:miniBufExplMapCTabSwitchBufs=1
let g:miniBufExplMapWindowsNavVim=1
let g:miniBufExplMapWindowNavArrows=1 

"兼容dos & unix 文本
set fileformats=unix,dos

"高亮当前行
set cursorline 

"编码
set encoding=utf-8
set termencoding=utf-8
set fileencodings=utf-8,chinese,latin-1
if g:iswindows==1
    set fileencoding=chinese
else
    set fileencoding=utf-8
endif
set fenc=gbk
language messages zh_CN.utf-8

"界面
set go=

"字体
if g:iswindows==1
    set guifont=Consolas:h11:cANSI,幼圆:h11:cGB2312
else
    set guifont=Sayo\ UV\ Console\ HC\ 11
endif

"关闭声音
set vb t_vb= 
set novisualbell 

" Tab 与缩进
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent

" 禁用临时文件
set nobackup
set nowritebackup
set noswapfile
set noundofile

"窗口透明,仅Windows下有效
if g:iswindows==1
    map <F5> :call Transparent()<CR>
    imap <F5> <ESC>:call Transparent()<CR>
    let g:istrans=0
    function Transparent()
        if (g:istrans==0)
            execute "call libcallnr(\"vimtweak.dll\", \"SetAlpha\", 220)"
            let g:istrans=1
        else
            execute "call libcallnr(\"vimtweak.dll\", \"SetAlpha\", 255)"
            let g:istrans=0
        endif 
    endfunction 
endif 

map <F1> :call NightMode()<CR>
imap <F1> <ESC>:call NightMode()<CR>
let g:isNightMode=1
function NightMode()
    if (g:isNightMode==0)
        set bg=dark
        let g:isNightMode=1
    else
        set bg=light
        let g:isNightMode=0
    endif 
endfunction 

"关闭提示音
set noeb
set vb

au BufRead,BufNewFile _pentadactylrc set filetype=pentadactyl
au BufNewFile,BufRead *.asm set filetype=fasm
au BufNewFile,BufRead *.md set filetype=markdown

" 禁用输入法
set iminsert=0
set imsearch=0
se imd
au InsertEnter * se noimd
au InsertLeave * se imd
au FocusGained * se imd

"单个文件编译 
"支持c/c++, java, haskell
map <F9> :call Do_OneFileMake()<CR>
imap <F9> <ESC>:call Do_OneFileMake()<CR>
function Do_OneFileMake()
    execute "cclose"
    if expand("%:p:h")!=getcwd()
        echohl WarningMsg | echo "Fail to make! This file is not in the current dir! " | echohl None
        return
    endif
    let sourcefileename=expand("%:t")
    if (sourcefileename=="" || (&filetype!="cpp" && &filetype!="c" && &filetype!="java" && &filetype!="haskell" && &filetype!="python"))
        echohl WarningMsg | echo "Fail to make! Please select the right file!" | echohl None
        return
    endif
    exec "w" 
    echo "file saved."
    "设置make参数
    if &filetype=="c"
        if g:iswindows==1
            set makeprg=gcc\ -o\ \"%<.exe\"\ \"%\"
        else
            " 默认用32位编译
            set makeprg=gcc\ -m32\ -o\ \"%<\"\ \"%\"
        endif
    elseif &filetype=="cpp"
        if g:iswindows==1
            set makeprg=g++\ -o\ \"%<.exe\"\ \"%\"
        else
            set makeprg=g++\ -o\ \"%<\"\ \"%\"
        endif
    elseif &filetype=="java"
        set makeprg=javac\ \"%\"
    elseif &filetype=="haskell"
        execute "!ghci %"
        return
    elseif &filetype=="python"
        execute "!python -i %"
        return
    endif
    "删除旧文件,对于非编译型的就算了
    if (&filetype=="c" || &filetype=="cpp") 
        if g:iswindows==1
            let outfilename=expand("%:r").".exe"
        else
            let outfilename=expand("%:r")
        endif
    elseif &filetype=="java" 
        let outfilename=expand("%:r").".class"
    endif

    if filereadable(outfilename)
        if(g:iswindows==1)
            let outdeletedsuccess=delete(outfilename)
        else
            let outdeletedsuccess=delete("./".outfilename) "maybe useable
        endif
        if(outdeletedsuccess!=0)
            set makeprg=make
            echohl WarningMsg | echo "Fail to make! I cannot delete the ".outfilename | echohl None
            return
        endif
    endif
    "静默编译
    execute "silent make"
    set makeprg=make   
    "编译成功后执行
    if filereadable(outfilename)
        if &filetype=="java"
            execute "!java %<"
            return
        else
            if(g:iswindows==1)
                execute "silent !\"%<.exe\""
                return 
            else
                execute "!./\"%<\"" 
                return 
            endif
        endif 
    endif
    "不成功弹出错误信息
    execute "silent copen 6"
endfunction

"让Vim的补全菜单行为与一般IDE一致(参考VimTip1228)
"set completeopt+=longest
 
"离开插入模式后自动关闭预览窗口
autocmd InsertLeave * if pumvisible() == 0|pclose|endif
 
"回车即选中当前项
inoremap <expr> <CR>       pumvisible() ? "\<C-y>" : "\<CR>"
 
"上下左右键的行为
inoremap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <expr> <PageDown> pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<PageDown>"
inoremap <expr> <PageUp>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<PageUp>"
