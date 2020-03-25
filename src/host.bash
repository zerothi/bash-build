
# Information and functions dealing with the host machine

# We will create a local name of the host
_host="$(hostname -s)"
function get_hostname {
    printf '%s' "$_host"
}

#  Function is_host
# Checks whether the current host corresponds to the
# argument given.
#  Arguments
#    <host> ...
#       A comparison between the local host and the given name.
#       Only the first N characters are compared where N is the
#       minimum string length of either comparison variable.
#       If more are provided then a positive is when just
#       one fulfills this check.

function is_host {
    local check=""
    local l=""
    while [[ $# -gt 0 ]]; do
	check="$1"
	l="${#check}"
	shift
	if [[ "x${_host:0:$l}" == "x$check" ]]; then
            return 0
        fi
    done
    return 1
}

# Figure out the number of cores on the machine
which nproc 2>/dev/null > dev/null
if [ $? -eq 0 ]; then
   _n_procs=$(nproc)
else
    _n_procs=2
fi
function set_procs {
    _n_procs=$1
    export NPROCS=$_n_procs
}
if [[ -n "$NPROCS" ]]; then
    set_procs $NPROCS
else
    set_procs $_n_procs
fi

# Try and decipher the frequency of the host
# Returns in MHz
function get_Hz {
    local s=1
    local opt
    if [[ $# -gt 0 ]]; then
	trim_em opt $1
	shift
	case $opt in
	    -GHz)
		s=0.001
		;;
	    -MHz)
		;;
	    -Hz)
		s=1000000
		;;
	    *)
		;;
	esac
	shift
    fi
    # In case there is a frequency stepper we will try and retrieve
    # it from the model-name
    local mname=`grep "model name" /proc/cpuinfo | head -1`
    local cpuHz=`grep "cpu MHz" /proc/cpuinfo | head -1`
    local Hz=2800
    # Now we first try the modelname
    printf '%s' $(($Hz*$s))
}

#  Data containers for the rejection lists
# This considers as the local reject
declare -A _host_reject
_n_host_rejects=0

function _add_rejects {
    local f=$1
    local line
    shift

    # Read the file
    if [[ -e $f ]]; then
	while read -r line || [[ -n "$line" ]]
	do
	    line=${line// /}
	    [[ ${#line} == 0 ]] && continue
	    [[ "${line:0:1}" == '#' ]] && continue
	    let _n_host_rejects++
	    _host_reject[$_n_host_rejects]="$line"
	done < $f
    fi
}

# Add the local rejects
_add_rejects $(get_hostname).reject
_add_rejects local.reject
_add_rejects .reject
