v=3.3.7
add_package -package eigen \
	    -archive eigen-$v.tar.bz2 \
            https://gitlab.com/libeigen/eigen/-/archive/$v/eigen-$v.tar.bz2

pack_set -directory 'eigen-*'

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR
pack_set -build-mod-req build-tools

pack_set -install-query $(pack_get -prefix)/include/Eigen/Dense

pack_cmd "cmake ../ -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"

pack_cmd "make install"

