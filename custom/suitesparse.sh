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
    opt=$1 ; shift
    case $opt in
	--python-version|-python-version|-pv)
	    python_version=$1 ; shift ;;
    esac
done

case $python_version in
    2|3)
	;; # fine
    *)
	doerr "option parsing" "Cant figure out the python version"
esac

# Use ln to link to this file
if [ $# -ne 0 ]; then
    [ ! -e $1 ] && echo "File $1 does not exist, please create." && exit 1
    source $1
    shift
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

source helpers.bash

# Default packages for many libs
source libs/blas.bash
source libs/cblas.bash
source libs/lapack.bash blas
source libs/atlas.bash
source libs/lapack.bash atlas
source libs/openblas.bash
source libs/lapack.bash openblas

source libs/metis.bash

source libs/suitesparse_all.bash

pack_install