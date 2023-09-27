add_R_package wk 0.8.0

tmp="'$archive_path/$(pack_get -archive)', '$(pack_get -prefix)'"
tmp="$tmp, repos=NULL, type='source'"

pack_cmd "Rscript -e \"install.packages($tmp)\""
