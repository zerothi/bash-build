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

# Install the helper
source helpers.bash

# Source the next build
if [ ${#l_builds[@]} -gt 1 ]; then
    i=1
    while [ $i -lt ${#l_builds[@]} ]; do
	source ${l_builds[$i]}
	let i++
    done
fi

source libs/zlib.bash
source libs/expat.bash
source libs/libffi.bash
source libs/libxml2.bash

# Basic parallel libraries
source libs/hwloc.bash
source libs/openmpi-hpc.bash

source libs/fftw2.bash
source libs/fftw3.bash
source libs/blas.bash
source libs/cblas.bash
source libs/lapack.bash blas
source libs/atlas.bash
source libs/lapack.bash atlas
source libs/openblas.bash
source libs/lapack.bash openblas

# A sparse library
source libs/suitesparse.bash

# These are "parent" installations...
source python${python_version}.bash
