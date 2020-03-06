add_R_package sf 0.8-1
pack_set -mod-req R.rgeos -mod-req R.units -mod-req gdal -mod-req geos

tmp="'$archive_path/$(pack_get -archive)', '$(pack_get -prefix)'"
tmp="$tmp, repos=NULL, type='source'"
tmp_f="--with-geos-config=$(pack_get -prefix geos)/bin/geos-config"
tmp_f="$tmp_f --with-gdal-config=$(pack_get -prefix gdal)/bin/gdal-config"
tmp_f="$tmp_f --with-proj-include=$(pack_get -prefix proj)/include"
tmp_f="$tmp_f --with-proj-lib=$(pack_get -prefix proj)/lib"
tmp="$tmp, configure.args='$tmp_f'"
tmp="$tmp, configure.vars='LIBS=\'$(list -LD-rp hdf5-serial netcdf-serial sqlite proj geos gdal)\' PKG_LIBS=\'$(list -LD-rp hdf5-serial netcdf-serial sqlite proj geos gdal)\''"
#tmp="$tmp, configure.vars='LDFLAGS=\'$(list -LD-rp hdf5-serial netcdf-serial sqlite proj gdal)\' LIBS=\'$(list -LD-rp hdf5-serial netcdf-serial sqlite proj gdal)\' PKG_LIBS=\'$(list -LD-rp hdf5-serial netcdf-serial sqlite proj gdal)\''"

pack_cmd "Rscript -e \"install.packages($tmp)\""
