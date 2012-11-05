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
source install_conf_flags.sh


archive_dir=$(pwd)/archives
compile_dir=$(pwd)/compile
# Create directories
mkdir -p $archive_dir
mkdir -p $compile_dir

# Initialize the installation path
set_installation_path $install_path

# Initialize the module read path
set_module_path $install_path/modules

# Initialize the compiler directory
set_c $compiler

# Begin installation of various packages
# List of archives
# The order is the installation order

source openmpi.bash
source zlib.bash
#source python2.bash
#source python3.bash
source hdf5.bash
#source parallel-netcdf.bash
#source netcdf.bash
#source git.bash


if [ 0 -eq 1 ]; then
echo After all sourcing:
echo $_N_archives
echo URL: ${_http[@]}
echo ARCHIVES: ${_archive[@]}
echo EXT: ${_ext[@]}
echo DIRECTORY: ${_directory[@]}
echo PACKAGE: ${_package[@]}
echo ALIAS: ${_alias[@]}

echo PREFIX: ${_install_prefix[@]}
echo $_package
echo $_version
fi 
# Set the umask 5 means read and execute
#umask 0

i=0
# Start installation loop
while : ; do
    pack_install $i
    [ $? -ne 0 ] && break
    i=$((i+1))
done

# We install the module scripts here:
create_module \
    -n "\"Nick Papior Andersen's module script for: $(get_c)\"" \
    -v $(date +'%j-%g') \
    -M npa/$(get_c) \
    -P "/directory/should/not/exist" \
    -L "$(pack_get --module-name openmpi)" \
    -L "$(pack_get --module-name zlib)" \
    -L "$(pack_get --module-name hdf5)" \
    -L "$(pack_get --module-name netcdf)"