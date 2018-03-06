" Vim configuration fil/
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
" Clang-format
Plug 'rhysd/vim-clang-format'
" Solarized colors
Plug 'altercation/vim-colors-solarized'
" Netwr enchancement
Plug 'tpope/vim-vinegar'
" FZF
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" Cmake building
Plug 'vhdirk/vim-cmake'
" Autocomplete
" Plug 'Valloric/YouCompleteMe', { 'do': './install.py --system-libclang --clang-completer' }
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'
" Async execution
Plug 'shougo/vimproc', { 'do': 'make' }
" Cool statusline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Doxygen
Plug 'vim-scripts/doxygentoolkit.vim', { 'for': 'cpp' }
" Switch between declaration and definition
Plug 'vim-scripts/a.vim'
" Syntax higlighting
Plug 'octol/vim-cpp-enhanced-highlight', { 'for': 'cpp' }
" Surround handling
Plug 'tpope/vim-surround'
" Allow repeat for plugins
Plug 'tpope/vim-repeat'
" Nice colors
Plug 'morhetz/gruvbox'
call plug#end()            " required

" Set colorscheme to solarized
syntax enable
set background=dark
if $SSH_CONNECTION
  let g:solarized_termtrans=0
  let g:solarized_termcolors=256
endif
try
   colorscheme gruvbox
   catch /^Vim\%((\a\+)\)\=:E185/
      echo "Solarized colorsceme not available"
endtry

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
set mouse=nicr                  " Disable mouse
" Disable bell
set visualbell                  " Disable visual bell
set noerrorbells                " Disable error bell
" Spell checking
set spelllang=en_us             " English as default language
set spell                       " Enable by default
" search options
set ignorecase
set smartcase
set incsearch       " do incremental searching
set hlsearch
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
" Make completion menu behave like an IDE
set completeopt=longest,menuone,preview
" misc
set title

highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" netrw
let g:netrw_liststyle = 3
let g:netrw_banner=0

" alternate settings
let g:alternateSearchPath='reg:|src/\([^/]*\)|inc/\1||,reg:|inc/\([^/]*\)|src/\1||,sfr:../source,sfr:../src,sfr:../include,sfr:../inc'

" clang format settings
let g:clang_format#detect_style_file=1
let g:clang_format#auto_format=1
let g:clang_format#auto_format_on_insert_leave=1
autocmd FileType c ClangFormatAutoEnable
autocmd FileType h ClangFormatAutoEnable
autocmd FileType cpp ClangFormatAutoEnable
autocmd FileType hpp ClangFormatAutoEnable

" Autocomplete
if executable('clangd')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': {server_info->['clangd']},
        \ 'whitelist': ['c', 'hpp', 'h', 'cpp', 'objc', 'objcpp'],
        \ })
endif

call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
    \ 'name': 'buffer',
    \ 'whitelist': ['*'],
    \ 'blacklist': ['go'],
    \ 'completor': function('asyncomplete#sources#buffer#completor'),
    \ }))

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<cr>"
imap <c-space> <Plug>(asyncomplete_force_refresh)
let g:asyncomplete_remove_duplicates = 1

" Autocomplete for YouCompleteMe (disabled plugin)
let g:ycm_extra_conf_globlist=['~/.vim/*']
let g:ycm_global_ycm_extra_conf='~/.vim/.ycm_extra_conf.py'
let g:ycm_collect_identifiers_from_tags_files=1
let g:ycm_error_symbol='✗'
let g:ycm_warning_symbol='▲'
let g:ycm_key_select_completion = '<Enter>'
let g:ycm_add_preview_to_completeopt = 1
let g:ycm_autoclose_preview_window_after_completion = 1
nnoremap <leader>jd :YcmCompleter GoTo<CR>

" fzf settings
command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

let g:fzf_nvim_statusline = 0 " disable statusline overwriting
let $FZF_DEFAULT_COMMAND = 'ag -g ""'
let $FZF_DEFAULT_OPTS .= ' --bind=up:preview-up,down:preview-down'

" Key bindings
let mapleader = ","
let g:mapleader = ","

" Fix tabs on new line
inoremap <C-Return> <CR><CR><C-o>k<Tab>

" easily go to end of line
map ยง $
imap ยง $
vmap ยง $
cmap ยง $

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
map   <silent> <F5>        :botright cope<CR>
map   <silent> <F6>        :cclose<CR>
map   <silent> <F7>        :cp<CR>
map   <silent> <F8>        :cn<CR>
" fzf. Former with prefix.
map <silent> <F10> :Files!<CR>
map <silent> <F11> :FZF<CR>
"}}}

" map searches
" no highlight
map <silent> <leader><cr> :noh<cr>

" Switch between header and source
map <leader>a :A<cr>

" Autocommands
augroup filtypes
    autocmd!
    autocmd FileType c,cpp setlocal comments^=:///
    autocmd FileType c,cpp setlocal commentstring=///\ %s
    autocmd FileType crontab setlocal nobackup nowritebackup
augroup end

augroup remove_trailing_whitespace
    autocmd!
    autocmd BufWritePre * :%s/\s\+$//e
augroup end

augroup reload_vimrc
    autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC
augroup end
