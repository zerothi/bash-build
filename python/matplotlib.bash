# This module requires that libfreetype6-dev be installed as well as
# libpng(12)-dev

add_package \
    --package matplotlib \
    https://github.com/matplotlib/matplotlib/archive/v1.3.0.tar.gz

pack_set --directory matplotlib-$(pack_get --version)

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/site.py

pack_set --module-requirement numpy

pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py config"
pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py build"
pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

