v=1.8.13
add_package --build generic \
	    --version $v --package doxygen \
	    --archive doxygen-Release_${v//./_}.tar.gz \
	    https://github.com/doxygen/doxygen/archive/Release_${v//./_}.tar.gz

if $(is_host ntch zero) ; then
    echo "Compiling" > /dev/null
else
    pack_set --host-reject $(get_hostname)
fi

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --prefix)/bin/doxygen

pack_cmd "module load $(list ++cmake)"

pack_cmd "cmake -G 'Unix Makefiles'" \
	 "-D use-libclang=ON" \
	 "-D CMAKE_INSTALL_PREFIX=$(pack_get --prefix) ../"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
