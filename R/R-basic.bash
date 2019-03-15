archive_path=$(build_get -archive-path)
prefix=$(pack_get -prefix $(get_parent))/library

function add_R_package {
    local name=$1
    local v=$2
    shift 2
    # TODO change to dwn_file, check for directory existance, then append pack_cmd to a single package!
    add_package $@ https://cran.r-project.org/src/contrib/${name}_$v.tar.gz
    pack_set --install-query $prefix/$name
    pack_cmd "$(get_parent_exec) CMD INSTALL -l $prefix $archive_path/$(pack_get -archive)"
}

add_R_package rstudioapi 0.9.0

add_R_package assertthat 0.2.0
add_R_package R6 2.4.0
add_R_package crayon 1.3.4
add_R_package cli 1.0.1
add_R_package rlang 0.3.1
add_R_package pillar 1.3.1
add_R_package testthat 2.0.1
add_R_package devtools 2.0.1
add_R_package glue 1.3.1
add_R_package covr 3.2.1
add_R_package magrittr 1.5
add_R_package stringi 1.4.3
add_R_package ellipsis 0.1.0
add_R_package clipr 0.5.0
add_R_package evaluate 0.13
add_R_package yaml 2.2.0
add_R_package knitr 1.22
add_R_package hms 0.4.2
add_R_package gtable 0.2.0
add_R_package scales 1.0.0
add_R_package prettyunits 1.0.2
add_R_package progress 1.2.0

unset archive_path
unset prefix
unset add_R_package
