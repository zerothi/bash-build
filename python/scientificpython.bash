
add_package https://sourcesup.renater.fr/frs/download.php/4570/ScientificPython-2.9.4.tar.gz
#add_package https://sourcesup.renater.fr/frs/download.php/4425/ScientificPython-2.9.3.tar.gz

pack_set -s $IS_MODULE

[[ "x${pV:0:1}" == "x3" ]] && pack_set --host-reject $(get_hostname)

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/Scientific

pack_set --module-requirement netcdf-serial \
    --module-requirement numpy

# Check for Intel MKL or not
tmp_flags="$(list --LD-rp netcdf-serial)"
tmp_compiler=""
if $(is_c intel) ; then
    echo "continue" > /dev/null

elif $(is_c gnu) ; then

    for la in $(pack_choice linalg) ; do
	if [[ $(pack_installed $la) -eq 1 ]]; then
	    pack_set --module-requirement $la
	    tmp_flags="$tmp_flags $(list --LD-rp $la)"
	    break
	fi
    done

else
    doerr Scientificpython "Could not determine compiler..."
fi

pack_cmd "sed -i -e 's|^\(extra_compile_args[[:space:]]*=.*\)|\1\nextra_link_args = [\"$tmp_flags\"]|' setup.py"
pack_cmd "sed -i -e 's|\(extra_compile_args[[:space:]]*=[[:space:]]*extra_compile_args\)|\1,extra_link_args=extra_link_args|' setup.py"

pack_cmd "NETCDF_PREFIX='$(pack_get --prefix netcdf-serial)' $(get_parent_exec) setup.py build ${pNumpyInstall%--fcom*}"

pack_cmd "NETCDF_PREFIX='$(pack_get --prefix netcdf-serial)' $(get_parent_exec) setup.py install" \
      "--prefix=$(pack_get --prefix)"

