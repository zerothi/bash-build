# Package requires:
#  libffi-dev
v=0.8.1
add_package https://pypi.python.org/packages/source/c/cffi/cffi-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages

pack_set --module-requirement cython

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

