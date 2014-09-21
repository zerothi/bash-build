[ "x${pV:0:1}" == "x3" ] && return 0
for v in 3.6.0.2515 3.8.1.3440 ; do
add_package \
    --package ase \
    --version $v \
    https://wiki.fysik.dtu.dk/ase-files/python-ase-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --module-opt "--lua-family ase"

pack_set --host-reject ntch

pack_set --install-query $(pack_get --library-path)/python$pV/site-packages/$(pack_get --alias)

pack_set --module-requirement scipy

pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix)"

done
