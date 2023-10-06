v=4.2.2
add_package -directory yt-yt-$v \
    -package yt -version $v \
    https://github.com/yt-project/yt/archive/yt-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/yt

pack_set -build-mod-req cython
pack_set $(list -prefix ' -module-requirement ' numpy scipy matplotlib sympy netcdf4py)

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

pack_cmd "unset LDFLAGS && $_pip_cmd ewah-bool-utils --prefix=$(pack_get -prefix)"
pack_cmd "unset LDFLAGS && $_pip_cmd . --prefix=$(pack_get -prefix)"

