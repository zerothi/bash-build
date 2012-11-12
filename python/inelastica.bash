tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
add_package http://downloads.sourceforge.net/project/inelastica/1.1/Inelastica-1.1.tar.gz

pack_set -s $IS_MODULE

pack_set --install-prefix $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$tmp/$(get_c)

pack_set --module-name $(pack_get --package)/$(pack_get --version)/$tmp/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/Inelastica

pack_set --module-requirement $(get_parent) \
    --module-requirement netcdf-serial \
    --module-requirement numpy \
    --module-requirement scientificpython

# Check for Intel MKL or not
tmp=$(get_c)
if [ "${tmp:0:5}" == "intel" ]; then
    pack_set --command "$(get_parent_exec) setup.py config" \
	--command-flag "--fcompiler=intelem" \
	--command-flag "--compiler=intelem"

elif [ "${tmp:0:3}" == "gnu" ]; then
    pack_set --command "$(get_parent_exec) setup.py config" \
	--command-flag "--fcompiler=gnu95" \
	--command-flag "--compiler=unix"

fi

pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"


pack_install
