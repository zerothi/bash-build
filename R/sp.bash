add_R_package sp 2.0-0

tmp="'$archive_path/$(pack_get -archive)', '$(pack_get -prefix)'"
tmp="$tmp, repos=NULL, type='source'"

pack_cmd "Rscript -e \"install.packages($tmp)\""
