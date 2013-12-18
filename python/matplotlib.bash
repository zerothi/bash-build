# This module requires that libfreetype6-dev be installed as well as
# libpng(12)-dev

add_package \
    --archive matplotlib-1.3.1.tar.gz \
    https://github.com/matplotlib/matplotlib/archive/1.3.1.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/site.py

pack_set --module-requirement numpy

pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py config"
pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py build"
# Apparently matplotlib sucks at creating directories...
pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/python$pV/site-packages/"
pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

