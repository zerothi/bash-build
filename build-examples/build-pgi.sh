module purge

source source-pgi.sh

new_build --name pgi \
    --installation-path /opt/$(get_c -n)/$(get_c -v) \
    --module-path /opt/modules/$(get_c -n)/$(get_c -v) \
    --build-path .compile \
    --build-module-path "-package -version" \
    --build-installation-path "-package -version" \
    --source source-pgi.sh

mkdir -p $(build_get --module-path[pgi])-apps

build_set --default-choice[pgi] linalg openblas atlas blas
build_set --default-module-version[pgi]

source source-pgi-debug.sh
new_build --name debug \
    --installation-path /opt/$(get_c -n)/$(get_c -v) \
    --module-path /opt/modules/$(get_c -n)/$(get_c -v) \
    --build-path .compile \
    --build-module-path "-package -version" \
    --build-installation-path "-package -version" \
    --source source-pgi-debug.sh

build_set --default-choice[pgi] linalg openblas atlas blas

FORCEMODULE=1
