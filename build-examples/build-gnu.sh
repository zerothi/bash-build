# Reset all modulepath
module purge
unset MODULEPATH_modshare
export MODULEPATH=
env | grep MODULE

source build-generic.sh

module purge

source source-gnu.sh
new_build --name gnu \
    --installation-path /opt/$(get_c -n)/$(get_c -v) \
    --module-path /opt/modules/$(get_c -n)/$(get_c -v) \
    --build-path .compile \
    --build-module-path "--package --version" \
    --build-installation-path "--package --version" \
    --source source-gnu.sh \
    --default-module gcc[$(get_c -v)]

build_set --default-choice[gnu] linalg openblas blis atlas blas

mkdir -p $(build_get --module-path[gnu])-apps

build_set --default-module-version[gnu]

source source-gnu-debug.sh
new_build --name debug \
    --installation-path /opt/$(get_c -n)/$(get_c -v) \
    --module-path /opt/modules/$(get_c -n)/$(get_c -v) \
    --build-path .compile \
    --build-module-path "--package --version" \
    --build-installation-path "--package --version" \
    --source source-gnu-debug.sh \
    --default-module gcc[$(get_c -v)]

build_set --default-choice[debug] linalg openblas blis atlas blas

# Override default build to gnu
_b_name_default=gnu
