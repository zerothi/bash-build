v=1.0.9
add_package --version $v --alias py-netcdf --package py-netcdf \
	--archive netcdf4-python-${v}rel.tar.gz \
	https://github.com/Unidata/netcdf4-python/archive/v${v}rel.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/nc3tonc4

pack_set --module-requirement cython \
    --module-requirement netcdf-serial \
    --module-requirement hdf5-serial \
    --module-requirement numpy

# Check for Intel MKL or not
tmp_flags="$(list --LDFLAGS --Wlrpath netcdf-serial hdf5-serial)"
tmp_compiler=""
if $(is_c intel) ; then
    tmp_compiler="intelem"

elif $(is_c gnu) ; then
    tmp_compiler=unix

else
    doerr netCDF4 "Could not determine compiler..."
fi

file=setup.cfg
pack_set --command "echo '#' > $file"

pack_set --command "sed -i '1 a\
[options]\n\
use_ncconfig = True\n\
[directories]\n\
netCDF4_dir = $(pack_get --install-prefix netcdf-serial)\n\
HDF5_dir = $(pack_get --install-prefix hdf5-serial)\n\
' $file"

pack_set --command "CFLAGS='$CFLAGS $tmp_flags' $(get_parent_exec) setup.py build"

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"
