add_package npa-scripts.local

pack_set -s $IS_MODULE

pack_set --directory .
pack_set --version npa

# Always install this package (easy updates)
pack_set --install-query /directory/does/not/exist

# Create installation dir
pack_set --command "mkdir -p $(pack_get --prefix)/bin"
pack_set --command "mkdir -p $(pack_get --prefix)/source"
pack_set --module-opt "--set-ENV NPA_SOURCE=$(pack_get --prefix)/source"

script=""
function _npa_new_name {
    script="${script}a"
}

_npa_new_name

source scripts/npa-spbs.bash
source scripts/npa-moduleswitch.bash
source scripts/npa-ml.bash

unset _npa_new_name
unset script
pack_set --command "chmod a+x $(pack_get --prefix)/bin/*"
