#!/bin/bash -i

_top_dir=`pwd`

source ~/.bashrc
module purge

# Ensure that there is not multiple threads running
export OMP_NUM_THREADS=1

# On thul and interactive nodes, sourching leads to going back
cd $_top_dir

# We have here the installation of all the stuff for gray....
source src/init.bash

# Default python version installed
_python_version=2
# Default MPI version
_mpi_version=openmpi
# Default name for build which builds the generic
# packages.
_generic_build=generic
_default_build=generic
while [ $# -gt 0 ]; do
    opt=$(trim_em $1)
    case $opt in
	-*)
	    shift
	    ;;
    esac
    case $opt in
	-python-version|-pv)
	    _python_version=$1
	    case $_python_version in
		2|3)
		    ;; # fine
		*)
		    doerr "option parsing" "Python version does not exist [2|3]"
		    ;;
	    esac
	    shift ;;
	-mpi-version|-mpi)
	    _mpi_version=$(lc $1)
	    case $_mpi_version in
		openmpi|mpich)
		    ;; # fine
		*)
		    doerr "option parsing" "MPI version does not exist [OpenMPI|MPICH]"
		    ;;
	    esac
	    shift ;;
	-tcl)
	    _module_format=TCL
	    ;;
	-lua)
	    _module_format=LUA
	    ;;
	-generic)
	    _generic_build=$1
	    shift ;;
	-default|-opti|-d)
	    _default_build=$1
	    shift ;;
	-list)
	    export PACK_LIST=1
	    ;;
	-only)
	    pack_only $1
	    shift ;;
	-only-file)
	    pack_only --file $1
	    shift ;;
	-debug)
	    export DEBUG=1
	    ;;
	-build)
	    opt=$1
	    ;& # go through
	*)
	    # We consider empty stuff to be builds
	    if [ ! -e $opt ]; then
		doerr "option parsing" "Build source $opt does not exist!"
	    fi
	    source $opt
	    shift
	    ;;
    esac
done

# We should now have populated all builds
# Check if the _generic_build exists
tmp=$(get_index --hash-array "_b_index" $_generic_build)
if [ -z "$tmp" ]; then
    doerr "option parsing" "Unrecognized build $_generic_build, create it first"
else
    build_set --default-build $_generic_build
    msg_install --message "The default build for the generic packages is: $_generic_build"
    source $(build_get --source)
fi
tmp=$(get_index --hash-array "_b_index" $_default_build)
if [ -z "$tmp" ]; then
    doerr "option parsing" "Unrecognized build $_default_build, create it first"
else
    msg_install --message "The default build for packages is: $_default_build"
fi

# Notify the user about which module files will be generated
msg_install --message "Will create $_module_format compliant module files"

tmp=0
while [ $tmp -lt $_N_b ]; do
    if [ -z "$(build_get --installation-path[$tmp])" ]; then
	msg_install --message "The installation path for ${_b_name[$tmp]} has not been set."
	echo "I do not dare to guess where to place packages!"
	echo "Please set it in your source file."
	exit 1
    fi

    if [ -z "$(build_get --module-path[$tmp])" ]; then
	msg_install --message "The module path for ${_b_name[$tmp]} has not been set."
	msg_install --message "Will set it to: $(build_get --installation-path[$tmp])/modules"
	build_set --module-path "$(build_get --installation-path[$tmp])/modules"
    fi
    let tmp++
done


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

build_set --default-build $_default_build
build_set --reset-module \
    $(list --prefix '--default-module ' \
        $(build_get --default-module))
source $(build_get --source)

# Install all libraries
source libs.bash

# These are "parent" installations...
source python${_python_version}.bash

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
