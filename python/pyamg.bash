[ "x${pV:0:1}" == "x3" ] && return 0

v=2.1.0
add_package \
    --package pyamg --version $v \
    https://github.com/pyamg/pyamg/releases/download/v$v/official_pyamg_source-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --directory pyamg-$v

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/pyamg

pack_set --module-requirement scipy

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py build $pNumpyInstall"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"
