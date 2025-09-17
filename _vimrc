"   Intended for Visual Studio IDE's vsvim extension
"   type ':source %' to reload the vim configs

syntax on

" Leader key configurations
nnoremap <SPACE> <Nop>
vnoremap <SPACE> <Nop>
let mapleader="\<Space>"
set timeoutlen=3000

" To have backspace work as intended
set backspace=indent,eol,start

" Use system keyboard
:set clipboard=unnamed
set number " Show line numbers
set relativenumber " Show relative line numbers
set cursorline " Highlight current line
set showmatch " Show matching brackets/parentheses
set ruler " Show cursor position
set wildmenu " Visual autocomplete for command menu
set showcmd " Show incomplete commands
set spell spelllang=en " Spell checking

" Tab and Indentation settings
set expandtab                   " Use spaces instead of tabs
set smarttab                    " Smart tab behavior
set shiftwidth=2                " 1 tab = 2 spaces
set tabstop=2                   " 1 tab = 2 spaces
set softtabstop=2               " Makes backspace treat 2 spaces as a tab
set autoindent                  " Auto indent
set smartindent                 " Smart indent

" File management
set nobackup                    " No backup files
set nowritebackup               " No backup files during editing
set noswapfile                  " No swap files
set hidden                      " Allow buffers to be hidden without saving

" Spelling correction
" See https://www.reddit.com/r/vim/comments/1ac30kt/comment/kjs5yxx/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u 

nnoremap <C-u> <C-u>zz
vnoremap <C-u> <C-u>zz
nnoremap <C-d> <C-d>zz
vnoremap <C-d> <C-d>zz
nnoremap <C-e> <C-d>zz
vnoremap <C-e> <C-d>zz

" Undo/redo mappings
nnoremap <C-z> u
vnoremap <C-z> u
inoremap <C-z> <C-o>u
nnoremap <C-S-z> <C-r>
vnoremap <C-S-z> <C-r>
inoremap <C-S-z> <C-o><C-r>

" Wrapped line navigation
nnoremap <C-Up> gk
vnoremap <C-Up> gk
inoremap <C-Up> <C-o>gk
nnoremap <C-Down> gj
vnoremap <C-Down> gj
inoremap <C-Down> <C-o>gj

" Save with Ctrl+S
nnoremap <C-s> :update<CR>
inoremap <C-s> <Esc>:update<CR>

" Indent and outdent with < and > in visual mode
vnoremap < <gv
vnoremap > >gv

" Map Ctrl+Backspace to delete the previous word in insert mode
" Note: In many terminals, Ctrl+Backspace sends different codes
inoremap <C-BS> <C-w>
" Map Ctrl+Delete to delete the next word in insert mode
inoremap <C-Del> <C-o>dw

" Window operations
nnoremap <C-w>y <C-w>h
nnoremap <C-w>h <C-w>j
nnoremap <C-w>a <C-w>k
nnoremap <C-w>e <C-w>l
nnoremap <leader>y <C-w>h
nnoremap <leader>h <C-w>j
nnoremap <leader>a <C-w>k
nnoremap <leader>e <C-w>l

" Delete without yanking
nnoremap <leader>d "_d
vnoremap <leader>d "_d
nnoremap <leader>D "_D
vnoremap <leader>D "_D
nnoremap <leader>x "_x
vnoremap <leader>x "_x
nnoremap <leader>X "_X
vnoremap <leader>X "_X

" Change without yanking
nnoremap <leader>c "_c
vnoremap <leader>c "_c
nnoremap <leader>C "_C
vnoremap <leader>C "_C

" Replace currently selected text with default register
" without yanking it
vnoremap <leader>p "_dP
vnoremap p "_dP

" Join lines
nnoremap <leader>j J

if has("gui_running")
  if has("gui_gtk2")
    set guifont=Inconsolata\ 12
  elseif has("gui_macvim")
    set guifont=Menlo\ Regular:h14
  elseif has("gui_win32")
    set guifont=JetBrainsMonoNL\ NFM\ Medium:h14
    " set guifont=Consolas:h11:cANSI
  endif
endif

