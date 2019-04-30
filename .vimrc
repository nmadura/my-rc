" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2002 Sep 19
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set nobackup		" keep a backup file
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  colorscheme koehler 
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")
set tabstop=2
set shiftwidth=2
set expandtab

" enable Modeline
set modeline
set modelines=5

if $TERM == "xterm-256color"
	let &t_Co=256
	hi Comment ctermfg=darkgray cterm=bold
	hi Constant ctermfg=cyan cterm=bold term=underline
	hi Statement ctermfg=yellow cterm=bold
	hi Cursor ctermfg=black
	hi Visual ctermbg=DarkBlue
	hi LineNr ctermfg=Brown
else
	" Apple_Terminal doesn't support 256 colors
	hi Comment ctermfg=darkgray
	hi Constant ctermfg=cyan cterm=bold term=underline
	hi Statement ctermfg=yellow
	hi Cursor ctermfg=black
end
" set expandtab
source $VIMRUNTIME/menu.vim
" set nu
set nowrap
set wildmenu
set cpo-=<
set wcm=<C-Z>
map <F4> :emenu <C-Z>
let g:snips_author = 'Nathaniel Madura'
let g:snips_email = 'shogunjp@gmail.com'
let g:snips_company = 'The University of Michigan Transporation Research Institute'
