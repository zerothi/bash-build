msg_install \
    --message \
    "Installing the R-packages for $(pack_get --module-name $(get_parent))"
# This script will install all R packages
#exit 0

rMod="$(pack_get --mod-req-module $(get_parent)) $(get_parent)"
rModNames="$(list --loop-cmd "pack_get --module-name" $pMod)"
module load $rModNames
rV=$(pack_get --version $(get_parent))
rV=${rV:0:3}
IrrV=$(lc $(pack_get --alias $(get_parent)))-$(pack_get --version $(get_parent))
IrV=$(pack_get --version $(get_parent))
module unload $rModNames

# Save the default build index
def_idx=$(build_get --default-build)

# Ensure get_c is defined
source $(build_get --source)
tmp=$(dirname $(pack_get --prefix $(get_parent)))/packages
new_build --name R$IrV \
    --source $(build_get --source) \
    $(list --prefix "--default-module " $rMod) \
    --installation-path $tmp \
    --build-module-path "--package --version $IrrV" \
    --build-installation-path "--package --version"
unset tmp

# Change to the new build default
build_set --default-build R$IrV

build_set --default-choice[R$IrV] linalg openblas blis atlas blas

source_pack R/rcpp.bash


build_set --default-build $def_idx
