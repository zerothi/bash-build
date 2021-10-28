add_package https://bitbucket.org/blaze-lib/blaze/downloads/blaze-3.8.tar.gz

pack_set -s $IS_MODULE

pack_set -build-mod-req build-tools

pack_set --install-query $(pack_get --prefix)/include/blaze

pack_cmd "mkdir -p $(pack_get -prefix)/include"
pack_cmd "cp -r ./blaze $(pack_get -prefix)/include"



