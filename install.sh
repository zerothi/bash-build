#!/bin/bash

source ~/.bashrc
module purge

# We have here the installation of all the stuff for gray....
source install_funcs.sh

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

# Initialize the installation path
set_installation_path $install_path

# Initialize the module read path
set_module_path $install_path/modules

# Initialize the compiler directory
set_c $compiler

# Begin installation of various packages
# List of archives
# The order is the installation order
# Set the umask 5 means read and execute
#umask 0
_DEBUG=0
if [ $_DEBUG -ne 0 ]; then
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
fi

# Install all libraries
source libs.bash

# These are "parent" installations...
source python2.bash
#source python3.bash

# We have installed all libraries needed for doing application installs
source apps.bash

# Initialize the module read path
set_module_path $install_path/modules-npa

# We install the module scripts here:
create_module \
    -n "\"Nick Papior Andersen's module script for: $(get_c)\"" \
    -v $(date +'%g-%j') \
    -M mpi.zlib.hdf5.netcdf/$(get_c) \
    -P "/directory/should/not/exist" \
    -L "$(pack_get --module-name openmpi)" \
    -L "$(pack_get --module-name zlib)" \
    -L "$(pack_get --module-name hdf5)" \
    -L "$(pack_get --module-name pnetcdf)" \
    -L "$(pack_get --module-name netcdf)"

create_module \
    -n "\"Nick Papior Andersen's basic math script for: $(get_c)\"" \
    -v $(date +'%g-%j') \
    -M blas.lapack/$(get_c) \
    -P "/directory/should/not/exist" \
    -L "$(pack_get --module-name blas)" \
    -L "$(pack_get --module-name lapack)"

create_module \
    -n "\"Nick Papior Andersen's parallel math script for: $(get_c)\"" \
    -v $(date +'%g-%j') \
    -M mpi.blas.lapack.scalapack/$(get_c) \
    -P "/directory/should/not/exist" \
    -L "$(pack_get --module-name openmpi)" \
    -L "$(pack_get --module-name blas)" \
    -L "$(pack_get --module-name lapack)" \
    -L "$(pack_get --module-name scalapack)"

create_module \
    -n "\"Nick Papior Andersen's default application script for: $(get_c)\"" \
    -v $(date +'%g-%j') \
    -M default.gnuplot.grace/$(get_c) \
    -P "/directory/should/not/exist" \
    -L "$(pack_get --module-name gnuplot)" \
    -L "$(pack_get --module-name grace)"
