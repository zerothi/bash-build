add_R_package units 0.6-7
pack_set -mod-req udunits

tmp="'$archive_path/$(pack_get -archive)', '$(pack_get -prefix)'"
tmp="$tmp, repos=NULL, type='source'"
tmp="$tmp, configure.args='--with-udunits2-include=$(pack_get -prefix udunits)/include'"
tmp="$tmp, configure.vars='LIBS=\'$(list -LD-rp udunits) $(pack_get -lib udunits)\''"

pack_cmd "Rscript -e \"install.packages($tmp)\""
