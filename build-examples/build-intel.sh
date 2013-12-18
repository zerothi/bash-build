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

build_set --default-module-version
FORCEMODULE=1
build_set --module-format LUA

source build-generic.sh
