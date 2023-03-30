v=4.2.3
add_package \
    -archive pyamg-$v.tar.gz -version $v \
    https://github.com/pyamg/pyamg/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -directory pyamg-$v

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/pyamg

pack_set -module-requirement scipy
pack_set -build-mod-req pybind11

pack_cmd "mkdir -p $(pack_get -prefix)/lib/python$pV/site-packages"

# Install commands that it should run (pyamg does not use numpy builds)
pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix)"
