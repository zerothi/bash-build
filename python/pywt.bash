v=1.0.1
add_package \
    --package pywavelets \
    --archive pywt-$v.tar.gz \
    https://github.com/PyWavelets/pywt/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/pywt
pack_set --module-requirement numpy

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
	 "--prefix=$(pack_get --prefix $(get_parent))"
