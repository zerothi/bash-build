module purge

source source-pgi.sh

new_build --name pgi \
    --installation-path /opt \
    --module-path /opt/modules \
    --build-path .compile \
    --build-module-path "--package --version $(get_c)" \
    --build-installation-path "--package --version $(get_c)" \
    --source source-pgi.sh

mkdir -p $(build_get --module-path[pgi])-npa
mkdir -p $(build_get --module-path[pgi])-npa-apps

build_set --default-module-version[pgi]
FORCEMODULE=1

