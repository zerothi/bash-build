v=0.3
add_package \
    --archive scikit-optimization-$v.tar.gz \
    --directory scikits.optimization-$v \
    https://pypi.python.org/packages/source/s/scikits.optimization/scikits.optimization-$v.tar.gz

pack_set --module-requirement numpy
pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages

pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix $(get_parent))"
