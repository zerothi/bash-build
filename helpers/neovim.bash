v=0.8.3
add_package -build generic -archive neovim-$v.tar.gz \
	https://github.com/neovim/neovim/archive/refs/tags/v$v.tar.gz

pack_set -s $IS_MODULE

pack_set -build-mod-req build-tools

pack_set -install-query $(pack_get -prefix)/bin/nvim

pack_cmd "make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_EXTRA_FLAGS='-DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)'"
pack_cmd "make install"
