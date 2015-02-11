module purge

source source-gnu.sh

new_build --name gnu \
    --installation-path /opt \
    --module-path /opt/modules \
    --build-path .compile \
    --build-module-path "--package --version $(get_c)" \
    --build-installation-path "--package --version $(get_c)" \
    --source source-gnu.sh

build_set --default-build gnu

mkdir -p $(build_get --module-path[gnu])-npa
mkdir -p $(build_get --module-path[gnu])-npa-apps

build_set --default-module-version
#FORCEMODULE=1
