
# We here contain any information that could be relevant for compiler setups

_c=""
# Set compiler name
function set_c { _c="$1" ; }
function get_c { printf "%s" "$_c" ; }

# Check the compiler...
# Takes one argument:
# #1 : the compiler string to search from the beginning of the compiler-name...
function is_c {
    local check="$1"
    local l="${#check}"
    if [ "x${_c:0:$l}" == "x$check" ]; then
	return 0
    fi
    return 1
}

# Local variables for different optimization levels of the compiler
declare -a _c_fO
declare -a _c_cO

# Sets the compiler optimization levels for the C and F compiler
# Currently it does not retain any information about the levels.
# However the array will setup like this:
#  0 == default flags
#  idx == level flags
# If idx does not exist, or the level has a zero length value it will
# return what is the default flag.
# 
# Example:
#  set_flags 1 -xHost -O3 ...
#  set_flags 2 -xHost -O3 -opt-prefetch ...
function set_flags {
    set_c_flags $@
    set_f_flags $@
}
# This will only set the C FLAGS
function set_c_flags {
    local idx=$1 ; shift
    _c_cO[$idx]="$@"
    [ $idx -ge 10 ] && return 0
    local i=$((idx+1))
    if [ "x${_c_cO[$i]}" == "x" ]; then
	set_c_flags $i $@
    fi
}
# This will only set the Fortran FLAGS
function set_f_flags {
    local idx=$1 ; shift
    _c_fO[$idx]="$@"
    [ $idx -ge 10 ] && return 0
    local i=$((idx+1))
    if [ "x${_c_fO[$i]}" == "x" ]; then
	set_f_flags $i $@
    fi
}

# Updates the corresponding environment variable with 
# the optimization level
function update_flags {
    update_c_flags $@
    update_f_flags $@
}

function update_c_flags {
    while true ; do
	# Process what is requested
	local opt=$(trim_em $1)
    done
    update_c_flags $@
    update_f_flags $@
}

function save_common_flags {
    export old_AR=$AR
    export old_CC=$CC
    export old_CXX=$CXX
    export old_CPP=$CPP
    export old_CXXCPP=$CXXCPP
    export old_FC=$FC
    export old_F77=$F77
    export old_F90=$F90
    export old_CFLAGS=$CFLAGS
    export old_FCFLAGS=$FCFLAGS
    export old_FFLAGS=$FFLAGS
    export old_MPICC=$MPICC
    export old_MPIFC=$MPIFC
    export old_MPIF77=$MPIF77
    export old_MPIF90=$MPIF90
}

function restore_common_flags {
    export AR=$old_AR
    export CC=$old_CC
    export CXX=$old_CXX
    export CPP=$old_CPP
    export CXXCPP=$old_CXXCPP
    export FC=$old_FC
    export F77=$old_F77
    export F90=$old_F90
    export CFLAGS=$old_CFLAGS
    export FCFLAGS=$old_FCFLAGS
    export FFLAGS=$old_FFLAGS
    export MPICC=$old_MPICC
    export MPIFC=$old_MPIFC
    export MPIF77=$old_MPIF77
    export MPIF90=$old_MPIF90
}

function reset_common_flags {
    export AR=""
    export CC=""
    export CXX=""
    export CPP=""
    export CXXCPP=""
    export FC=""
    export F77=""
    export F90=""
    export CFLAGS=""
    export FCFLAGS=""
    export FFLAGS=""
    export MPICC=""
    export MPIFC=""
    export MPIF77=""
    export MPIF90=""
}

function reset_common_flags {
    export AR=""
    export CC=""
    export CXX=""
    export CPP=""
    export CXXCPP=""
    export FC=""
    export F77=""
    export F90=""
    export CFLAGS=""
    export FCFLAGS=""
    export FFLAGS=""
    export MPICC=""
    export MPIFC=""
    export MPIF77=""
    export MPIF90=""
}