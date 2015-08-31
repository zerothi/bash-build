
# Information and functions dealing with the host machine

# We will create a local name of the host
_host="$(hostname -s)"
function get_hostname {
    _ps "$_host"
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
_n_procs=$(grep "cpu cores" /proc/cpuinfo | awk '{print $NF ; exit 0 ;}')
if [ -z "$NPROCS" ]; then
    export NPROCS=$_n_procs
fi

#  Data containers for the rejection lists
# This considers as the local reject
declare -A _host_reject
_n_host_rejects=0

function _add_rejects {
    local f=$1
    local -a lines
    local tmp
    shift

    # Read the file
    if [[ -e $f ]]; then
	read -d '\n' -a lines < $f
	for tmp in ${lines[@]} ; do
	    let _n_host_rejects++
	    _host_reject[$_n_host_rejects]="$tmp"
	done
    fi
}

# Add the local rejects
_add_rejects local.reject
_add_rejects .reject
