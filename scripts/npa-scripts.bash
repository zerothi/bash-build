add_package npa-scripts.local

pack_set -s $IS_MODULE

pack_set --directory .
pack_set --version npa

# Always install this package (easy updates)
pack_set --install-query /directory/does/not/exist

# Create installation dir
pack_cmd "mkdir -p $(pack_get --prefix)/bin"
pack_cmd "mkdir -p $(pack_get --prefix)/source"
pack_set --module-opt "--set-ENV NPA_SOURCE=$(pack_get --prefix)/source"

source scripts/npa-spbs.bash
source scripts/npa-slsf.bash
source scripts/npa-moduleswitch.bash
source scripts/npa-ml.bash
source scripts/npa-sub.bash

pack_cmd "chmod a+rx $(pack_get --prefix)/bin/*"
pack_cmd "chmod a+r $(pack_get --prefix)/source/*"
