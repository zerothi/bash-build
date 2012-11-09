#!/bin/bash

source ~/.bashrc
module purge

# We have here the installation of all the stuff for gray....

# Use ln to link to this file
if [ $# -ne 0 ]; then
    [ ! -e $1 ] && echo "File $1 does not exist, please create." && exit 1
    source $1
else
    [ ! -e compiler.sh ] && echo "Please create file: compiler.sh" && exit 1
    source compiler.sh
fi

source install_funcs.sh

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

source gnuplot.bash
source blas.bash
source lapack.bash
#source atlas.bash
source gsl.bash
source zlib.bash
source openmpi.bash
#source git.bash
source scalapack.bash
source hdf5.bash
source hdf5-serial.bash
source parallel-netcdf.bash
source netcdf.bash
source xmgrace.bash

# These are "parent" installations...
source python2.bash
#source python3.bash



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
