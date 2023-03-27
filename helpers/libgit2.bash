v=1.6.3
add_package -build generic -archive libgit2-$v.tar.gz \
	    https://github.com/libgit2/libgit2/archive/v$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR
pack_set -build-mod-req build-tools
pack_set -mod-req openssl
pack_set -mod-req libssh2

pack_set -install-query $(pack_get -LD)/libgit2.so

# Install commands that it should run
pack_cmd "cmake .. -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"
pack_cmd "cmake --build . --target install"
