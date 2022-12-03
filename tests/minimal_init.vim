set rtp+=.
set rtp+=deps/plenary
runtime deps/plenary/plugin/plenary.vim
runtime plugin/bzlrun.lua

nnoremap ,,x :luafile %<CR>
