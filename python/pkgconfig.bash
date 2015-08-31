v=1.1.0
add_package --archive pkgconfig-$v.tar.gz \
    https://github.com/matze/pkgconfig/archive/v$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/pkgconfig-${v}-py$pV.egg

pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages"

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix $(get_parent))"

