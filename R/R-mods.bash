# placeholder for modules

rm_latest R$rV.numerics
tmp=
for i in Rcpp Matrix RcppEigen plyr bench tidyselect dplyr \
	      stringr forcats purrr readr tidyr MASS ggplot2 ; do
    if [[ $(pack_installed $i) -eq $_I_INSTALLED ]]; then
        tmp="$tmp $i"
    fi
done
create_module \
    -n R$rV.numerics \
    -W "R script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M R$rV.numerics \
    -P "/directory/should/not/exist" \
    $(list --prefix '-RL ' $tmp)

