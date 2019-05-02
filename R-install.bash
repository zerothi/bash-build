msg_install \
    -message \
    "Installing the R-packages for $(pack_get -module-name $(get_parent))"
# This script will install all R packages
#exit 0

# Install packages in the base-R directory!
source R/R-basic.bash

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

add_R_package Matrix 1.2-17

add_R_package RcppEigen 0.3.3.5.0
pack_set -mod-req Matrix

add_R_package RcppEigen 0.3.3.5.0
pack_set -mod-req Matrix

add_R_package plyr 1.8.4

# tidyverse packages
#  ggplot2
#  dplyr
#  tidyr
#  readr
#  purrr
#  tibble
#  stringr
#  forcats

add_R_package tibble 2.1.1

add_R_package bench 1.0.2
pack_set -mod-req tibble

add_R_package tidyselect 0.2.5

add_R_package dplyr 0.8.0.1
pack_set -mod-req tibble
pack_set -mod-req tidyselect

add_R_package stringr 1.4.0

add_R_package forcats 0.4.0
pack_set -mod-req tibble

add_R_package purrr 0.3.2

add_R_package readr 1.3.1
pack_set -mod-req tibble

add_R_package tidyr 0.8.3
pack_set -mod-req purrr
pack_set -mod-req dplyr

add_R_package MASS 7.3-51.4

add_R_package ggplot2 3.1.1
pack_set -mod-req plyr
pack_set -mod-req tibble
pack_set -mod-req dplyr
pack_set -mod-req MASS


install_all -from Matrix

unset add_R_package


