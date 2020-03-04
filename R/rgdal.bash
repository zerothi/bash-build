add_R_package rgdal 1.4-8
pack_set -mod-req R-udunits2 -mod-req gdal -mod-req R-sp

tmp="'$archive_path/$(pack_get -archive)', '$(pack_get -prefix)'"
tmp="$tmp, repos=NULL, type='source'"
tmp_f="-with-gdal-config=$(pack_get -prefix gdal)/bin/gdal-config"
tmp="$tmp, configure.args='$tmp_f'"

pack_cmd "Rscript -e \"quit(install.packages($tmp))\""
