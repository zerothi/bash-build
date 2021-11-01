v=8.0.2
add_package -archive qhull-$v.tar.gz \
	    https://github.com/qhull/qhull/archive/v$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -install-query $(pack_get -LD)/libqhull.so
pack_set -lib -lqhull_r

pack_cmd cmake -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix) ..
pack_cmd "make $(get_make_parallel) all libqhull qhull qhullp"
pack_cmd "make install"
pack_cmd 'for f in libqhull_p* libqhull.* libqhullstatic* ; do cp $f $(pack_get -LD)/ ; done'
