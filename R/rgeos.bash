add_R_package rgeos 0.5-2
pack_set -mod-req R.udunits2 -mod-req geos -mod-req R.sp

tmp="'$archive_path/$(pack_get -archive)', '$(pack_get -prefix)'"
tmp="$tmp, repos=NULL, type='source'"
tmp="$tmp, configure.args='--with-geos-config=$(pack_get -prefix geos)/bin/geos-config'"
tmp="$tmp, configure.vars='PKG_LIBS=\'$(list -LD-rp geos)\''"

pack_cmd "Rscript -e \"install.packages($tmp)\""
