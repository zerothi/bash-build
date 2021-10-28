v=8.0.2
add_package -archive qhull-$v.tar.gz \
	    https://github.com/qhull/qhull/archive/v$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -install-query $(pack_get -LD)/libqhull_r.so
pack_set -lib -lqhull

pack_cmd cmake -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix) \
	 ..

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
