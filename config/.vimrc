" ============================================================
" .vimrc — Ansible / YAML tuned config for RH294 lab
" Place at: /home/ansible/.vimrc
" ============================================================

" --- General behaviour ---
set nocompatible            " Use Vim defaults, not Vi compatibility mode
set encoding=utf-8          " Always write UTF-8 files
set history=500             " Remember 500 commands
set autoread                " Reload file if changed outside Vim

" --- Indentation (YAML requires 2-space indent, never tabs) ---
set tabstop=2               " A <Tab> key displays as 2 spaces
set softtabstop=2           " <Tab> in insert mode inserts 2 spaces
set shiftwidth=2            " >> and << indent/dedent by 2 spaces
set expandtab               " Always expand Tab keypresses to spaces
set autoindent              " New line inherits indent of previous line
set smartindent             " Smarter autoindent for structured files

" --- Search ---
set hlsearch                " Highlight all search matches
set incsearch               " Jump to match as you type
set ignorecase              " Case-insensitive search ...
set smartcase               " ... unless the pattern contains uppercase

" --- Line display ---
set number                  " Show absolute line numbers
set relativenumber          " Show relative line numbers (great for jumps)
set cursorline              " Highlight the current line
set colorcolumn=160         " Draw a guide at column 160
set wrap                    " Wrap long lines visually
set linebreak               " Wrap at word boundaries, not mid-word
set scrolloff=5             " Keep 5 lines visible above/below cursor

" --- Status bar ---
set laststatus=2            " Always show the status line
set ruler                   " Show line/column in status line
set showcmd                 " Show partial commands in the status line
set showmode                " Show current mode (INSERT / NORMAL / VISUAL)

" --- Whitespace visibility ---
set list                    " Show invisible characters
set listchars=tab:▸\ ,trail:·,extends:»,precedes:«,nbsp:+
" tab:▸  shows a tab as ▸ followed by spaces — easy to spot accidental tabs in YAML
" trail:· shows trailing whitespace — common YAML mistake

" --- Backspace behaviour ---
set backspace=indent,eol,start  " Allow backspace over indent, line breaks, insert start

" --- Visual helpers ---
set showmatch               " Briefly jump to matching bracket/brace/paren
set matchtime=2             " Show match for 0.2 seconds
syntax on                   " Enable syntax highlighting
set background=dark         " Assume a dark terminal background

" --- File type detection ---
filetype on                 " Detect file type
filetype plugin on          " Load filetype-specific plugins
filetype indent on          " Load filetype-specific indent rules

" --- YAML-specific settings (applied when editing .yml / .yaml files) ---
autocmd FileType yaml setlocal
  \ tabstop=2
  \ softtabstop=2
  \ shiftwidth=2
  \ expandtab
  \ autoindent

" --- Paste mode toggle (prevents auto-indent mangling pasted YAML) ---
set pastetoggle=<F2>
" Press F2 before pasting from clipboard, F2 again to return to normal mode

" --- Quick save / quit shortcuts ---
nnoremap <leader>w :w<CR>   " <leader>w  saves the file
nnoremap <leader>q :q<CR>   " <leader>q  quits
nnoremap <leader>x :x<CR>   " <leader>x  saves and quits
" Default <leader> is backslash \

" --- Clear search highlight with Escape ---
nnoremap <Esc> :nohlsearch<CR>

" --- Split navigation (Ctrl + direction) ---
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" --- Strip trailing whitespace on save (important for YAML) ---
autocmd BufWritePre *.yml,*.yaml :%s/\s\+$//e
autocmd BufWritePre *.ini,*.cfg  :%s/\s\+$//e

" --- Undo persistence (undo history survives closing the file) ---
if has('persistent_undo')
  set undodir=~/.vim/undodir
  set undofile
  silent !mkdir -p ~/.vim/undodir
endif

" --- Wildmenu (tab-completion in command mode) ---
set wildmenu
set wildmode=list:longest,full

" ============================================================
" Key reference
" ============================================================
" F2            Toggle paste mode (use before pasting YAML)
" \w            Save
" \q            Quit
" \x            Save and quit
" Ctrl-h/j/k/l  Navigate between splits
" :set nu!      Toggle line numbers on/off
" :%s/foo/bar/g Global search and replace
" gg=G          Re-indent entire file
" ============================================================
