add_package -package eigen \
	    --archive eigen-3.2.8.tar.bz2 \
	    http://bitbucket.org/eigen/eigen/get/3.2.8.tar.bz2

pack_set --directory 'eigen-*'

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --prefix)/include/Eigen/Dense

pack_cmd "module load cmake"

pack_cmd "cmake ../ -DCMAKE_INSTALL_PREFIX=$(pack_get --prefix)" \
	 "-DEIGEN_INCLUDE_INSTALL_DIR=$(pack_get --prefix)/include"
pack_cmd "make install"

pack_cmd "module unload cmake"


