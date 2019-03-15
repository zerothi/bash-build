add_package --package sympack \
	    https://github.com/symPACK/symPACK/releases/download/v1.1/symPACK-1.1.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR -s $BUILD_TOOLS

pack_set --install-query $(pack_get --LD)/libsymPACK.a

# Install commands that it should run
pack_cmd "METIS_DIR=$(pack_get --prefix metis)" \
	 "PARMETIS_DIR=$(pack_get --prefix parmetis)" \
	 "SCOTCH_DIR=$(pack_get --prefix scotch)" \
	 " cmake -DCMAKE_INSTALL_PREFIX=$(pack_get --prefix)" \
	 "-DENABLE_METIS=ON -DENABLE_PARMETIS=ON -DENABLE_SCOTCH=ON" \
	 ".."

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
