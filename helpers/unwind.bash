add_package --build generic --package unwind \
	    http://download.savannah.nongnu.org/releases/libunwind/libunwind-1.3.0.tar.gz

pack_set -s $BUILD_DIR -s $IS_MODULE

pack_set --module-requirement build-tools

pack_set --install-query $(pack_get --prefix)/lib/libunwind.so

# Install commands that it should run
pack_cmd "../configure" \
	 "--prefix=$(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
