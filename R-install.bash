msg_install \
    --message \
    "Installing the R-packages for $(pack_get --module-name $(get_parent))"
# This script will install all R packages
#exit 0

rMod="$(pack_get --mod-req-module $(get_parent)) $(get_parent)"
rModNames="$(list --loop-cmd "pack_get --module-name" $pMod)"
module load $rModNames
IrV=$(pack_get --version $(get_parent))
rV=${IrV:0:3}
module unload $rModNames

# Save the default build index
def_idx=$(build_get --default-build)

# Ensure get_c is defined
# R packages are *not* installed using the typical
#  ./configure ... things
# Basically the packages are installed from their tar.gz files
# using the direct command:
#  R CMD INSTALL --library=<prefix>
# which results in a file structure:
#   <prefix>/<R-package>
source $(build_get --source)
new_build --name _internal-R$IrV \
	  --module-path $(build_get --module-path[$def_idx])-R/$IrV \
	  --source $(build_get --source) \
	  $(list --prefix "--default-module " $rMod) \
	  --installation-path $(dirname $(pack_get --prefix $(get_parent)))/packages \
	  --build-module-path "--package --version" \
	  --build-installation-path "$IrV --package --version" \
	  --build-path $(build_get --build-path[$def_idx])/R-$IrV

build_set --default-setting[_internal-R$IrV] $INSTALL_FROM_ARCHIVE \
	  --default-setting[_internal-R$IrV] $PRELOAD_MODULE

# Change to the new build default
build_set --default-build _internal-R$IrV

build_set --default-choice[_internal-R$IrV] linalg openblas blis atlas blas

# Install packages in the base-R directory!
source R/R-basic.bash

archive_path=$(build_get -archive-path)
function add_R_package {
    local name=$1
    local v=$2
    shift 2
    add_package $@ https://cran.r-project.org/src/contrib/${name}_$v.tar.gz
    pack_set -s $IS_MODULE
    local _prefix=$(pack_get -prefix)
    pack_set --install-query $_prefix/$(pack_get --package)
    pack_cmd "$(get_parent_exec) CMD INSTALL -l $_prefix $archive_path/$(pack_get -archive)"
    pack_set -module-opt "-prepend-ENV R_LIBS_SITE=$_prefix"
}

add_R_package Rcpp 1.0.0

add_R_package Matrix 1.2-16

add_R_package RcppEigen 0.3.3.5.0
pack_set --mod-req Matrix

add_R_package RcppEigen 0.3.3.5.0
pack_set --mod-req Matrix

add_R_package plyr 1.8.4
pack_set --mod-req Rcpp

# tidyverse packages
#  ggplot2
#  dplyr
#  tidyr
#  readr
#  purrr
#  tibble
#  stringr
#  forcats

add_R_package tibble 2.0.1

add_R_package bench 1.0.1
pack_set --mod-req tibble

add_R_package tidyselect 0.2.5
pack_set --mod-req Rcpp

add_R_package dplyr 0.8.0.1
pack_set --mod-req tibble
pack_set --mod-req tidyselect

add_R_package stringr 1.4.0

add_R_package forcats 0.4.0
pack_set --mod-req tibble

add_R_package purrr 0.3.1

add_R_package readr 1.3.1
pack_set --mod-req Rcpp
pack_set --mod-req tibble

add_R_package tidyr 1.3.1
pack_set --mod-req purrr
pack_set --mod-req dplyr

add_R_package MASS 7.3-51.1

add_R_package ggplot2 1.3.1
pack_set --mod-req plyr
pack_set --mod-req tibble
pack_set --mod-req dplyr
pack_set --mod-req MASS

unset add_R_package

build_set --default-build $def_idx
