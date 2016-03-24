add_package https://bitbucket.org/blaze-lib/blaze/downloads/blaze-2.6.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --prefix)/lib/libblaze.a


