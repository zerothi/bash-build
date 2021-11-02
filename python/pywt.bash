v=1.1.1
add_package \
    -package pywavelets \
    -archive pywt-$v.tar.gz \
    https://github.com/PyWavelets/pywt/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -module-requirement numpy
# Not working on py2
[[ ${pV:0:1} -eq 2 ]] && pack_set -host-reject $(get_hostname)

pack_set -install-query $(pack_get -prefix)/lib/python$pV/site-packages/PyWavelets-$v*

pack_cmd "mkdir -p $(pack_get -prefix)/lib/python$pV/site-packages/"

pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix)"
