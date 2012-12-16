tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
add_package http://www.student.dtu.dk/~nicpa/packages/Inelastica-151.tar.gz


pack_set -s $IS_MODULE

pack_set --alias Inelastica-DEV
pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$tmp/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/Inelastica

pack_set --module-requirement netcdf-serial \
    $(list --pack-module-reqs scientificpython)

# Check for Intel MKL or not
if $(is_c intel) ; then
    pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py config" \
	--command-flag "--fcompiler=intelem" \
	--command-flag "--compiler=intelem"

elif $(is_c gnu) ; then
    pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py config" \
	--command-flag "--fcompiler=gnu95" \
	--command-flag "--compiler=unix"

fi

pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py build"
pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

pack_install
