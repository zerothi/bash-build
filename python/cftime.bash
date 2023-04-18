v=1.6.2
add_package \
    --version $v --package cftime \
    --archive cftime-${v}rel.tar.gz \
    https://github.com/Unidata/cftime/archive/v${v}rel.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/cftime

pack_set -build-mod-req cython \
    -module-requirement numpy

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages"
pack_cmd "CFLAGS='$pCFLAGS' $_pip_cmd . --prefix=$(pack_get --prefix)"
