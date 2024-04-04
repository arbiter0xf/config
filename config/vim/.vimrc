" Line numbers
set number

" 80 character limit marker
set colorcolumn=80

" Highlight current line
set cursorline

let mapleader = ","

nmap <F7> :tabp<CR>
nmap <F8> :tabn<CR>

nmap <leader>it :set noexpandtab softtabstop=0 tabstop=8 shiftwidth=8<CR>
nmap <leader>is :set tabstop=8 softtabstop=0 expandtab
	\ shiftwidth=4 smarttab<CR>

