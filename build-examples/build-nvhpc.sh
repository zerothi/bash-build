# Reset all modulepath
module purge
unset MODULEPATH_modshare
export MODULEPATH=
env | grep MODULE

source build-generic.sh

module purge

source source-nvhpc.sh
new_build --name nvhpc \
    --installation-path /opt/$(get_c -n)/$(get_c -v) \
    --module-path /opt/modules/$(get_c -n)/$(get_c -v) \
    --build-path .compile \
    --build-module-path "--package --version" \
    --build-installation-path "--package --version" \
    --source source-nvhpc.sh \
    --default-module nvhpc[$(get_c -v)]

build_set --default-choice[nvhpc] linalg openblas blis atlas blas

mkdir -p $(build_get --module-path[nvhpc])-apps

build_set --default-module-version[nvhpc]

source source-nvhpc-debug.sh
new_build --name debug \
    --installation-path /opt/$(get_c -n)/$(get_c -v) \
    --module-path /opt/modules/$(get_c -n)/$(get_c -v) \
    --build-path .compile \
    --build-module-path "--package --version" \
    --build-installation-path "--package --version" \
    --source source-nvhpc-debug.sh \
    --default-module nvhpc[$(get_c -v)]

build_set --default-choice[debug] linalg openblas blis atlas blas

# Override default build to gnu
_b_name_default=nvhpc
