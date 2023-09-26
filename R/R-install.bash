msg_install \
    -message \
    "Installing the R-packages for $(pack_get -module-name $(get_parent))"
# This script will install all R packages
#exit 0

# Install packages in the base-R directory!
source R/R-basic.bash

function mk_R_install_script {
    local file=$(build_get -build-path)/.R.$(pack_get -package).$(pack_get -version)
    case $1 in
	new)
	    shift 1
        rm -f $file
	    [ $# -gt 0 ] && echo "$@" > $file
	    ;;
	get)
	    shift 1
	    printf '%s' "$file"
	    ;;
	*)
	    echo "$@" >> $file
	    ;;
    esac
}


archive_path=$(build_get -archive-path)
function add_R_package {
    local name=$1
    local v=$2
    shift 2
    local opt=
    case $@ in
	*-directory*)
	    noop
	    ;;
	*)
	    opt="-directory $name"
	    ;;
    esac
    add_package -package $name -version $v $opt $@ https://cran.r-project.org/src/contrib/${name}_$v.tar.gz
    pack_set -s $IS_MODULE
    local _prefix=$(pack_get -prefix)
    pack_set -install-query $_prefix/$(pack_get -package)
    pack_cmd "mkdir -p $_prefix"
    pack_cmd "$(get_parent_exec) CMD INSTALL -l $_prefix $archive_path/$(pack_get -archive)"
    pack_set -module-opt "-prepend-ENV R_LIBS_SITE=$_prefix"
}

add_R_package Matrix 1.4-0

add_R_package RcppEigen 0.3.3.9.1
pack_set -mod-req Matrix

add_R_package plyr 1.8.6

# tidyverse packages
#  ggplot2
#  dplyr
#  tidyr
#  readr
#  purrr
#  tibble
#  stringr
#  forcats

add_R_package tibble 3.1.6

add_R_package bench 1.1.2
pack_set -mod-req tibble

add_R_package tidyselect 1.1.2

add_R_package dplyr 1.0.8
pack_set -mod-req tibble
pack_set -mod-req tidyselect

add_R_package stringr 1.4.0

add_R_package forcats 0.5.1
pack_set -mod-req tibble

add_R_package purrr 0.3.4

add_R_package readr 2.1.2
pack_set -mod-req tibble

add_R_package tidyr 1.2.0
pack_set -mod-req purrr
pack_set -mod-req dplyr

add_R_package MASS 7.3-55

add_R_package ggplot2 3.3.5
pack_set -mod-req plyr
pack_set -mod-req tibble
pack_set -mod-req dplyr
pack_set -mod-req MASS


install_all -from Matrix



function add_R_package {
    local name=$1
    local v=$2
    shift 2
    local opt=
    case $@ in
	*-directory*)
	    noop
	    ;;
	*)
	    opt="-directory $name"
	    ;;
    esac
    add_package -package R.$name -version $v $opt $@ https://cran.r-project.org/src/contrib/${name}_$v.tar.gz
    pack_set -s $IS_MODULE
    local _prefix=$(pack_get -prefix)
    pack_set -install-query $_prefix/$name
    pack_cmd "mkdir -p $_prefix"
    pack_set -module-opt "-prepend-ENV R_LIBS_SITE=$_prefix"
}

archive_path=$(build_get -archive-path)

# Now we install R packages
# Note that all packages installed like this will have an "R-" prefix.
# This is to ensure no nameclashes with parent libraries
source R/udunits2.bash
source R/units.bash
source R/sp.bash
source R/rgeos.bash
source R/wk.bash
source R/s2.bash
source R/sf.bash
source R/rgdal.bash
source R/lwgeom.bash

install_all -from R.udunits2


unset archive_path
unset add_R_package
unset mk_R_install_script
