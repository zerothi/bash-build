msg_install --message "Installing the scripts..."

# fetch default versions
def_build=$(build_get --default-build)
def_version=$(build_get --def-module-version)

build_set --non-default-module-version
build_set --default-build generic-no-version

source scripts/npa-scripts.bash

install_all --from npa-scripts

if [ $def_version -eq 1 ]; then
    build_set --default-module-version
fi
build_set --default-build $def_build
unset def_build def_version
