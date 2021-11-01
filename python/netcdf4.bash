v=1.5.7
add_package \
    -version $v -package netcdf4py \
    -archive netcdf4-python-${v}rel.tar.gz \
    https://github.com/Unidata/netcdf4-python/archive/v${v}rel.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -prefix)/bin/nc3tonc4

pack_set -build-mod-req cython
pack_set -module-requirement netcdf-serial \
    -module-requirement cftime \
    -module-requirement numpy

tmp_flags="$(list -LD-rp netcdf-serial hdf5-serial)"

file=setup.cfg
pack_cmd "echo '#' > $file"

pack_cmd "sed -i '1 a\
[options]\n\
use_ncconfig = True\n\
use_cython = True\n\
[directories]\n\
netCDF4_dir = $(pack_get -prefix netcdf-serial)\n\
HDF5_dir = $(pack_get -prefix hdf5-serial)\n\
' $file"

pack_cmd "mkdir -p $(pack_get -prefix)/lib/python$pV/site-packages"
pack_cmd "CFLAGS='$pCFLAGS $tmp_flags' $(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get -prefix)"
