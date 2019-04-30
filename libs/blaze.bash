add_package https://bitbucket.org/blaze-lib/blaze/downloads/blaze-3.5.tar.gz

pack_set -s $IS_MODULE -s $BUILD_TOOLS

pack_set --install-query $(pack_get --prefix)/include/blaze

pack_cmd "mkdir -p $(pack_get -prefix)/include"
pack_cmd "cp -r ./blaze $(pack_get -prefix)/include"



