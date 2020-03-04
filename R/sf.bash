add_R_package sf 0.8-1
pack_set -mod-req R-rgeos -mod-req R-units

tmp="'$archive_path/$(pack_get -archive)', '$(pack_get -prefix)'"
tmp="$tmp, repos=NULL, type='source'"

pack_cmd "Rscript -e \"quit(install.packages($tmp))\""
