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

python_version=2

while [ $# -gt 1 ]; do
    opt=$1
    case $opt in
	--python-version|-python-version|-pv)
	    shift
	    python_version=$1
	    shift ;;
	--tcl|-tcl)
	    _module_format=TCL
	    shift ;;
	--lua|-lua)
	    _module_format=LUA
	    shift ;;
	*)
	    break
	    ;;
    esac
done

# Notify the user about which module files will be generated
msg_install --message "Will create $_module_format compliant module files"

case $python_version in
    2|3)
	;; # fine
    *)
	doerr "option parsing" "Cant figure out the python version"
esac

declare -a l_builds

# Get all sources
l_builds[0]=compiler.sh
i=0
while [ $# -ne 0 ]; do
    l_builds[$i]=$1
    let i++
    shift
done

# Source the first file
if [ ! -e ${l_builds[0]} ]; then
    echo "File ${l_builds[0]} does not exist, please create."
    exit 1
fi
source ${l_builds[0]}

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

# Install helper scripts
source scripts.bash

# Install the lua-libraries
source lua/lua.bash

# Source the next build
if [ ${#l_builds[@]} -gt 1 ]; then
    i=1
    while [ $i -lt ${#l_builds[@]} ]; do
	source ${l_builds[$i]}
	let i++
    done
fi

# Install all libraries
source libs.bash

# These are "parent" installations...
source python${python_version}.bash

# We have installed all libraries needed for doing application installs
source apps.bash

# Add the default modules
source default.bash

# Add the latest modules
source latest.bash

msg_install --message "Finished installing all applications..."


# When dealing with additional sets of instructions spec files
# can come in handy.
# For instance to add an include directory to all cpp files do
# gcc -dumpspecs > specs
# Edit specs in line *cpp:
# and add -I<folder>
# Per default will gcc read specs in the folder of generic libraries:
# gcc -print-libgcc-file-name (dir)
