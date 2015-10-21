for v in 3.9.1 ; do

add_package --archive ase-$v.tar.gz \
    https://gitlab.com/ase/ase/repository/archive.tar.gz?ref=$v

pack_set --directory ase-$v-*

pack_set -s $IS_MODULE

pack_set --module-opt "--lua-family ase"

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/$(pack_get --alias)

pack_set --module-requirement scipy

pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"

done
