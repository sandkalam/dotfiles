" ============================================================================
" VIMRC — Clean & Powerful (gvim + vim compatible)
" Last cleaned: 2025
" ============================================================================

set nocompatible

" ============================================================================
" PLUGIN MANAGEMENT (vim-plug)
" Install: curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
"   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
" ============================================================================

call plug#begin('~/.vim/plugged')

" --- File Navigation ---
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" --- Statusline ---
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" --- Git ---
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" --- LSP / Completion / Snippets ---
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'honza/vim-snippets'

" --- Syntax & Formatting ---
Plug 'sheerun/vim-polyglot'
Plug 'rhysd/vim-clang-format'
Plug 'Yggdroot/indentLine'

" --- Editing Utilities ---
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'mg979/vim-visual-multi'

" --- Color Schemes ---
Plug 'morhetz/gruvbox'
Plug 'joshdick/onedark.vim'

call plug#end()

" ============================================================================
" GENERAL
" ============================================================================

filetype plugin indent on
syntax enable

set encoding=utf-8
set fileencoding=utf-8

" System clipboard (Wayland)
set clipboard=unnamedplus

" Persistent undo
set undofile
set undodir=~/.vim/undodir

" Backup & swap
set backup
set backupdir=~/.vim/backup
set directory=~/.vim/swap

" Auto-create dirs
for s:dir in [$HOME.'/.vim/undodir', $HOME.'/.vim/backup', $HOME.'/.vim/swap']
  if !isdirectory(s:dir) | call mkdir(s:dir, 'p', 0700) | endif
endfor

set autoread
set hidden                  " allow switching buffers without saving

" ============================================================================
" UI
" ============================================================================

set background=dark
colorscheme gruvbox

if has('termguicolors')
  set termguicolors
endif

" --- gvim specific ---
if has('gui_running')
  set guifont=JetBrainsMono\ Nerd\ Font\ 11  " change to your preferred font
  set guioptions-=m                           " remove menu bar
  set guioptions-=T                           " remove toolbar
  set guioptions-=r                           " remove right scrollbar
  set guioptions-=L                           " remove left scrollbar
  set lines=40 columns=130                    " default window size
  set guicursor=n-v-c:block-Cursor            " block in normal
  set guicursor+=i:ver25-iCursor              " thin line in insert
endif

set number
set relativenumber
set cursorline
set showcmd
set ruler
set showmatch
set mouse=a
set scrolloff=8
set sidescrolloff=8
set wildmenu
set wildmode=longest:full,full
set splitbelow
set splitright
set laststatus=2
set noshowmode
set showtabline=1

" ============================================================================
" SEARCH
" ============================================================================

set hlsearch
set incsearch
set ignorecase
set smartcase

" ============================================================================
" INDENTATION & FORMATTING
" ============================================================================

set noexpandtab             " use real tabs (change to expandtab if you prefer spaces)
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smartindent
set autoindent
set wrap
set linebreak

" ============================================================================
" PERFORMANCE
" ============================================================================

set ttyfast
set lazyredraw
set timeoutlen=500
set ttimeoutlen=10
set updatetime=100          " faster gitgutter & CursorHold

" ============================================================================
" CURSOR SHAPE (terminal only — gvim uses guicursor above)
" ============================================================================

if !has('gui_running')
  let &t_SI = "\e[5 q"     " Insert: blinking pipe
  let &t_EI = "\e[1 q"     " Normal: blinking block
endif

" ============================================================================
" KEY MAPPINGS
" ============================================================================

let mapleader      = " "
let maplocalleader = " "

" Save / Quit
nnoremap <leader>w  :w<CR>
nnoremap <leader>q  :q<CR>
nnoremap <leader>x  :x<CR>

" Clear search highlight
nnoremap <leader><space> :nohlsearch<CR>

" NERDTree
nnoremap <leader>n  :NERDTreeToggle<CR>
nnoremap <leader>e  :NERDTreeFind<CR>

" FZF  (note: <leader>p was conflicting with paste — moved to <leader>ff)
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fg :Rg<CR>
nnoremap <leader>fh :History<CR>

" System clipboard  (no conflict with fzf now)
vnoremap <leader>y  "+y
nnoremap <leader>Y  "+yg_
nnoremap <leader>y  "+y
nnoremap <leader>p  "+p
nnoremap <leader>P  "+P
vnoremap <leader>p  "+p
vnoremap <leader>P  "+P

" Split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Resize splits
nnoremap <leader>+  :vertical resize +5<CR>
nnoremap <leader>-  :vertical resize -5<CR>

" Move lines in visual mode
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Keep indent after visual shift
vnoremap < <gv
vnoremap > >gv

" ============================================================================
" COC — Completion, Snippets, LSP
" ============================================================================

let g:coc_global_extensions = [
    \ 'coc-json',
    \ 'coc-tsserver',
    \ 'coc-html',
    \ 'coc-css',
    \ 'coc-pyright',
    \ 'coc-clangd',
    \ 'coc-rust-analyzer',
    \ 'coc-snippets',
    \ 'coc-pairs',
    \ 'coc-eslint',
    \ 'coc-prettier',
    \ 'coc-yaml',
    \ 'coc-sh',
    \ ]

