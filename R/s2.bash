add_R_package s2 1.1.4

pack_set -mod-req R.wk

tmp="'$archive_path/$(pack_get -archive)', '$(pack_get -prefix)'"
tmp="$tmp, repos=NULL, type='source'"

pack_cmd "Rscript -e \"install.packages($tmp)\""
