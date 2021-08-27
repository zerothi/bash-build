v=3.6.0
add_package -directory yt-yt-$v \
    -package yt -version $v \
    https://github.com/yt-project/yt/archive/yt-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/site.py

pack_set $(list -prefix ' -module-requirement ' numpy cython scipy matplotlib sympy netcdf4py)

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

pack_cmd "unset LDFLAGS && $(get_parent_exec) setup.py build"

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get -prefix)"

