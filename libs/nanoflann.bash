v=1.3.1
add_package -archive nanoflann-$v.tar.gz https://github.com/jlblancoc/nanoflann/archive/v$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -install-query $(pack_get -prefix)/include/nanoflann.hpp
pack_set -mod-req eigen

pack_cmd "cmake ../ -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make test > nanoflann.test 2>&1"
pack_cmd "make install"
pack_store nanoflann.test
