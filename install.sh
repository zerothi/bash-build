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

TIMING=1

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

# Vendor libraries do not depend on anything...
source vendor.bash

# Install the helper
source helpers.bash

# Install the lua-libraries
if $(is_host slid muspel slid n-) ; then
    msg_install --message "Will not install LUA libraries on niflheim..."
else
    source lua/lua.bash
fi

# Install all libraries
source libs.bash

# These are "parent" installations...
source python2.bash
# The _ctypes does not work yet...
#source python3.bash

# We have installed all libraries needed for doing application installs
source apps.bash

# Add the default modules
source default.bash

# We have installed all libraries needed for doing application installs
source scripts.bash

# When dealing with additional sets of instructions spec files
# can come in handy.
# For instance to add an include directory to all cpp files do
# gcc -dumpspecs > specs
# Edit specs in line *cpp:
# and add -I<folder>
# Per default will gcc read specs in the folder of generic libraries:
# gcc -print-libgcc-file-name (dir)
