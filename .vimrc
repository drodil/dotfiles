" Vim configuration
"
" Tuned for c++ development. Requires python language server for
" autocomplete features. Please install it by
"
" sudo apt-get install python-pip
" sudo pip install --upgrade python-language-server
"
" To install plugins, open vim and run :PlugInstall
"
" Some plugins might not work with vim version 8<
"
set nocompatible              " be iMproved, required
filetype off                  " required

" Automatic installation of vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Install plugins
if has('nvim')
    call plug#begin('~/.config/nvim/plugged')
else
    call plug#begin('~/.vim/plugged')
endif
Plug 'tpope/vim-pathogen'
" Detector for wrong style indentations
Plug 'ciaranm/detectindent'
" Git plugins
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
" Vim templates support
Plug 'aperezdc/vim-template'
" Autoformat
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'
" Cheat sheets
Plug 'dbeniamine/cheat.sh-vim'
" Netwr enchancement
Plug 'tpope/vim-vinegar'
" FZF
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" Cmake building
Plug 'vhdirk/vim-cmake'
" Easy commenting
Plug 'tpope/vim-commentary'
" Auto pairs
Plug 'jiangmiao/auto-pairs'
" Autocomplete
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer --go-completer --rust-completer --java-completer' }
" Async execution
Plug 'shougo/vimproc', { 'do': 'make' }
" Cool statusline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Doxygen
Plug 'vim-scripts/doxygentoolkit.vim', { 'for': 'cpp' }
" Switch between declaration and definition
Plug 'vim-scripts/a.vim'
" Buffer explorer
Plug 'jlanzarotta/bufexplorer'
" Syntax higlighting
Plug 'octol/vim-cpp-enhanced-highlight', { 'for': 'cpp' }
" Surround handling
Plug 'tpope/vim-surround'
" Allow repeat for plugins
Plug 'tpope/vim-repeat'
" Nice colors
Plug 'morhetz/gruvbox'
" Conque GDB
Plug 'vim-scripts/Conque-GDB'
Plug 'chemzqm/vim-jsx-improve'
call plug#end()            " required

" Set colorscheme to solarized
syntax enable
set background=dark
if $SSH_CONNECTION
    let g:solarized_termtrans=0
    let g:solarized_termcolors=256
endif

if filereadable( expand("$HOME/.vim/plugged/gruvbox/package.json") )
    colorscheme gruvbox
endif

" set UTF-8 encoding
set enc=utf-8
set fenc=utf-8
set termencoding=utf-8
" use indentation of previous line
set autoindent
" use intelligent indentation for C
set smartindent
" configure tabwidth and insert spaces instead of tabs
set tabstop=4        " tab width is 4 spaces
set shiftwidth=4     " indent also with 4 spaces
set expandtab        " expand tabs to spaces
" wrap lines at 120 chars. 80 is somewaht antiquated with nowadays displays.
set textwidth=120
set backspace=indent,eol,start  " Delete over line breaks
set whichwrap+=<,>,h,l
set laststatus=2                " Always display the status line
set lazyredraw                  " Use lazy redrawing
set ruler                       " Show ruler
set showcmd                     " Show current command
set showmatch                   " Show matching bracket/parenthesis/etc
set showmode                    " Show current mode
" Temp Files
set nobackup                    " No backup file
set noswapfile                  " No swap file
" show line number
set number
" Mouse
set mousehide                   " Hide mouse when typing
"set mouse=nicr                  " Disable mouse
set mouse=a
set ttyfast
" Disable bell
set visualbell                  " Disable visual bell
set noerrorbells                " Disable error bell
" Change buffer without saving
set hid
" Regex support with magic
set magic
" Spell checking
set spelllang=en_us             " English as default language
set spell                       " Enable by default
" search options
set ignorecase
set smartcase
set incsearch       " do incremental searching
set hlsearch
set gdefault
" wordwrap
set nowrap
set sidescroll=15
set listchars+=precedes:<,extends:>
set tags+=~/.vim/tags/cpp;./tags;/.     " recursively search tags from current directory
set autoread            " auto read when a file is changed from the outside
" Key sequence timeout
set ttimeout                    " Enable time out
set ttimeoutlen=0               " Disable key code delay
set mat=2
" Scroll
set sidescrolloff=5             " Keep at least 5 lines left/right
set scrolloff=5                 " Keep at least 5 lines above/below
" History
set history=1000                " Remember more commands
if has('persistent_undo')
    set undofile                " Persistent undo
    set undodir=~/.vim/undo     " Location to store undo history
    set undolevels=1000         " Max number of changes
    set undoreload=10000        " Max lines to save for undo on a buffer reload
