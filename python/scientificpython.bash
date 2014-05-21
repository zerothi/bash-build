
add_package https://sourcesup.renater.fr/frs/download.php/4425/ScientificPython-2.9.3.tar.gz
#https://sourcesup.renater.fr/frs/download.php/4153/ScientificPython-2.9.2.tar.gz

pack_set -s $IS_MODULE

[ "x${pV:0:1}" == "x3" ] && pack_set --host-reject $(get_hostname)

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/Scientific

pack_set --module-requirement netcdf-serial \
    --module-requirement numpy

# Check for Intel MKL or not
tmp_flags="$(list --LDFLAGS --Wlrpath netcdf-serial)"
tmp_compiler=""
if $(is_c intel) ; then
    echo "continue" > /dev/null

elif $(is_c gnu) ; then
    # Add requirements when creating the module
    if [ $(pack_installed atlas) -eq 1 ] ; then
	pack_set --module-requirement atlas
	tmp_flags="$tmp_flags $(list --LDFLAGS --Wlrpath atlas)"
    else
	pack_set --module-requirement blas
	pack_set --module-requirement lapack
	tmp_flags="$tmp_flags $(list --LDFLAGS --Wlrpath blas lapack)"
    fi
else
    doerr Scientificpython "Could not determine compiler..."
fi

pack_set --command "sed -i -e 's|^\(extra_compile_args[[:space:]]*=.*\)|\1\nextra_link_args = [\"$tmp_flags\"]|' setup.py"
pack_set --command "sed -i -e 's|\(extra_compile_args[[:space:]]*=[[:space:]]*extra_compile_args\)|\1,extra_link_args=extra_link_args|' setup.py"

pack_set --command "NETCDF_PREFIX='$(pack_get --install-prefix netcdf-serial)' $(get_parent_exec) setup.py build ${pNumpyInstall%--fcom*}"

pack_set --command "NETCDF_PREFIX='$(pack_get --install-prefix netcdf-serial)' $(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

