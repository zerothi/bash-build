v=0.3
add_package \
    --archive scikit-optimization-$v.tar.gz \
    --directory scikits.optimization-$v \
    https://pypi.python.org/packages/source/s/scikits.optimization/scikits.optimization-$v.tar.gz

pack_set --module-requirement numpy
pack_set --install-query $(pack_get --install-prefix $(get_parent))/lib/python$pV/site-packages

pack_set --command "$(get_parent_exec) setup.py build"

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix $(get_parent))"