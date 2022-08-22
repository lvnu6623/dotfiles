"vimrc"
set signcolumn=yes
set nobackup
set nowritebackup
set cmdheight=2
set updatetime=300

"colorscheme"
syntax enable
set background=dark
colorscheme iceberg

"background transparent"
highlight Normal ctermbg=NONE guibg=NONE
highlight NonText ctermbg=NONE guibg=NONE
highlight LineNr ctermbg=NONE guibg=NONE
highlight Folded ctermbg=NONE guibg=NONE
highlight EndOfBuffer ctermbg=NONE guibg=NONE
highlight signcolumn ctermbg=NONE guibg=NONE

"lightline"
let g:lightline = {
      \ 'colorscheme': 'iceberg',
      \ }

"coc.nvim"
set hidden
let g:coc_global_extensions = ['coc-json', 'coc-git', 'coc-css', 'coc-docker', 'coc-eslint', 
      \ 'coc-go', 'coc-html', 'coc-python', 'coc-pyright', 'coc-tsserver', 'coc-explorer']

"nvim language fix"
language en_US.UTF-8

