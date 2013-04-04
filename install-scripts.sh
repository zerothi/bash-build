#!/bin/bash

source ~/.bashrc

# We have here the installation of all the stuff for gray....
source install_funcs.sh

if [ $# -ne 0 ]; then
    [ ! -e $1 ] && echo "File $1 does not exist, please create." && exit 1
    source $1
else
    [ ! -e compiler.sh ] && echo "Please create file: compiler.sh" && exit 1
    source compiler.sh
fi

# Create the build path for downloading and creating the stuff
set_build_path $(pwd)

# Initialize the module read path
set_module_path $(get_installation_path)/modules

source scripts.bash

pack_install
