
# Information and functions dealing with the host machine

# We will create a local name of the host
_host="$(hostname -s)"
function get_hostname { echo -n "$_host" ; }

# Figure out the number of cores on the machine
_n_procs=$(grep "cpu cores" /proc/cpuinfo | awk '{print $NF ; exit 0 ;}')
export NPROCS=$_n_procs

# Check the host...
# Takes one argument:
# #1 : the host string to search from the beginning of the host-name...
function is_host {
    local check=""
    local l=""
    while [ $# -gt 0 ]; do
	check="$1"
	l="${#check}"
	shift
	if [ "x${_host:0:$l}" == "x$check" ]; then
            return 0
        fi
    done
    return 1
}

