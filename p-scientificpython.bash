tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
add_package https://sourcesup.renater.fr/frs/download.php/4153/ScientificPython-2.9.2.tar.gz

pack_set -s $IS_MODULE

pack_set --alias $(lc $(pack_get --alias))
pack_set --alias $(lc $(pack_get --package))

pack_set --install-prefix $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$tmp/$(get_c)

pack_set --module-name $(pack_get --package)/$(pack_get --version)/$tmp/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/Scientific

pack_set --module-requirement openmpi \
    --module-requirement zlib \
    --module-requirement hdf5 \
    --module-requirement pnetcdf \
    --module-requirement netcdf \
    --module-requirement $(get_parent) \
    --module-requirement numpy

# Check for Intel MKL or not
tmp=$(get_c)
if [ "${tmp:0:5}" == "intel" ]; then
    pack_set --command "NETCDF_PREFIX='$(pack_get --install-prefix netcdf)' $(get_parent_exec) setup.py build" \
	--command-flag "--compiler=intelem"

elif [ "${tmp:0:3}" == "gnu" ]; then
    module load $(pack_get --module-name atlas)
    # Add requirments when creating the module
    pack_set --module-requirement atlas

    pack_set --command "NETCDF_PREFIX='$(pack_get --install-prefix netcdf)' $(get_parent_exec) setup.py build" \
	--command-flag "--compiler=unix"

fi

pack_set --command "NETCDF_PREFIX='$(pack_get --install-prefix netcdf)' $(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

pack_install
