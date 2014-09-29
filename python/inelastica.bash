[ "x${pV:0:1}" == "x3" ] && return 0

add_package http://downloads.sourceforge.net/project/inelastica/1.1/Inelastica-1.1.tar.gz

pack_set -s $IS_MODULE

pack_set --module-opt "--lua-family inelastica"

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/Inelastica

pack_set --module-requirement netcdf-serial \
    --module-requirement scientificpython

pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py config"
pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py build"
pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix)"