endif
" misc
set title

"   Correct some spelling mistakes    "
ia teh      the
ia htis     this
ia tihs     this
ia funciton function
ia fucntion function
ia funtion  function
ia retunr   return
ia reutrn   return
ia sefl     self
ia eslf     self
ia viod     void

" Remove extra whitespace automatically
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()
autocmd FileType netrw setl bufhidden=wipe

" netrw
let g:netrw_liststyle = 3
let g:netrw_banner=0
let g:netrw_preview = 1

" alternate settings
let g:alternateSearchPath='reg:|src/\([^/]*\)|inc/\1||,reg:|inc/\([^/]*\)|src/\1||,sfr:../source,sfr:../src,sfr:../include,sfr:../inc'

" Template settings
let g:templates_no_autocmd=1
let g:templates_directory=['~/.vim/templates']
let g:templates_global_name_prefix='tpl'

" clang format settings
let g:clang_format#detect_style_file=1
let g:clang_format#auto_format=1
let g:clang_format#auto_format_on_insert_leave=1

" Autoformat settings
augroup autoformat_settings
    autocmd FileType c,cpp,hpp,h,proto,java AutoFormatBuffer clang-format
    autocmd FileType go AutoFormatBuffer gofmt
    autocmd FileType gn AutoFormatBuffer gn
    autocmd FileType html,css,sass,scss,less,json AutoFormatBuffer js-beautify
    autocmd Filetype python AutoFormatBuffer autopep8
    autocmd Filetype javascript AutoFormatBuffer prettier
augroup END

" Autocomplete for YouCompleteMe
let g:ycm_global_ycm_extra_conf='~/.vim/.ycm_extra_conf.py'
let g:ycm_error_symbol='✗'
let g:ycm_warning_symbol='▲'

" fzf settings
command! -bang -nargs=? -complete=dir Files
            \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

let g:fzf_nvim_statusline = 0 " disable statusline overwriting
if executable('ag')
    let $FZF_DEFAULT_COMMAND = 'ag -g ""'
    let g:ackprg = 'ag --vimgrep'
endif
let $FZF_DEFAULT_OPTS .= ' --bind=up:preview-up,down:preview-down'

" Key bindings
let mapleader = ","
let g:mapleader = ","

nnoremap <leader>jd :YcmCompleter GoToDefinition<CR>
nnoremap <leader>jj :YcmCompleter GoToDefinitionElseDeclaration<CR>
nnoremap <leader>jg :YcmCompleter GoToDeclaration<CR>
nnoremap <leader>jk :YcmCompleter GoToInclude<CR>

" Search in visual mode
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>

" Fix tabs on new line
inoremap <C-Return> <CR><CR><C-o>k<Tab>

" easily go to end of line
map ยง $
imap ยง $
vmap ยง $
cmap ยง $
" Add newline from normal mode
nmap <C-S> o<Esc>k<CR>
" buffer resizing
map <silent> <S-h> <C-W>10<
map <silent> <S-j> <C-W>10-
map <silent> <S-k> <C-W>10+
map <silent> <S-l> <C-W>10>

" horisontal and vertical splitting
map <silent> <leader>s :split<CR>
map <silent> <leader>v :vsplit<CR>

" Fast editing of the .vimrc
map <leader>e :e! $MYVIMRC<cr>

" F1 - F12 {{{
" Explore
map <silent> <F2> <Esc><Esc>:call ToggleExplore()<CR>
" Shorter commands to toggle Taglist display
map <silent> <F3>  <Esc><Esc>:TagbarToggle<CR>
" BufExplorer toggle
map <silent> <F4>  <Esc><Esc>:ToggleBufExplorer<CR>
" Quickfix toggle
map <silent> <F5>        :botright cope<CR>
map <silent> <F6>        :cclose<CR>
map <silent> <F7>        :cp<CR>
map <silent> <F8>        :cn<CR>
map <silent> <F9> :YcmCompleter FixIt<CR>
" fzf. Former with prefix.
map <silent> <F10> :Files!<CR>
map <silent> <F11> :Ag<CR>
map <F12> :!bash $HOME/.vim/tags/generate_tags.sh -d . -i "build docs"<CR>
"}}}

