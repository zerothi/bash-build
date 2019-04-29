# purge modules
module purge

# set-c compiler verion
source source-intel.sh

new_build --name intel \
    --installation-path /opt/$(get_c -n)/$(get_c -v) \
    --module-path /opt/modules/$(get_c -n)/$(get_c -v) \
    --build-path .compile \
    --build-module-path "--package --version" \
    --build-installation-path "--package --version" \
    --source source-intel.sh

build_set --default-choice[intel] linalg openblas atlas blas

mkdir -p $(build_get --module-path[intel])-apps

build_set --default-module-version[intel]
FORCEMODULE=1

source source-intel-debug.sh

new_build --name debug \
    --installation-path /opt/$(get_c -n)/$(get_c -v) \
    --module-path /opt/modules/$(get_c -n)/$(get_c -v) \
    --build-path .compile \
    --build-module-path "--package --version" \
    --build-installation-path "--package --version" \
    --source source-intel-debug.sh

build_set --default-choice[debug] linalg openblas atlas blas

