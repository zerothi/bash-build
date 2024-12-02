add_package -package nvptx-tools --version 0 \
	    -directory nvptx-tools \
	    https://github.com/SourceryTools/nvptx-tools.git

pack_set -s $IS_MODULE
pack_set -build-module-requirement build-tools

pack_set -install-query $(pack_get -prefix)/bin/nvptx-none-run

pack_cmd "./configure --prefix=$(pack_get -prefix)"

pack_cmd "make"
pack_cmd "make install"
