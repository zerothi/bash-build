msg_install --message "Installing the scripts..."

build_set --non-default-module-version
build_set --default-build generic-empty

source scripts/npa-scripts.bash

install_all --from npa-scripts
