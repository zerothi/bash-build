add_R_package lwgeom 0.2-5
pack_set -mod-req R.udunits2 -mod-req geos -mod-req R.sf

tmp="'$archive_path/$(pack_get -archive)', '$(pack_get -prefix)'"
tmp="$tmp, repos=NULL, type='source'"
tmp_f="--with-geos-config=$(pack_get -prefix geos)/bin/geos-config"
tmp_f="$tmp_f --with-proj-include=$(pack_get -prefix proj)/include"
tmp_f="$tmp_f --with-proj-lib=$(pack_get -prefix proj)/lib"
tmp="$tmp, configure.args='$tmp_f'"
tmp="$tmp, configure.vars='LIBS=\'$(list -LD-rp hdf5-serial netcdf-serial sqlite proj geos)\' PKG_LIBS=\'$(list -LD-rp hdf5-serial netcdf-serial sqlite proj geos)\''"

pack_cmd "Rscript -e \"install.packages($tmp)\""
