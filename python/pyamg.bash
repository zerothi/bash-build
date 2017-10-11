v=3.3.0
add_package \
    --archive pyamg-$v.tar.gz --version $v \
    https://github.com/pyamg/pyamg/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --directory pyamg-$v

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/site.py

pack_set --module-requirement scipy

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages"

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py build $pNumpyInstallC"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"
