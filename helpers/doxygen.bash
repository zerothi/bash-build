v=1.8.15
add_package --build generic \
	    --version $v --package doxygen \
	    --archive doxygen-Release_${v//./_}.tar.gz \
	    https://github.com/doxygen/doxygen/archive/Release_${v//./_}.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR -s $BUILD_TOOLS

pack_set --install-query $(pack_get --prefix)/bin/doxygen

pack_cmd "cmake -G 'Unix Makefiles'" \
	 "-D use-libclang=ON" \
	 "-D CMAKE_INSTALL_PREFIX=$(pack_get --prefix) ../"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
