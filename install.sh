#!/bin/bash

source ~/.bashrc
module purge

# We have here the installation of all the stuff for gray....
source install_funcs.sh

TIMING=1

# Use ln to link to this file
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

# Begin installation of various packages
# List of archives
# The order is the installation order
# Set the umask 5 means read and execute
#umask 0

if [ $DEBUG -ne 0 ]; then
    echo get CFLAGS $(edit_env --get CFLAGS)
    $(edit_env --prepend '-hollo' CFLAGS)
    echo get PREPEND CFLAGS $(edit_env --get CFLAGS)
    $(edit_env --append '-hollo' CFLAGS)
    echo get APPEND CFLAGS $(edit_env --get CFLAGS)
    echo ""
    add_package abc.tar.gz
    add_package def.tar.gz
    pack_set --module-requirement abc
    add_package ghi.tar.gz
    pack_set $(list --pack-module-reqs def)
    echo PRE ALL: $(list --prefix 'PRE' abc def ghi )
    echo PRE SUF ALL: $(list --prefix 'PRE' --suffix 'SUF'  abc def ghi )
    echo Wlrpath LDFLAGS $(list --Wlrpath --LDFLAGS   abc def ghi )
    echo ""
    echo Module reqs: $(list --pack-module-reqs def)
    echo Assert Module reqs: $(pack_get --module-requirement ghi)
    echo ""
    tmp="${FCFLAGS// -/ }"
    echo $tmp
    echo SPLIT of FLAGS "$(list --prefix ,\'- --suffix \' ${tmp:1})"
    echo " Check: " 
    echo $(pack_get --module-requirement def)
    echo ""
    tmp=""
    echo LIST of emptyness: "$(list --prefix '-R ' $tmp)"
    echo "Done with DEBUG"
fi

# Install all libraries
source libs.bash

timings

# These are "parent" installations...
source python2.bash
#source python3.bash

# We have installed all libraries needed for doing application installs
source apps.bash


timings