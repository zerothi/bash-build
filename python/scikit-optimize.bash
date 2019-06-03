v=0.6
add_package \
    -archive scikit-optimize-$v.tar.gz \
    -directory scikit.optimize-$v \
    https://github.com/scikit-optimize/scikit-optimize/archive/v$v.tar.gz

pack_set -s $IS_MODULE

pack_set -module-requirement numpy
pack_set -install-query $(pack_get -prefix $(get_parent))/lib/python$pV/site-packages

pack_cmd "$(get_parent_exec) setup.py build ${pNumpyInstallC}"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get -prefix $(get_parent))"
