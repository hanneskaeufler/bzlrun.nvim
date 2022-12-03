test: deps
	nvim --headless --noplugin -u scripts/minimal.vim -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.vim'}"

deps:
	wget -L -O plenary.zip https://github.com/nvim-lua/plenary.nvim/archive/4b7e520.zip
	mkdir -p deps/
	unzip -d deps/ plenary.zip
	rm plenary.zip
	mv deps/plenary.nvim-* deps/plenary
