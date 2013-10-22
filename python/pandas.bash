v=0.12.0
add_package https://pypi.python.org/packages/source/p/pandas/pandas-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/site.py

pack_set $(list --prefix ' --module-requirement ' cython numpy numexpr[2] scipy pytables matplotlib bottleneck pytz)

pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/python$pV/site-packages"

pack_set --command "$(get_parent_exec) setup.py build"

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

