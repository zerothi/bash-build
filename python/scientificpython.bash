tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
add_package https://sourcesup.renater.fr/frs/download.php/4153/ScientificPython-2.9.2.tar.gz

pack_set -s $IS_MODULE

pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$tmp/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/Scientific

pack_set --module-requirement netcdf-serial $(list --pack-module-reqs numpy)

# Check for Intel MKL or not
tmp_flags="$(list --LDFLAGS --Wlrpath netcdf-serial)"
tmp_compiler=""
if $(is_c intel) ; then
    tmp_compiler="intelem"

elif $(is_c gnu) ; then
    # Add requirements when creating the module
    pack_set --module-requirement atlas
    tmp_flags="$tmp_flags $(list --LDFLAGS --Wlrpath atlas)"
    tmp_compiler=unix
else
    doerr Scientificpython "Could not determine compiler..."
fi

pack_set --command "sed -i -e 's|^\(extra_compile_args[[:space:]]*=.*\)|\1\nextra_link_args = [\"$tmp_flags\"]|' setup.py"
pack_set --command "sed -i -e 's|\(extra_compile_args[[:space:]]*=[[:space:]]*extra_compile_args\)|\1,extra_link_args=extra_link_args|' setup.py"

pack_set --command "NETCDF_PREFIX='$(pack_get --install-prefix netcdf-serial)' $(get_parent_exec) setup.py build" \
    --command-flag "--compiler=$tmp_compiler"

pack_set --command "NETCDF_PREFIX='$(pack_get --install-prefix netcdf-serial)' $(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

