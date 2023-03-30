# This file should be sourced and used to compile the tools for compiling 
# different libraries.

# Set options
set -o hashall
shopt -s globstar
# disable win-resizing
shopt -u checkwinsize
# disable history
shopt -u histappend


# Check whether the module command is actually installed
_has_module_cmd=1
type module 2>&1 > /dev/null
if [[ $? -eq 1 ]]; then
    _has_module_cmd=0
fi


# Create proper error handling
# First we establish what the PID of the current process is
_bb_PID=$$
# Now instantiate a trap which catches TERM signals
trap '_bb_exit' TERM

function _bb_exit {
    # This function will list the lines where it went wrong
    local depthn=${#FUNCNAME[@]}
    local i j
    local func src line
    echo ''

    for ((i=1; i<$depthn; i++)) ; do
	j=$((i-1))
        func="${FUNCNAME[$j]}"
        src="${BASH_SOURCE[$i]}"
        line="${BASH_LINENO[$j]}"
        printf '%*s %s in %s at line: %s\n' $i '' "$func()" "$src" "$line"
    done

    exit 1
}

# Make an error and exit
function doerr {
    local prefix="ERROR: "
    echo "${prefix}$@" >> $_ERROR_FILE
    echo "${prefix}$@" >&2
    kill -s TERM $_bb_PID
    exit 1
}

if [[ ${BASH_VERSION%%.*} -lt 4 ]]; then
    doerr "$BASH_VERSION" 'Installation requires to use BASH >= 4.x.x'
fi

_DEBUG_COUNTER=0
function debug { echo "Debug: ${_DEBUG_COUNTER} $@" ; let _DEBUG_COUNTER++ ; }

source src/globals.bash

_crt_version=0

_parent_package=''
# The parent package (for instance Python)
function set_parent {       _parent_package=$1 ; }
function clear_parent {     _parent_package='' ; }
function get_parent { printf '%s' "$_parent_package" ; }

_parent_exec=''
# The parent package (for instance Python)
function set_parent_exec {       _parent_exec=$1 ; }
function get_parent_exec { printf '%s' "$_parent_exec" ; }

# Create a list of packages that _only_ will
# be installed
# This can be handy to create custom builds which
# can test certain parts.
declare -A _pack_only
function pack_only {
    local tmp
    local opt
    while [[ $# -gt 0 ]]; do
	trim_em opt $1
	case $opt in
	    -file)
		shift
		# We will add all packages found in the file
		local line
		# parse file
		while read line
		do
		    [[ "x${line:0:1}" == "x#" ]] && continue
		    _pack_only[$line]=1
		done < $1
		shift
		;;
	    *)
		_pack_only[$opt]=1
		shift
		;;
	esac
    done
}

# Add any auxillary commands
source src/auxilliary.bash

# Add the compiler stuff 
source src/compiler.bash

# Add host information
source src/host.bash

# The place of all the archives
_archives="$_cwd/.archives"
# Ensure the archive directory exists
mkdir -p $_archives
function pwd_archives { printf '%s' "$_archives" ; }

_install_prefix_no_path="HIDDEN"

source src/build.bash
source src/package.bash
source src/install.bash
source src/module.bash


# Function for editing environment variables
# Mainly used for receiving and appending to variables
function edit_env {
    local opt
    trim_em opt $1
    shift
    local echo_env=0
    local append='' ; local prepend=''
    case $opt in
	-g|-get)           echo_env=1 ;;
	-p|-prepend)       prepend="$1" ; shift ;;
	-a|-append)        append="$1" ; shift ;;
	*)
	    doerr $1 "No option for edit_env found for $1" ;;
    esac
    local env=$1
    shift
    [[ "$echo_env" -ne "0" ]] && printf '%s' "${!env}" && return 0
    # Process what is requested
    [[ -n "$append" ]] && export ${!env}="${!env}$append"
    [[ -n "$prepend" ]] && eval "export $env='$prepend${!env}'"
}


# Has setting returns 1 for success and 0 for fail
#   $1 : <setting>
#   $2 : <index|name of archive>
function has_setting {
    local ss
    local s="$1" ; shift
    local -a sets=()
    [[ $# -gt 0 ]] && ss="$1" && shift
    IFS="$_LIST_SEP" read -ra sets <<< "$(pack_get -s $ss)"
    for ss in "${sets[@]}" ; do
	[[ "x$s" == "x$ss" ]] && return 0
    done
    return 1
}

    
# Returns the -j <procs> flag for the make command
# If the MAKE_PARALLEL setting has been enabled.
#   $1 : <index of archive>
function get_make_parallel {
    if $(has_setting $MAKE_PARALLEL $1) ; then
	printf '%s' "-j $_n_procs"
    else
	printf '%s' ""
    fi
}

# Returns number of processors for parallel runs
# If the MAKE_PARALLEL setting has been enabled.
#   $1 : <index of archive>
# If not, it returns 1
function get_parallel {
    if $(has_setting $MAKE_PARALLEL $1) ; then
	printf '%s' "$_n_procs"
    else
	printf '%s' "1"
    fi
}
#################################################
#################################################
###########     Helper functions     ############


function pack_crt_list {
    [ $PACK_LIST -eq 0 ] && return
    # It will only take one argument...
    local pack=$_N_archives
    [ $# -gt 0 ] && pack=$1
    local build=$(pack_get --build $pack)
    build=$(build_get --build-path[$build])
    local mr=$(pack_get --module-requirement $pack)
    if [[ -n "$mr" ]]; then
	{
	    echo '# Used packages'
	    for p in $mr ; do
		echo "$p"
	    done
	    echo "$(pack_get --alias $pack)"
	} > $build/$(pack_get --alias $pack)-$(pack_get --version $pack).list
    fi
}

