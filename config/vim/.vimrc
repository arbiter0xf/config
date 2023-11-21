" =========================================================
" Plugins / Plugins / Plugins / Plugins / Plugins / Plugins
" =========================================================
set nocompatible	" Be iMproved, required
filetype off		" required

" Setting vim runtimepath in alias script to vim80
"set rtp+=/usr/share/vim/vim80 "

" Set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" Keep Plugin commands between vundle#begin/end.

" Let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
"Plugin 'gmarik/Vundle.vim'

" Git wrapper
Plugin 'tpope/vim-fugitive'

" Search
Plugin 'mileszs/ack.vim'

" Files
Plugin 'tpope/vim-vinegar'
Plugin 'jlanzarotta/bufexplorer'

" View
Plugin 'majutsushi/tagbar'

" Edit
Plugin 'tpope/vim-commentary'
Plugin 'sjl/gundo.vim'
Plugin 'vim-scripts/VisIncr'

" Language
" Plugin 'ervandew/supertab'
Plugin 'Shougo/neocomplete.vim'
Plugin 'andreshazard/vim-logreview'
Plugin 'vim-syntastic/syntastic'

" Journal
Plugin 'vimwiki/vimwiki'
" Plugin 'tbabej/taskwiki' " <- python problems

" Colors
Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

call vundle#end()		" required
filetype plugin indent on	" required

" =========================================================
" Visuals / Visuals / Visuals / Visuals / Visuals / Visuals
" =========================================================
" Allow buffers to be hidden if buffer is modified
set hidden

" More readable syntax highlighting
set background=dark
colorscheme solarized

" Line numbers
set nu

" Wrap without inserting newlines
set wrap

" Only filename in tab
set guitablabel=%t

" 80 character limit marker
set colorcolumn=79

set tabpagemax=100

" Disable search highlighting
set nohlsearch

" Highlight current line
set cursorline
hi CursorLine	ctermbg=black
		\ ctermfg=red guibg=black guifg=red
hi CursorColumn ctermbg=black
		\ ctermfg=red guibg=black guifg=red

"let $VIMRUNTIME='/usr/share/vim/vim80'
let $VIMRUNTIME='/usr/share/vim/vim82'
syntax enable
"source $VIMRUNTIME/syntax/syntax.vim

let g:airline_powerline_fonts = 1
set t_Co=256

" Show airline all the time
set laststatus=2

if !exists('g:airline_symbols')
	let g:airline_symbols = {}
endif

" Jump to first or last row of currently visible rows.
set scrolloff=0

" --------------------------------------------------------------------- "
" Powerline fonts for terminal from: https://github.com/powerline/fonts "
" --------------------------------------------------------------------- "

" Airline symbols fallback
let g:airline_theme='murmur'
let g:airline_detect_paste = 1
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

" ==============================================================
" Keymapping / Keymapping / Keymapping / Keymapping / Keymapping
" ==============================================================
let mapleader = ","

" Open a new empty buffer
nmap <leader>eb :enew<CR>

" Move to the next buffer
nmap <leader>f :bnext<CR>

" Move to the previous buffer
nmap <leader>d :bprevious<CR>

" Close the current buffer and move to the previous one
nmap <leader>bb :bp <BAR> bd #<CR>
"nmap <leader>bb :bd <BAR> bp<CR>

" Show all open buffers and their status
nmap <leader>l :ls<CR>

" Show whitespace
nnoremap <leader>wh :set list!<CR>

" Log highlighting for files without log filetype
nnoremap <leader>sl :set filetype=logreview

nmap <leader>v :vsplit<CR>
nmap <leader>h :split<CR>
nmap <leader>cls :close<CR>
nmap <leader>bu :buffer<CR>
nmap <leader>sv :source ~/.vimrc<CR>
nmap <leader>ev :vsplit ~/.vimrc<CR>
nmap <leader>it :set noexpandtab softtabstop=0 tabstop=8 shiftwidth=8<CR>
nmap <leader>is :set tabstop=8 softtabstop=0 expandtab
	\ shiftwidth=4 smarttab<CR>

nmap <leader>t :TagbarToggle<CR>

nmap <F7> :tabp<CR>
nmap <F8> :tabn<CR>

" Manually run code analysis
nmap <F10> :SyntasticCheck<CR>

" Syntastic to passive mode and back
nmap <leader>stm :SyntasticToggleMode<CR>

" NVIM: turn off highlighting of most recent search
nmap <leader>so :noh<CR>

nmap <leader>new 0i[ ---- ]<ESC>
nmap <leader>did 0f-deiDONE<ESC>

" To remember how to get command output to current file
nmap <leader>ls :r!ls<CR>

nnoremap <leader>clc :set cursorline! cursorcolumn!<CR>
nnoremap <leader>cl :set cursorline!<CR>
nnoremap <leader>cc :set cursorcolumn!<CR>
nnoremap <leader>ct :set nocursorline nocursorcolumn<CR>

" Do not jump to first result automatically
nnoremap <leader>a :Ack!<Space>

nmap <leader>wah :VimwikiAll2HTML<CR>

nmap <leader>ncd :NeoCompleteEnable<CR>
nmap <leader>nce :NeoCompleteDisable<CR>

" =====================================================
" Help / Help / Help / Help / Help / Help / Help / Help
" =====================================================
" :help syntastic-checkers " <- lists syntax checkers
" :help vimwiki " <- help on wiki syntax

" ====================================================
" Remember / Remember / Remember / Remember / Remember
" ====================================================

" Format text to column width
" gq

" Paste from yank register
" "0p

" About vim registers: http://www.brianstorti.com/vim-registers/

" ====================================================
" External / External / External / External / External
" ====================================================

let g:neocomplete#enable_at_startup = 1

" Do not jump to first result automatically
cnoreabbrev Ack Ack!

" Syntastic recommended beginner settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:vimwiki_list = [
		\{'path': '~/vimwiki/luk.wiki'},
		\{'path': '~/vimwiki/software_projects.wiki'},
		\{'path': '~/vimwiki/hardware.wiki'},
		\{'path': '~/vimwiki/improvement.wiki'}
	\]

if has('cscope')
	set cscopetag cscopeverbose

	if has('quickfix')
		set cscopequickfix=s-,c-,d-,i-,t-,e-
	endif

	" Use start using current cscope db if set
	if $CSCOPE_DB != ""
		cs add $CSCOPE_DB
	endif

	cnoreabbrev csa cs add
	cnoreabbrev csf cs find
	cnoreabbrev csk cs kill
	cnoreabbrev csr cs reset
	cnoreabbrev css cs show
	cnoreabbrev csh cs help

	command -nargs=0 Cscope cs add $VIMSRC/src/cscope.out $VIMSRC/src

	nnoremap <leader>css yiw:cs find s
		\ <C-R>=expand("<cword>")<CR><CR>:bd<CR>:cwindow<CR>/<C-R>0<CR>
	nnoremap <leader>csg yiw:cs find g
		\ <C-R>=expand("<cword>")<CR><CR>:bd<CR>:cwindow<CR>/<C-R>0<CR>
	nnoremap <leader>csd yiw:cs find d
		\ <C-R>=expand("<cword>")<CR><CR>:bd<CR>:cwindow<CR>/<C-R>0<CR>
	nnoremap <leader>csc yiw:cs find c
		\ <C-R>=expand("<cword>")<CR><CR>:bd<CR>:cwindow<CR>/<C-R>0<CR>
endif
