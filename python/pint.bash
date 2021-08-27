v=0.13
add_package \
    --package pint \
    --archive pint-$v.zip \
    --directory Pint-$v \
    https://pypi.python.org/packages/source/P/Pint/Pint-$v.zip

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/

pack_cmd "$(get_parent_exec) setup.py build"

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"
