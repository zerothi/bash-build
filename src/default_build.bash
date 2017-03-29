# Initial source
if [[ -z "$gen_gnu_version" ]]; then
    gen_gnu_version=`gcc --version | head -1 | awk '{print $NF}'`
fi
tmp_src=src/source-generic.sh
source $tmp_src
module purge

# By default create survey file
module_set --survey-file $_prefix/survey

new_build --name generic \
    --installation-path $_prefix/generic \
    --module-path $_prefix/modules-generic \
    --build-path .compile \
    --source $tmp_src \
    --build-module-path "--package --version" \
    --build-installation-path "--package --version"

new_build --name generic-no-version \
    --installation-path $_prefix/generic \
    --module-path $_prefix/modules-generic \
    --build-path .compile \
    --source $tmp_src \
    --build-module-path "--package" \
    --build-installation-path "--package"

new_build --name generic-empty \
    --installation-path $_prefix/generic \
    --module-path $_prefix/modules-generic \
    --build-path .compile \
    --source $tmp_src \
    --build-module-path "--package" \
    --build-installation-path ""

new_build --name vendor \
    --installation-path $_prefix/vendor \
    --module-path $_prefix/modules-generic \
    --build-path .compile \
    --source $tmp_src \
    --build-module-path "--package --version" \
    --build-installation-path "--package --version"

new_build --name generic-host \
    --installation-path $_prefix \
    --module-path $_prefix/modules \
    --build-path .compile \
    --source $tmp_src \
    --build-module-path "--package --version $(get_c)" \
    --build-installation-path "--package --version $(get_c)"


# Define the gnu builds
if [[ -z "$gnu_version" ]]; then
    gnu_version=6.1.0
fi

tmp_src=src/source-gnu.sh
source $tmp_src

new_build --name gnu \
    --installation-path $_prefix \
    --module-path $_prefix/modules \
    --build-path .compile \
    --build-module-path "--package --version $(get_c)" \
    --build-installation-path "--package --version $(get_c)" \
    --source $tmp_src \
    --default-module gcc[$gnu_version]

# The default linear algebra choice for this default build
build_set --default-choice[gnu] linalg openblas atlas blis blas

# Create additional module installation directories
mkdir -p $(build_get --module-path[gnu])-npa
mkdir -p $(build_get --module-path[gnu])-npa-apps

# Specify that the default module version is gnu
build_set --default-module-version[gnu]

tmp_src=src/source-gnu-debug.sh
source $tmp_src
new_build --name debug \
    --installation-path $_prefix \
    --module-path $_prefix/modules \
    --build-path .compile \
    --build-module-path "--package --version $(get_c)" \
    --build-installation-path "--package --version $(get_c)" \
    --source $tmp_src \
    --default-module gcc[$gnu_version]

build_set --default-choice[debug] linalg openblas atlas blis blas

# Override default build to gnu
_b_name_default=gnu

