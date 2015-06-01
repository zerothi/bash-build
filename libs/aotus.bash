add_package --package aotus \
    --archive apesteam-aotus-dev.tar.bz2 \
    --directory apesteam-aotus* \
    https://bitbucket.org/apesteam/aotus/get/tip.tar.bz2

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libaotus.a

pack_set --command "./waf configure build install --prefix=$(pack_get --prefix)"
