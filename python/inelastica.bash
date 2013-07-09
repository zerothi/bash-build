[ "x${pV:0:1}" == "x3" ] && return 0

add_package http://downloads.sourceforge.net/project/inelastica/1.1/Inelastica-1.1.tar.gz

pack_set -s $IS_MODULE

pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$IpV/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/Inelastica

pack_set --module-requirement netcdf-serial \
    --module-requirement scientificpython

# Check for Intel MKL or not
if $(is_c intel) ; then
    tmp="--fcompiler=intelem --compiler=intelem"
elif $(is_c gnu) ; then
    tmp="--fcompiler=gnu95 --compiler=unix"
fi

pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py config" \
    --command-flag "$tmp"
pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py build" \
    --command-flag "$tmp"
pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"


