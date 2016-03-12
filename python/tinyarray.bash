[ "x${pV:0:1}" == "x3" ] && return 0

add_package https://pypi.python.org/packages/source/t/tinyarray/tinyarray-1.1.0.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/tinyarray.so

pack_set --module-requirement numpy \
    --module-requirement cython

pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"