" ── TAB KEY LOGIC ─────────────────────────────────────────────────────────
"
"  Priority order when Tab is pressed:
"   1. If a snippet placeholder/jump target exists → jump to it   (fix!)
"   2. If completion popup is visible              → select next
"   3. If before non-whitespace                    → trigger completion
"   4. Otherwise                                   → insert a real Tab
"
inoremap <silent><expr> <TAB>
    \ coc#pum#visible()             ? coc#pum#next(1)           :
    \ coc#expandableOrJumpable()    ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
    \ CheckBackspace()              ? "\<Tab>"                   :
    \ coc#refresh()

inoremap <silent><expr> <S-TAB>
    \ coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Confirm completion with Enter
inoremap <silent><expr> <CR>
    \ coc#pum#visible() ? coc#pum#confirm()
    \ : "\<C-g>u\<CR>\<C-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1] =~# '\s'
endfunction

" Trigger completion manually
inoremap <silent><expr> <C-space> coc#refresh()

" coc-snippets: tell it Tab is the expand+jump key
let g:coc_snippet_next = '<Tab>'
let g:coc_snippet_prev = '<S-Tab>'

" ── LSP NAVIGATION ────────────────────────────────────────────────────────

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nnoremap <silent> K :call ShowDocumentation()<CR>
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Rename symbol
nmap <leader>rn <Plug>(coc-rename)

" Format
xmap <leader>F  <Plug>(coc-format-selected)
nmap <leader>F  <Plug>(coc-format-selected)

" Quick fix
nmap <leader>qf <Plug>(coc-fix-current)

" Code actions
nmap <leader>ca <Plug>(coc-codeaction-cursor)

" Diagnostics
nnoremap <silent><nowait> <leader>cd :<C-u>CocList diagnostics<CR>
nnoremap <silent><nowait> <leader>cx :<C-u>CocList extensions<CR>
nnoremap <silent><nowait> <leader>cc :<C-u>CocList commands<CR>

" Highlight symbol under cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" ============================================================================
" NERDTREE
" ============================================================================

let NERDTreeShowHidden  = 1
let NERDTreeMinimalUI   = 1
let NERDTreeIgnore      = ['\.git$', '\.DS_Store$', '__pycache__$', 'node_modules$']

" Close vim if NERDTree is the only window left
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1
    \ && exists('b:NERDTree') && b:NERDTree.isTabTree()
    \ | quit | endif

" ============================================================================
" AIRLINE
" ============================================================================

let g:airline_powerline_fonts              = 1
let g:airline_theme                        = 'gruvbox'
let g:airline#extensions#tabline#enabled  = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'

" ============================================================================
" INDENTLINE
" ============================================================================

let g:indentLine_char    = '┊'
let g:indentLine_enabled = 1

" ============================================================================
" FZF
" ============================================================================

let g:fzf_layout         = { 'down': '40%' }
let g:fzf_preview_window = ['right:50%', 'ctrl-/']

" ============================================================================
" AUTOCOMMANDS
" ============================================================================

augroup general
  autocmd!
  " Remove trailing whitespace on save
  autocmd BufWritePre * :%s/\s\+$//e
  " Return to last edit position
  autocmd BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \   exe "normal! g`\"" |
      \ endif
augroup END

augroup filetype_specific
  autocmd!
  " Web: 2-space indent
  autocmd FileType html,css,javascript,typescript,json,yaml
      \ setlocal expandtab ts=2 sts=2 sw=2
  " Python
  autocmd FileType python setlocal expandtab colorcolumn=80
  " C/C++
  autocmd FileType c,cpp setlocal noexpandtab ts=4 sts=4 sw=4
augroup END

" ============================================================================
" CUSTOM COMMANDS
" ============================================================================

command! TrimWhitespace      :%s/\s\+$//e
command! TabsToSpaces        :%s/\t/    /g
command! ToggleRelativeNumber :set relativenumber!

" ============================================================================
" QUICK REFERENCE
" ============================================================================
"
" LEADER = <Space>
"
"  File / Buffer
"   <Space>w        Save
"   <Space>q        Quit
"   <Space>x        Save & quit
"   <Space>ff       FZF files
"   <Space>fb       FZF buffers
"   <Space>fg       FZF ripgrep
"   <Space>fh       FZF history
"
"  Explorer
"   <Space>n        NERDTree toggle
"   <Space>e        NERDTree find current file
"
"  Clipboard
"   <Space>y/Y      Yank to system clipboard
"   <Space>p/P      Paste from system clipboard
"
"  LSP (coc)
"   gd / gy / gi / gr   Go to definition / type / impl / refs
"   K                   Hover docs
"   <Space>rn           Rename
"   <Space>F            Format selection
"   <Space>qf           Quick fix
"   <Space>ca           Code actions
"   <Space>cd           Diagnostics list
"
"  Snippets / Completion  ← TAB FIX
"   Tab (popup open)    Select next completion item
"   Tab (in snippet)    Jump to next placeholder  ← THIS IS THE FIX
"   S-Tab               Previous / jump back
"   Enter               Confirm completion
"   Ctrl-Space          Trigger completion manually
"
" ============================================================================
