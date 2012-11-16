tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
add_package https://sourcesup.renater.fr/frs/download.php/4153/ScientificPython-2.9.2.tar.gz

pack_set -s $IS_MODULE

pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$tmp/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/Scientific

pack_set --module-requirement netcdf-serial \
    --module-requirement $(get_parent) \
    $(list --pack-module-reqs numpy)

# Check for Intel MKL or not
tmp=$(get_c)
tmp_cflags=""
tmp_compiler=""
if [ "${tmp:0:5}" == "intel" ]; then
    tmp_compiler="intelem"

elif [ "${tmp:0:3}" == "gnu" ]; then
    # Add requirements when creating the module
    pack_set --module-requirement atlas
    tmp_cflags="$(list --LDFLAGS --Wlrpath netcdf-serial atlas)"
    tmp_compiler=unix
fi

pack_set --command "NETCDF_PREFIX='$(pack_get --install-prefix netcdf-serial)' CFLAGS='$CFLAGS $tmp_cflags' $(get_parent_exec) setup.py build" \
    --command-flag "--compiler=$tmp_compiler"

pack_set --command "NETCDF_PREFIX='$(pack_get --install-prefix netcdf-serial)' CFLAGS='$CFLAGS $tmp_cflags' $(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

pack_install
