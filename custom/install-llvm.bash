#!/bin/bash -i

tmp=`pwd`

source ~/.bashrc
module purge

# Ensure that there is not multiple threads running
export OMP_NUM_THREADS=1

# On thul and interactive nodes, sourching leads to going back
cd $tmp
unset tmp

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

if [ -z "$(build_get --installation-path)" ]; then
    msg_install --message "The installation path has not been set."
    echo "I do not dare to guess where to place it..."
    echo "Please set it in your source file."
    exit 1
fi

if [ -z "$(build_get --module-path)" ]; then
    msg_install --message "The module path has not been set."
    msg_install --message "Will set it to: $(build_get --installation-path)/modules"
    build_set --module-path "$(build_get --installation-path)/modules"
fi


# Begin installation of various packages
# List of archives
# The order is the installation order
# Set the umask 5 means read and execute
#umask 0

# We can always set the env-variable of LMOD
export LMOD_IGNORE_CACHE=1

# Install the helper
source helpers.bash

source libs/zlib.bash


# Install Python 2 versions
if $(is_c intel) ; then
    v=2.7.3
else
    v=2.7.6
fi
if $(is_host n-) ; then
    add_package --alias python --package Python \
	http://www.python.org/ftp/python/$v/Python-$v.tgz
else
    add_package --alias python --package python \
	http://www.python.org/ftp/python/$v/Python-$v.tgz
fi

# The settings
pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --module-requirement zlib

pack_set --install-query $(pack_get --install-prefix)/bin/python

tmp=
if ! $(is_c gnu) ; then
    tmp="--without-gcc"
fi

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "LDFLAGS='$(list --LDFLAGS --Wlrpath zlib)'" \
    --command-flag "CPPFLAGS='$(list --INCDIRS zlib)' $tmp" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

pack_install

source libs/llvm.bash

install_all