prefix=$(pack_get -prefix $(get_parent))/library

_R_pack=
function R_append {
    while [[ $# -gt 0 ]];
    do
	_R_pack="$_R_pack, \"$1\""
	shift
    done
}

add_package R_installs.local
pack_set --directory .

R_append rstudioapi
R_append fansi
R_append R6
R_append crayon
R_append cli
R_append rlang
R_append devtools
R_append utf8
R_append pillar
R_append digest
R_append praise
R_append withr
R_append magrittr
R_append testthat
R_append pkgconfig
R_append glue
R_append covr
R_append stringi
R_append ellipsis
R_append clipr
R_append evaluate
R_append yaml
R_append knitr
R_append hms
R_append gtable
R_append scales
R_append prettyunits
R_append progress

_R_dwn=$(pwd_archives)/R
mkdir -p $_R_dwn
pack_cmd "R -q --vanilla -e 'lop <- c(${_R_pack:2}) ; np <- lop[!(lop %in% installed.packages()[,\"Package\"])] ; q(install.packages(np, lib=\"$prefix\", destdir=\"$_R_dwn\", verbose=TRUE, repos=\"https://cloud.r-project.org\"));'"
unset _R_dwn

function add_R_package {
    shift
}
add_R_package rstudioapi

add_R_package fansi 0.4.0
add_R_package assertthat 0.2.1
add_R_package R6 2.4.0
add_R_package crayon 1.3.4
add_R_package cli 1.1.0
add_R_package rlang 0.3.4
add_R_package utf8 1.1.4
add_R_package pillar 1.3.1
add_R_package digest 0.6.18
add_R_package praise 1.0.0
add_R_package withr 2.1.2
add_R_package magrittr 1.5
add_R_package testthat 2.0.1
add_R_package devtools 2.0.2
add_R_package pkgconfig 2.0.2
add_R_package glue 1.3.1
add_R_package covr 3.2.1
add_R_package stringi 1.4.3
add_R_package ellipsis 0.1.0
add_R_package clipr 0.5.0
add_R_package evaluate 0.13
add_R_package yaml 2.2.0
add_R_package knitr 1.22
add_R_package hms 0.4.2
add_R_package gtable 0.3.0
add_R_package scales 1.0.0
add_R_package prettyunits 1.0.2
add_R_package progress 1.2.0

unset _R_pack
unset prefix
unset add_R_package
unset R_append


pack_install
