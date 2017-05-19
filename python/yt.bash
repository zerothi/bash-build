v=3.3.5
add_package --directory yt-$v \
    --package yt --version $v \
    https://github.com/yt-project/yt/archive/yt-3.3.5.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/site.py

pack_set $(list --prefix ' --module-requirement ' numpy cython scipy matplotlib netcdf4py)

pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages"

pack_cmd "unset LDFLAGS && $(get_parent_exec) setup.py build ${pNumpyInstall%--fcom*}"

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"

