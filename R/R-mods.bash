# placeholder for modules
case $_mod_format in
    $_mod_format_ENVMOD)
	function rm_latest {
	    local latest_mod=$(build_get -module-path)
	    rm -rf $latest_mod/$1
	}
	;;
    $_mod_format_LMOD)
	function rm_latest {
	    local latest_mod=$(build_get -module-path)
	    rm -rf $latest_mod/$1.lua
	}
	;;
esac


rm_latest R$rV.numerics
tmp=
for i in Rcpp Matrix RcppEigen plyr bench tidyselect dplyr \
	      stringr forcats purrr readr tidyr MASS ggplot2 ; do
    if [[ $(pack_installed $i) -eq $_I_INSTALLED ]]; then
        tmp="$tmp $i"
    fi
done
create_module \
    -n R.numerics \
    -W "Numerical R script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M R.numerics \
    -P "/directory/should/not/exist" \
    $(list -prefix '-RL ' $tmp)

unset rm_latest
