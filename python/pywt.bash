v=1.1.1
add_package \
    --package pywavelets \
    --archive pywt-$v.tar.gz \
    https://github.com/PyWavelets/pywt/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --module-requirement numpy

pack_set --install-query $(pack_get --prefix)/lib/python$pV/site-packages/PyWavelets-$v*

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages/"

pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install --prefix=$(pack_get --prefix)"