" map searches
" no highlight
map <silent> <leader><cr> :noh<cr>

" Switch between header and source
map <leader>a :A<cr>

" Get off my lawn - helpful when learning Vim :)
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

" Shortcuts for system clipboard
" Copy to X CLIPBOARD
map <silent> <leader>cc :w !xsel -i -b<CR><CR>
map <silent> <leader>cp :w !xsel -i -p<CR><CR>
map <silent> <leader>cs :w !xsel -i -s<CR><CR>
" Paste from X CLIPBOARD
map <silent> <leader>pp :r!xsel -p<CR><CR>
map <silent> <leader>ps :r!xsel -s<CR><CR>
map <silent> <leader>pb :r!xsel -b<CR><CR>

" Autocommands
autocmd BufWritePre * %s/\s\+$//e
augroup filtypes
    autocmd!
    autocmd FileType c,cpp setlocal comments^=:///
    autocmd FileType c,cpp setlocal commentstring=///\ %s
    autocmd FileType crontab setlocal nobackup nowritebackup
augroup end

augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
    autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

augroup remove_trailing_whitespace
    autocmd!
    autocmd BufWritePre * :%s/\s\+$//e
augroup end

augroup reload_vimrc
    autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC
augroup end

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Toggle Vexplore {{{
"
function! ToggleExplore()
    if &ft ==# "netrw"
        Rexplore
    else
        Explore
    endif
endfunction
" }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{ Ruby settings
"
autocmd FileType ruby set shiftwidth=2
augroup filetypedetect
    autocmd BufNewFile,BufRead *.yml setf eruby
augroup END
"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{ Perl settings
"
autocmd FileType perl set shiftwidth=2
"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{ Tex settings
"
autocmd FileType tex set shiftwidth=2
autocmd FileType tex let g:tex_flavor = "latex"
"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{ Markdown settings
"
au BufRead,BufNewFile *.md setlocal textwidth=80
"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{ JavaScript settings
"
au FileType javascript call JavaScriptSettings()
function! JavaScriptSettings()
    setl nocindent
endfunction
"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Python settings {{{
"
au FileType python call PythonSettings()
function! PythonSettings()
    set nocindent
    set shiftwidth=2
    set tabstop=2
    set softtabstop=2
    "autocmd BufWrite *.py :call DeleteTrailingWS()
endfunction
"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Bitbake settings {{{
"
au FileType bitbake call BibakeSettings()
function! BibakeSettings()
    set nocindent
    "autocmd BufWrite *.bb :call DeleteTrailingWS()
    "autocmd BufWrite *.bbclass :call DeleteTrailingWS()
    "autocmd BufWrite *.bbappend :call DeleteTrailingWS()
endfunction
"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Bash settings {{{
"
function! BashSettings()
    setl expandtab
    setl shiftwidth=2
    setl tabstop=2
    setl softtabstop=2
endfunction
"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CMake settings {{{
"
autocmd BufRead,BufNewFile *.cmake,CMakeLists.txt,*.cmake.in call CMakeSettings()
function! CMakeSettings()
    setl expandtab
    setl shiftwidth=4
    setl tabstop=4
    setl softtabstop=4
endfunction
"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Rust settings {{{
"
au FileType rust nmap gd <Plug>(rust-def)
au FileType rust nmap gs <Plug>(rust-def-split)
au FileType rust nmap gx <Plug>(rust-def-vertical)
au FileType rust nmap <leader>gd <Plug>(rust-doc)
au FileType rust compiler cargo
"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Makefiles {{{
"
au FileType make setl noexpandtab " use real tabs
au FileType make setl shiftwidth=8 " standard shift width
au FileType make setl tabstop=8 " use standard tab size

"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" binary files {{{
"
augroup Binary " vim -b : edit binary using xxd-format!
    au!
    au BufReadPre  *.tgz,*.BIN,*.bin,*.img let &bin=1
    au BufReadPost *.tgz,*.BIN,*.bin,*.img if &bin | %!xxd
    au BufReadPost *.tgz,*.BIN,*.bin,*.img set ft=xxd | endif
    au BufWritePre *.tgz,*.BIN,*.bin,*.img if &bin | %!xxd -r
    au BufWritePre *.tgz,*.BIN,*.bin,*.img endif
    au BufWritePost *.tgz,*.BIN,*.bin,*.img if &bin | %!xxd
    au BufWritePost *.tgz,*.BIN,*.bin,*.img set nomod | endif
augroup END
"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

