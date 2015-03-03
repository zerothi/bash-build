# purge modules
module purge

# set-c compiler verion
source source-intel.sh

new_build --name intel \
    --installation-path /opt \
    --module-path /opt/modules \
    --build-path .compile \
    --build-module-path "--package --version $(get_c)" \
    --build-installation-path "--package --version $(get_c)" \
    --source source-intel.sh

mkdir -p $(build_get --module-path[intel])-npa
mkdir -p $(build_get --module-path[intel])-npa-apps

build_set --default-module-version[intel]
FORCEMODULE=1

tmp=$(get_c)
new_build --name vendor-intel \
    --installation-path /opt/vendor \
    --module-path /opt/modules-vendor \
    --source source-intel.sh \
    --build-module-path "--package --version ${tmp//intel-/}" \
    --build-installation-path "--package --version ${tmp//intel-/}"

