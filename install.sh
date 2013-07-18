#!/bin/bash

tmp=`pwd`

source ~/.bashrc
module purge

# Ensure that there is not multiple threads running
export OMP_NUM_THREADS=1

# On thul and interactive nodes, sourching leads to going back
cd $tmp
unset tmp

# We need to load this every time... :(
# Enables all modules that gets added...
module load npa-cluster-setup

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
    #echo get CFLAGS $(edit_env --get CFLAGS)
    #$(edit_env --prepend '-hollo' CFLAGS)
    #echo get PREPEND CFLAGS $(edit_env --get CFLAGS)
    #$(edit_env --append '-hollo' CFLAGS)
    #echo get APPEND CFLAGS $(edit_env --get CFLAGS)
    echo ""
    add_package abc-1.8.2.tar.gz
    add_package abc-1.8.3.tar.gz
    add_package def-1.8.3.tar.gz
    pack_set --module-requirement abc[1.8.2]
    for tmp in $(pack_get --module-requirement) ; do
	echo Checking $tmp
    done
    echo Check version indexing:
    echo START >> test
    echo $(pack_get --version abc[1.8.2]) $(pack_get --version abc) $(pack_get --version abc[1.8.3])
    echo END >> test
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
    echo Check for is_c:
    if $(is_c $(get_c)) ; then
	echo Success on is_c
    else
	echo Fail on is_c
    fi
    if  $(is_c random) ; then
	echo Fail on is_c
    else
	echo Success on is_c
    fi
    echo Duplicate removal:
    echo $(rem_dup 1290 0935 1 4- 81 1290 senthu seuth stneo[2314] seuth[243])

    if $(pack_exists abc) ; then
	echo "FOUND CORRECTLY PACKAGE abc"
    else
	echo "ERROR"
    fi
    if $(pack_exists aeudaoeusnoa) ; then
	echo "ERROR FOUND PACKAGE aeudaoeusnoa $(get_index aeudaoeusnoa)"
    else
	echo "CORRECTLY DETERMINED THE PACKAGE TO NOT EXIST"
    fi

# for i in "${!_index[@]}"
# do
#    echo "value: ${_index[$i]}\tkey: $i"
# done
    echo "Done with DEBUG"
fi

# Install the lua-libraries
source lua/lua.bash

# Install all libraries
source libs.bash

# These are "parent" installations...
source python2.bash
#source python3.bash

# We have installed all libraries needed for doing application installs
source apps.bash

# We have installed all libraries needed for doing application installs
source scripts.bash

install_all


# When dealing with additional sets of instructions spec files
# can come in handy.
# For instance to add an include directory to all cpp files do
# gcc -dumpspecs > specs
# Edit specs in line *cpp:
# and add -I<folder>
# Per default will gcc read specs in the folder of generic libraries:
# gcc -print-libgcc-file-name (dir)
