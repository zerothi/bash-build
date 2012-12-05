# This file should be sourced and used to compile the tools for compiling 
# different libraries.

# Default debugging variables
[ -z "$TIMING" ] && TIMING=0
_NS=1000000000
[ -z "$DEBUG" ]  && DEBUG=0

_HAS_HASH=1
if [ "${BASH_VERSION:0:1}" -lt "4" ]; then
    _HAS_HASH=0
fi


# List of options for archival stuff
let "BUILD_DIR=1 << 0"
let "MAKE_PARALLEL=1 << 1"
let "IS_MODULE=1 << 2"
let "UPDATE_MODULE_NAME=1 << 3"
let "PRELOAD_MODULE=1 << 4"

# We will create a local name of the host
_host="$(hostname -s)"
function get_hostname { echo -n "$_host" ; }

_prefix=""
# Instalation path
function set_installation_path { _prefix=$1 ; }
function get_installation_path { echo -n $_prefix ; }

_c=""
# Instalation path
function set_c { _c=$1 ; }
function get_c { echo -n $_c ; }

_parent_package=""
# The parent package (for instance Python)
function set_parent { _parent_package=$1 ; }
function clear_parent { _parent_package="" ; }
function get_parent { echo -n $_parent_package ; }

_parent_exec=""
# The parent package (for instance Python)
function set_parent_exec { _parent_exec=$1 ; }
function get_parent_exec { echo -n $_parent_exec ; }

_modulepath=""
# Module path for creating the modules
function set_module_path { _modulepath=$1 ; }
function get_module_path { echo -n $_modulepath ; }

_buildpath="./"
# Path for downloading and extracting the packages
function set_build_path { _buildpath=$1 ; for d in $1 $1/.archives $1/.compile ; do mkdir -p $d ; done ; }
function get_build_path { echo -n $_buildpath ; }

_def_module_reqs=""
# Path for downloading and extracting the packages
function set_default_modules { _def_module_reqs="$1" ; }
function get_default_modules { echo -n "$_def_module_reqs" ; }

# Figure out the number of cores on the machine
_n_procs=$(grep "cpu cores" /proc/cpuinfo | awk '{print $NF ; exit 0 ;}')
export NPROCS=$_n_procs


# Based on the extension which command should be called
# to extract the archive
function arc_cmd {
    local ext="$(lc $1)"
    if [ "x$ext" == "xbz2" ]; then
	echo -n "tar jxf"
    elif [ "x$ext" == "xxz" ]; then
	echo -n "tar Jxf"
    elif [ "x$ext" == "xgz" ]; then
	echo -n "tar zxf"
    elif [ "x$ext" == "xtgz" ]; then
	echo -n "tar zxf"
    elif [ "x$ext" == "xtar" ]; then
	echo -n "tar xf"
    elif [ "x$ext" == "xzip" ]; then
	echo -n "unzip"
    elif [ "x$ext" == "xpy" ]; then
	echo -n "ln -fs"
    elif [ "x$ext" == "xlocal" ]; then
	echo -n "echo"
    else
	doerr "Unrecognized extension $ext in [bz2,xz,tgz,gz,tar,zip,py,local]"
    fi
}

#
# Using wget we will collect the giving file
# $1 http path 
# $2 outdirectory
function dwn_file {
    local ext=$(pack_get --ext $1)
    [ "x$ext" == "xlocal" ] && return 0
    local subdir=./
    if [ $# -gt 1 ]; then
	subdir="$2"
    fi
    local archive=$(pack_get --archive $1)
    [ -e $subdir/$archive ] && return 0
    wget $(pack_get --url $1) -O $subdir/$archive
}


#
# Extract file 
# $1 subdirectory of archive
# $2 index or name of archive
function extract_archive {
    local d=$(pack_get --directory $2)
    local cmd=$(arc_cmd $(pack_get --ext $2) )
    local archive=$(pack_get --archive $2)
    [ -d "$1/$d" ] && rm -rf "$1/$d"
    local ext=$(pack_get --ext $1)
    [ "x$ext" == "xlocal" ] && return 0
    docmd $archive $cmd $1/$archive
}

# Local variables for archives to be installed
declare -a _http
# The settings
declare -a _settings
# Where the package is installed
declare -a _install_prefix
# What to check for when installed
declare -a _install_query
# An aliased name
declare -a _alias
# The module name (when one which to load it must be (module load _mod_name[i])
declare -a _mod_name
# The extension of the archive
declare -a _ext
# The pure archive name (i.e. without http)
declare -a _archive
# The package name (i.e. without extension and version, defaults to be the same as alias)
declare -a _package
# The version number of the package
declare -a _version
# The directory of the extracted package
declare -a _directory
# A command sequence of the extracted package (executed before make commands)
declare -a _cmd
# A module sequence which is the requirements for the package
declare -a _mod_req
# Variable for holding information about "non-installation" hosts
declare -a _reject_host
# A variable that contains all the hosts that it will be installed on
declare -a _only_host
# Logical variable determines whether the package has been installed
declare -a _installed
# Adds this to the environment variable in the creation of the modules
declare -a _mod_env
# Local variables for hash tables of index (speed up of execution)
[ $_HAS_HASH -eq 1 ] && \
    declare -A _index
# A separator used for commands that can be given consequitively
_LIST_SEP='ø'
# The counter to hold the archives
_N_archives=-1

# $1 http path
export _add_package_T=0.0
function add_package {
    do_debug --enter add_package
    # Do a timing
    [ $TIMING -ne 0 ] && local time=$(add_timing)
    _N_archives=$(( _N_archives + 1 ))
    # Save the url 
    local url=$1
    _http[$_N_archives]=$url
    # Save the archive name
    local fn=$(basename $url)
    _archive[$_N_archives]=$fn
    # Save the type of archive
    local ext=$(echo -n $fn | awk -F. '{print $NF}')
    _ext[$_N_archives]=$ext
    # Infer what the directory is
    local d=${fn%.*tar.$ext}
    [ "${#d}" -eq "${#fn}" ] && d=${fn%.$ext}
    _directory[$_N_archives]=$d
    # Save the version
    local v=`expr match "$d" '[^-_]*[-_]\([0-9.]*\)'`
    if [ -z "$v" ]; then
	v=`expr match "$d" '[^0-9]*\([0-9.]*\)'`
    fi
    _version[$_N_archives]=$v
    # Save the settings
    _settings[$_N_archives]=0
    # Save the package name...
    local package=${d%$v}
    local len=${#package}
    if [[ ${package:$len-1} =~ [\-\._] ]]; then
	package=${package:0:$len-1}
    fi
    _package[$_N_archives]=$package
    # Save the alias for the package, defaulted to package
    _alias[$_N_archives]=$package
    # Save the hash look-up
    if [ $_HAS_HASH -eq 1 ]; then
	local tmp=${_index[$(lc ${_alias[$_N_archives]})]}
	[ -z "$tmp" ] && \
	    _index[$(lc ${_alias[$_N_archives]})]=$_N_archives
    fi
    # Default the module name to this:
    _installed[$_N_archives]=0
    _mod_name[$_N_archives]=$package/$v/$(get_c)
    _install_prefix[$_N_archives]=$(get_installation_path)/$package/$v/$(get_c)
    # Install default values
    _mod_req[$_N_archives]=""
    _reject_host[$_N_archives]=""
    _only_host[$_N_archives]=""
    [ $TIMING -ne 0 ] && export _add_package_T=$(add_timing $_add_package_T $time)
    do_debug --return add_package
}

# This function allows for setting data related to a package
export _pack_set_T=0.0
export _pack_set_mr_T=0.0
function pack_set {
    do_debug --enter pack_set
    [ $TIMING -ne 0 ] && local time=$(add_timing)
    local index=$_N_archives # Default to this
    local alias="" ; local version="" ; local directory=""
    local settings="0" ; local install="" ; local query=""
    local mod_name="" ; local package="" ; local opt=""
    local cmd="" ; local cmd_flags="" ; local req="" ; local idx_alias=""
    local reject_h="" ; local only_h=""
    while [ $# -gt 0 ]; do
	# Process what is requested
	local opt=$1
	case $opt in
	    --*) opt=${opt:1} ;;
	esac
	shift
	case $opt in
            -C|-command)  cmd="$1" ; shift ;;
            -CF|-command-flag)  cmd_flags="$cmd_flags $1" ; shift ;; # called several times
            -I|-install-prefix)  install="$1" ; shift ;;
            -R|-module-requirement)  
		[ $TIMING -ne 0 ] && local timemr=$(add_timing)
		local tmp="$(pack_get --module-requirement $1)"
		[ ! -z "$tmp" ] && req="$req $tmp"
		req="$req $1" ; shift ;; # called several times
            -Q|-install-query)  query="$1" ; shift ;;
	    -a|-alias)  alias="$1" ; shift ;;
	    -index-alias)  idx_alias="$1" ; shift ;;
            -v|-version)  version="$1" ; shift ;;
            -d|-directory)  directory="$1" ; shift ;;
	    -s|-setting)  settings=$((settings + $1)) ; shift ;; # Can be called several times
	    -m|-module-name)  mod_name="$1" ; shift ;;
	    -prefix-and-module)  mod_name="$1" ; install="$(get_installation_path)/$1" ; shift ;;
	    -p|-package)  package="$1" ; shift ;;
	    -host-only)  only_h="$only_h $1" ; shift ;; # Can be called several times
	    -host-reject)  reject_h="$reject_h $1" ; shift ;; # Can be called several times
	    *)
		# We do a crude check
		# We have an argument
		index=$(get_index $opt)
		shift $#
	esac
    done
    # We now have index to be the correct spanning
    [ ! -z "$cmd" ] && _cmd[$index]="${_cmd[$index]}$cmd $cmd_flags${_LIST_SEP}"
    if [ ! -z "$req" ]; then
	req="${_mod_req[$index]}$req"
	req="$(echo $req | tr ' ' '\n' | sed -e '/^[[:space:]]*$/d' | awk '!_[$0]++' | tr '\n' ' ')"
	[ $TIMING -ne 0 ] && export _pack_set_mr_T=$(add_timing $_pack_set_mr_T $timemr)
	_mod_req[$index]="$req"
    fi
    [ ! -z "$install" ]    && _install_prefix[$index]="$install"
    [ ! -z "$query" ]      && _install_query[$index]="$query"
    if [ ! -z "$alias" ]; then
	[ $_HAS_HASH -eq 1 ] && \
	    unset _index[_alias[$index]] 
	_alias[$index]="$alias"
	[ $_HAS_HASH -eq 1 ] && \
	    _index[$(lc ${_alias[$index]})]=$index
    fi
    if [ ! -z "$idx_alias" ]; then
	[ $_HAS_HASH -eq 1 ] && \
	    _index[$idx_alias]="$index"
    fi
    [ ! -z "$version" ]    && _version[$index]="$version"
    [ ! -z "$directory" ]  && _directory[$index]="$directory"
    [ 0 -ne "$settings" ]  && _settings[$index]="$settings"
    [ ! -z "$mod_name" ]   && _mod_name[$index]="$mod_name"
    [ ! -z "$package" ]    && _package[$index]="$package"
    [ ! -z "$only_h" ]     && _only_host[$index]="${_only_host[$index]}$only_h"
    [ ! -z "$reject_h" ]   && _reject_host[$index]="${_reject_host[$index]}$reject_h"
    [ $TIMING -ne 0 ] && export _pack_set_T=$(add_timing $_pack_set_T $time)
    do_debug --return pack_set
}

# This function allows for setting data related to a package
# Should take at least one parameter (-a|-I...)
export _pack_get_T=0.0
function pack_get {
    do_debug --enter pack_get
    [ $TIMING -ne 0 ] && local time=$(add_timing)
    local opt=$1 # Save the option passed
    case $opt in
	--*) opt=${opt:1} ;;
    esac
    shift
    # We check whether a specific index is requested
    if [ $# -gt 0 ]; then
	while [ $# -gt 0 ]; do
	    index=$(get_index $1)
	    shift
            # Process what is requested
	    case $opt in
		-C|-commands)        echo -n "${_cmd[$index]}" ;;
		-h|-u|-url|-http)    echo -n "${_http[$index]}" ;;
		-R|-module-requirement) 
                                     echo -n "${_mod_req[$index]}" ;;
		-I|-install-prefix|-prefix) 
                                     echo -n "${_install_prefix[$index]}" ;;
		-Q|-install-query)   echo -n "${_install_query[$index]}" ;;
		-a|-alias)           echo -n "${_alias[$index]}" ;;
		-A|-archive)         echo -n "${_archive[$index]}" ;;
		-v|-version)         echo -n "${_version[$index]}" ;;
		-d|-directory)       echo -n "${_directory[$index]}" ;;
		-s|-settings)        echo -n "${_settings[$index]}" ;;
		-m|-module-name)     echo -n "${_mod_name[$index]}" ;;
		-p|-package)         echo -n "${_package[$index]}" ;;
		-e|-ext)             echo -n "${_ext[$index]}" ;;
		-host-only)          echo -n "${_only_host[$index]}" ;;
		-host-reject)        echo -n "${_reject_host[$index]}" ;;
		*)
		    doerr "$1" "No option for pack_get found for $1" ;;
	    esac
	    [ $# -gt 0 ] && echo -n " "
	done
    else
	local index=$_N_archives # Default to this
        # Process what is requested
	case $opt in
	    -C|-commands)        echo -n "${_cmd[$index]}" ;;
	    -h|-u|-url|-http)    echo -n "${_http[$index]}" ;;
	    -R|-module-requirement) 
                echo -n "${_mod_req[$index]}" ;;
	    -I|-install-prefix|-prefix) 
                echo -n "${_install_prefix[$index]}" ;;
	    -Q|-install-query)   echo -n "${_install_query[$index]}" ;;
	    -a|-alias)           echo -n "${_alias[$index]}" ;;
	    -A|-archive)         echo -n "${_archive[$index]}" ;;
	    -v|-version)         echo -n "${_version[$index]}" ;;
	    -d|-directory)       echo -n "${_directory[$index]}" ;;
	    -s|-settings)        echo -n "${_settings[$index]}" ;;
	    -m|-module-name)     echo -n "${_mod_name[$index]}" ;;
	    -p|-package)         echo -n "${_package[$index]}" ;;
	    -e|-ext)             echo -n "${_ext[$index]}" ;;
	    -host-only)          echo -n "${_only_host[$index]}" ;;
	    -host-reject)        echo -n "${_reject_host[$index]}" ;;
	    *)
		doerr $1 "No option for pack_get found for $1" ;;
	esac
    fi
    [ $TIMING -ne 0 ] && export _pack_get_T=$(add_timing $_pack_get_T $time)
    do_debug --return pack_get
}


# Function for editing environment variables
# Mainly used for receiving and appending to variables
function edit_env {
    local opt=$1 # Save the option passed
    case $opt in
	--*) opt=${opt:1} ;;
    esac
    shift
    local echo_env=0
    local append="" ; local prepend=""
    case $opt in
	-g|-get)           echo_env=1 ;;
	-p|-prepend)       prepend="$1" ; shift ;;
	-a|-append)        append="$1" ; shift ;;
	*)
	    doerr $1 "No option for edit_env found for $1" ;;
    esac
    local env=$1
    shift
    [ "$echo_env" -ne "0" ] && echo -n "${!env}" && return 0
    # Process what is requested
    [ ! -z "$append" ] && export ${!env}="${!env}$append"
    [ ! -z "$prepend" ] && eval "export $env='$prepend${!env}'"
}

# Function to return a list of space seperated quantities with prefix and suffix
export _list_T=0.0
function list {
    do_debug --enter list
    local time=$(add_timing)
    local suf="" ; local pre="" ; local lcmd=""
    local cmd ; local retval=""
    # First we collect all options
    local opts=""
    while : ; do
	local opt=$1 # Save the option passed
	case $opt in
	    --*) opt=${opt:1} ;;
	    -*) ;;
	    *)  break ;;
	esac
	shift
	case $opt in
	    -prefix|-p)    pre="$1" ; shift ;;
	    -suffix|-s)    suf="$1" ; shift ;;
	    -loop-cmd|-c)  lcmd="$1" ; shift ;;
	    *)
		opts="$opts $opt" ;;
	esac
    done
    local args=""
    while [ $# -gt 0 ]; do
	args="$args $1"
	shift
    done
    for opt in $opts ; do
	case $opt in
	    -pack-module-reqs)      
		pre="--module-requirement " 
		suf=""
		args="$(pack_get --module-requirement $args) $args" ;;
	    -Wlrpath)
		pre="-Wl,-rpath=" 
		suf="/lib" 
		lcmd="pack_get --install-prefix " ;;
	    -LDFLAGS)   
		pre="-L"  
		suf="/lib" 
		lcmd="pack_get --install-prefix " ;;
	    -INCDIRS) 
		pre="-I" 
		suf="/include" 
		lcmd="pack_get --install-prefix " ;;
	    *)
		[ $TIMING -ne 0 ] && _list_T=$(add_timing $_list_T $time)
		doerr "$opt" "No option for list found for $opt" ;;
	esac
	for cmd in $args ; do
	    if [ ! -z "$lcmd" ]; then
		retval="$retval $pre$($lcmd $cmd)$suf"
	    else
		retval="$retval $pre$cmd$suf"
	    fi
	done
    done
    if [ -z "$retval" ]; then
	for cmd in $args ; do
	    if [ ! -z "$lcmd" ]; then
		retval="$retval $pre$($lcmd $cmd)$suf"
	    else
		retval="$retval $pre$cmd$suf"
	    fi
	done
    fi
    echo -n "$retval"
    [ $TIMING -ne 0 ] && export _list_T=$(add_timing $_list_T $time)
    do_debug --return list
}


# Install the package
export _pack_install_T=0.0
function pack_install {
    local time=$(add_timing)
    do_debug --enter pack_install
    local idx=$_N_archives
    if [ $# -ne 0 ]; then
	idx=$1
    fi
    
    # We install the package
    local archive="$(pack_get --archive $idx)"
    [ $? -ne "0" ] && return 1
	
    # Check that we can install on this host
    local run=0
    local tmp="$(pack_get --host-only $idx)"
    if [ ! -z "$tmp" ]; then
	for host in $tmp ; do
	    local lh="${#host}"
	    [ "x$host" == "x${_host:0:$lh}" ] && \
		run=1
	done
	[ $run -eq 0 ] && return 1
    fi
    local tmp="$(pack_get --host-reject $idx)"
    if [ ! -z "$tmp" ]; then
	run=1
	for host in $tmp ; do
	    local lh="${#host}"
	    [ "x$host" == "x${_host:0:$lh}" ] && \
		run=0
	done
	[ $run -eq 0 ] && return 1
    fi
    
    # Update the module name now
    if [ $(has_setting $UPDATE_MODULE_NAME $idx) ]; then
	pack_set --module-name "$(pack_get --package $idx)/$(pack_get --version $idx)/$(get_c)" $idx
    fi
        
     # Check that the thing is not already installed
    if [ ! -e $(pack_get --install-query $idx) ]; then

	# If the module should be preloaded (for configures which checks that the path exists)
	if [ $(has_setting $PRELOAD_MODULE) ]; then
	    create_module --force \
		-n $(pack_get --alias $idx) \
		-v $(pack_get --version $idx) \
		-M $(pack_get --module-name $idx) \
		-P $(pack_get --install-prefix $idx)
	    # Load module for preloading
	    module load $(pack_get --module-name $idx)
	fi

        # Create the list of requirements
	local module_loads="$(list --loop-cmd 'pack_get --module-name' $(pack_get --module-requirement $idx))"
	for mod in $_def_module_reqs $module_loads ; do
            module load $mod
	done

	# Append all relevant requirements to the relevant environment variables
	# Perhaps this could be generalized with options specifying the ENV_VARS
	old_fcflags="$FCFLAGS"
	export FCFLAGS="$FCFLAGS $(list --LDFLAGS --Wlrpath $(pack_get --module-requirement $idx))"
	old_fflags="$FFLAGS"
	export FFLAGS="$FFLAGS $(list --LDFLAGS --Wlrpath $(pack_get --module-requirement $idx))"
	old_cflags="$CFLAGS"
	export CFLAGS="$CFLAGS $(list --LDFLAGS --Wlrpath $(pack_get --module-requirement $idx))"
	old_cppflags="$CPPFLAGS"
	export CPPFLAGS="$CPPFLAGS $(list --INCDIRS $(pack_get --module-requirement $idx))"
	old_ldflags="$LDFLAGS"
	export LDFLAGS="$LDFLAGS $(list --LDFLAGS --Wlrpath $(pack_get --module-requirement $idx))"
	
        # Show that we will install
	msg_install --start $idx

        # Download archive
	dwn_file $idx $(get_build_path)/.archives
	
        # Extract the archive
	pushd $(get_build_path)/.compile
	[ $? -ne 0 ] && exit 1
	# Remove directory if already existing
	local d=$(pack_get --directory $idx)
	if [ "x$d" != "x." ] || [ "x$d" != "x./" ]; then
	    rm -rf $(pack_get --directory $idx)
	fi
	extract_archive $(get_build_path)/.archives $idx
	pushd $(pack_get --directory $idx)
	[ $? -ne 0 ] && exit 1
	
        # We are now in the package directory
	if [ $(has_setting $BUILD_DIR $idx) ]; then
	    rm -rf build-tmp ; mkdir -p build-tmp ; popd ; pushd $(pack_get --directory $idx)/build-tmp
	fi
	
	# Run all commands
	local cmd="$(pack_get --commands $idx)"
	local -a cmds=()
	IFS="$_LIST_SEP" read -ra cmds <<< "$cmd"
	for cmd in "${cmds[@]}" ; do
	    [ -z "${cmd// /}" ] && continue # Skip the empty commands...
	    docmd "$archive" "$cmd"
	done

	popd

        # Remove compilation directory
	local d=$(pack_get --directory $idx)
	if [ "x$d" != "x." ] || [ "x$d" != "x./" ]; then
	    rm -rf $(pack_get --directory $idx)
	fi
	
	popd
	msg_install --finish $idx
	
	# Unload the requirement modules
	for mod in $module_loads $_def_module_reqs ; do
            module unload $mod
	done

	# Unload the module itself in case of PRELOADING
	if [ $(has_setting $PRELOAD_MODULE) ]; then
	    module unload $(pack_get --module-name $idx)
	fi

	export FCFLAGS="$old_fcflags"
	export FFLAGS="$old_fflags"
	export CFLAGS="$old_cflags"
	export CPPFLAGS="$old_cppflags"
	export LDFLAGS="$old_ldflags"

    else
	msg_install --already-installed $idx
    fi

    _installed[$idx]=1

    if [ $(has_setting $IS_MODULE $idx) ]; then
        # Create the list of requirements
	local reqs="$(list --prefix '-R ' $_def_module_reqs) $(list --prefix '-R ' --loop-cmd 'pack_get --module-name' $(pack_get --module-requirement $idx))"
        # We install the module scripts here:
	create_module \
	    -n $(pack_get --alias $idx) \
	    -v $(pack_get --version $idx) \
	    -M $(pack_get --module-name $idx) \
	    -P $(pack_get --install-prefix $idx) $reqs
    fi
    [ $TIMING -ne 0 ] && export _pack_install_T=$(add_timing $_pack_install_T $time)
    do_debug --return pack_install
}

# Can be used to return the index in the _arrays for the named variable
# $1 is the shortname for what to search for
export _get_index_T=0.0
function get_index {
    do_debug --enter get_index
    local time=$(add_timing)
    local i ; local lookup
    local l=${#1} ; local lc_name=$(lc $1)
    $(isnumber $1)
    if [ "$?" -eq "0" ]; then # We have a number
	[ "$1" -gt "$_N_archives" ] && return 1
	[ "$1" -lt 0 ] && return 1
	echo -n "$1"
	[ $TIMING -ne 0 ] && export _get_index_T=$(add_timing $_get_index_T $time)
	do_debug --return get_index
	return 0
    fi
    if [ $_HAS_HASH -eq 1 ]; then
	i=${_index[$lc_name]}
    else
	i=-1
    fi
    [ -z "${i// /}" ] && i=-1
    #echo "$lc_name $i" >> error.cfg
    if [ "$i" -ge "0" ] && [ "$_N_archives" -le "$i" ]; then
	echo -n "$i"
	[ $TIMING -ne 0 ] && export _get_index_T=$(add_timing $_get_index_T $time)
	do_debug --return get_index
	return 0
    fi
    for lookup in alias archive package ; do
	i=0
	while [ "$i" -le "$_N_archives" ]; do
	    local tmp=$(pack_get --$lookup $i)
	    if [ "x$(lc ${tmp:0:$l})" == "x$lc_name" ]; then
		echo -n "$i"
		[ $TIMING -ne 0 ] && export _get_index_T=$(add_timing $_get_index_T $time)
		do_debug --return get_index
		return 0
	    fi
	    i=$((i+1))
	done
    done
    [ $TIMING -ne 0 ] && export _get_index_T=$(add_timing $_get_index_T $time)
    doerr $1 "Could not find the archive in the list..."
    do_debug --return get_index
}

# Has setting returns 1 for success and 0 for fail
#   $1 : <setting>
#   $2 : <index|name of archive>
function has_setting {
    local tmp
    let "tmp=$1 & $(pack_get -s $2)"
    [ $tmp -gt 0 ] && echo -n "true" && return 0
    echo -n ""
}
    
# Returns the -j <procs> flag for the make command
# If the MAKE_PARALLEL setting has been enabled.
#   $1 : <index of archive>
function get_make_parallel {
    if [ $(has_setting $MAKE_PARALLEL $1) ]; then
	echo -n "-j $_n_procs"
    else
	echo -n ""
    fi
}

# Create a module for loading
# Flags for creating the module:
#   -n <name>
#   -v <version>
#   -M <the module path for output>
#   -P <path> of the installation, 
#            will add <path>/bin to PATH
#            will add <path>/lib[64] to PATH (64 has priority)
#   -r <module requirement> 
#   -H <help message> 
#   -W <what is message>
export _create_module_T=0.0
function create_module {
    do_debug --enter create_module
    local time=$(add_timing)
    local name;local version;local path; local help; local whatis
    local mod_path=""
    local force=0
    local require=""; local conflict=""; local load=""
    while [ $# -gt 0 ]; do
	local opt="$1" # Save the option passed
	case $opt in
	    --*) opt=${opt:1} ;;
	esac
	shift
	case $opt in
	    -n|-name)  name="$1" ; shift ;;
	    -v|-version)  version="$1" ; shift ;;
	    -P|-path)  path="$1" ; shift ;;
	    -p|-module-path)  mod_path="$1" ; shift ;;
	    -M|-module-name)  mod="$1" ; shift ;;
	    -R|-require)  require="$require $1" ; shift ;; # Can be optioned several times
	    -L|-load-module)  load="$load $1" ; shift ;; # Can be optioned several times
	    -C|-conflict-module)  conflict="$conflict $1" ; shift ;; # Can be optioned several times
	    -H|-help)  help="$1" ; shift ;;
	    -W|-what-is)  whatis="$1" ; shift ;;
	    -F|-force)  force=1 ;;
	    *)
		doerr "$opt" "Option for create_module $opt was not recognized"
	esac
    done
    require=${require% } ; load=${load% } ; conflict=${conflict% }

    # Create the file to which we need to install the module script
    if [ -z "$mod_path" ]; then
	local mfile=$(get_module_path)/$mod
    else
	local mfile=$mod_path/$mod
    fi

    # First create directory if it does not exist:
    mkdir -p $(dirname $mfile)
    
    # Create the module file
    cat <<EOF > $mfile
#%Module1.0
#####################################################################

set modulename  $name
set version	$version
set compiler	$(get_c)
set basepath	$path

proc ModulesHelp { } {
    puts stderr "\tLoads \$modulename (\$version)"
}

module-whatis "Loads \$modulename (\$version), compiler \$compiler."

EOF
    # Add pre loaders if needed
    if [ ! -z "$load" ]; then
	    cat <<EOF >> $mfile
# This module will load the following modules
EOF
	for tmp in $load ; do
	    echo "module load $tmp" >> $mfile
	done
	echo "" >> $mfile
    fi

    # Add requirement if needed
    if [ ! -z "$require" ]; then
	cat <<EOF >> $mfile
# List the requirements for loading which this module does want to use
EOF
	for tmp in "$require" ; do
	    echo "prereq $tmp" >> $mfile
	done
	echo "" >> $mfile
    fi
    # Add conflict if needed
    if [ ! -z "$conflict" ]; then
	cat <<EOF >> $mfile
# List the conflicts which this module does not want to take part in
EOF
	for tmp in "$conflict" ; do
	    echo "conflict $tmp" >> $mfile
	done
	echo "" >> $mfile
    fi
    # Add paths if they are available
    _add_module_if -F $force -d "$path/bin" $mfile \
	"prepend-path PATH             \$basepath/bin"
    _add_module_if -F $force -d "$path/man" $mfile \
	"prepend-path MANPATH          \$basepath/man"
    # The LD_LIBRARY_PATH is DANGEROUS!
    #_add_module_if -F $force -d "$path/lib64" $mfile \
#	"prepend-path LD_LIBRARY_PATH  \$basepath/lib64"
#    _add_module_if -F $force -d "$path/lib" $mfile \
#	"prepend-path LD_LIBRARY_PATH  \$basepath/lib"
    _add_module_if -F $force -d "$path/man" $mfile \
	"prepend-path MANPATH  \$basepath/man"
    for PV in 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 ; do
	_add_module_if -F $force -d "$path/lib/python$PV/site-packages" $mfile \
	    "prepend-path PYTHONPATH  \$basepath/lib/python$PV/site-packages"
    done
    [ $TIMING -ne 0 ] && export _create_module_T=$(add_timing $_create_module_T $time)
    do_debug --return create_module
}

# Append to module file dependent on the existance of a
# directory or file
#   -d <directory>
#   -f <file>
#   $1 module file to append to
#   $2-? append this in one line to the file
export __add_module_if_T=0.0
function _add_module_if {
    local time=$(add_timing)
    local d="";local f="" ;local F=0;
    while getopts ":d:f:F:h" opt; do
	case $opt in
            d)  d="$OPTARG" ;;
            f)  f="$OPTARG" ;;
            F)  F="$OPTARG" ;;
            h)  _add_module_if_usage 0 ;;
            \?) echo "Invalid option: -$OPTARG"
		_add_module_if_usage 1 ;;
            :)  echo "Option -$OPTARG requires an argument."
		_add_module_if_usage 1 ;;
	esac
    done ; shift $((OPTIND-1)) ; OPTIND=1
    local mf="$1" ; shift
    local check=""
    [ -n "$d" ] && check=$d ; [ -n "$f" ] && check=$f
    [ "$F" -ne "0" ] && check=$HOME # Force the check to succed
    if [ -e $check ]; then
	cat <<EOF >> $mf
$@
EOF
	[ $TIMING -ne 0 ] && export __add_module_if_T=$(add_timing $__add_module_if_T $time)
	return 0
    fi
    [ $TIMING -ne 0 ] && export __add_module_if_T=$(add_timing $__add_module_if_T $time)
    return 1
}


# Init installation
# Pretty prints some information about the installation
#   $1 : the package name or index
function msg_install {
    local n="" ; local action=0
    while [ $# -gt 1 ]; do
	local opt=$1
	case $opt in
	    --*) opt=${opt:1} ;;
	esac ; shift
	case $opt in
	    -start|-S) n="Installing" ; action=1 ;;
	    -finish|-F) n="Finished" ; action=2 ;;
	    -already-installed) n="Already installed" ; action=3 ;;
	    -message) n="$1" ; action=4 ;;
	esac
    done
    [ "$action" -ne "4" ] && \
	local cmd=$(arc_cmd $(pack_get --ext $1) )
    echo " ================================== "
    echo "            $n"
    if [ "$action" -eq "1" ]; then
	echo " File    : $(pack_get --archive $1)"
	echo " Ext     : $(pack_get --ext $1)"
	echo " Ext CMD : $cmd"
    fi
    if [ "$action" -ne "4" ]; then
	echo " Package : $(pack_get --package $1)"
	if [ "$(pack_get --package $1)" != "$(pack_get --alias $1)" ]; then
	    echo " Alias   : $(pack_get --alias $1)"
	fi	
	echo " Version : $(pack_get --version $1)"
    fi
    if [ "$action" -eq "1" ]; then
	module list
	if [ "$?" -ne "0" ]; then
	    doerr "module list" "Could not show module loaded files"
	fi
    fi
    echo " ================================== "
}


# Do the cmd 
# This will automatically check for the error
function docmd {
    local ar=$1
    shift
    local cmd=($*)
    echo 
    echo " # ================================================================"
    if [ ! -z "$ar" ] ; then
        echo " # Archive: $(pack_get --alias $ar) ($(pack_get --version $ar))"
    fi
    echo " # PWD: "$(pwd)
    echo " # CMD: "${cmd[@]}
    echo " # ================================================================"
    eval ${cmd[@]}
    local st=$?
    if (( $st != 0 )) ; then
	echo "STATUS = $st"
        exit $st;
    fi
}


#################################################
#################################################
###########     Helper functions     ############

# Return the latest index, or the provided one, if any
function _get_true_index {
    if [ $# -eq 0 ]; then
	echo -n "$_N_archives"
    else
	echo -n "$1"
    fi
}

# Return the lowercase equivalent of the argument
function lc { echo "$1" | tr '[A-Z]' '[a-z]' ; }

# Make an error and exit
function exit_on_error {
    if [ "$1" -ne "0" ]; then
	shift
	doerr "$@"
    fi
}

# Make an error and exit
function doerr {
    local prefix="ERROR: "
    for ln in "$@" ; do
        echo "${prefix}${ln}"
        prefix="       "
    done ; exit 1
}

# Help for create_module...
# At the moment only used internally, however
# can be used at the end of the script to make collected modules
function create_module_usage { 
    local f_format="%5s%-20s%s\n"
    echo "Usage:"
    printf "%5s%s\n" "" "${0##*/} -<flags> [opt options]"
    printf "  %s\n" "" "Creates a module in <name>/<sub>/<version>"
    printf "%s\n" "" "The options:"
    printf $f_format "" "-n" "name of the library"
    printf $f_format "" "-v" "version of the library"
    printf $f_format "" "-P" "the base path of the installation"     
    printf $f_format "" "-C" "the conflicts for this module"     
    printf $f_format "" "-R" "the requirements for this module"     
    printf $f_format "" "-H" "the help message in the module"     
    printf $f_format "" "-W" "the 'what-is' message"     
    exit $1
}

function _add_module_if_usage { 
    local f_format="%5s%-20s%s\n"
    echo "Usage:"
    printf "%5s%s\n" "" "${0##*/} -<flags> [opt options]"
    printf "%s\n" "" "The options:"
    printf $f_format "" "-d" "the directory that needs to be checked"     
    printf $f_format "" "-f" "the file that needs to be checked"     
    exit $1
}


# Takes one, optionally two arguments
# $1 is the file..
function get_file_time {
    local format="$1"
    local fdate=$(stat -c "%y" $2)
    echo -n "`date +"$format" --date="$fdate"`"
}

# Check for a number
function isnumber { 
    printf '%d' "$1" &>/dev/null
}


# Update the package version number by looking at the date in the file
function pack_set_file_version {
    local idx=$_N_archives
    [ $# -gt 0 ] && idx=$1
    # Download the archive
    dwn_file $idx $(get_build_path)/.archives
    local v="$(get_file_time %g-%j $(get_build_path)/.archives/$(pack_get --archive $idx))"
    pack_set --version "$v"
     # Default the module name to this:
    pack_set --module-name $(pack_get --package $idx)/$v/$(get_c) $idx
}


# Print a debugging message for the timings
function timings {
    echo ""
    if [ $TIMING -ne 0 ]; then
	echo "###############################################"
	[ $# -ne 0 ] && \
	    echo "    $@" && \
	    echo "-----------------------------------------------"
	echo " Timing for the installation routine:"
	echo "  add_package    : $(get_timing $_add_package_T)"
	echo "  pack_install   : $(get_timing $_pack_install_T)"
	echo "  pack_set       : $(get_timing $_pack_set_T)"
	echo "  pack_set_mr    : $(get_timing $_pack_set_mr_T)"
	echo "  pack_get       : $(get_timing $_pack_get_T)"
	echo "  list           : $(get_timing $_list_T)"
	echo "  get_index      : $(get_timing $_get_index_T)"
	echo "  create_module  : $(get_timing $_create_module_T)"
	echo "  _add_module_if : $(get_timing $__add_module_if_T)"
	echo "###############################################"
    else
	echo " Timing for the installation routines has not been recorded (use TIMING>0)"
    fi
    echo ""
}

function add_timing {
    if [ $# -eq 0 ]; then
	echo -n `date +%s-%N`
    else
	# The current time that has runned...
	#echo $@ >> timing
	local run_s="${1%%\.*}"
	local run_ns="${1##*\.}"
	run_ns=`expr "$run_ns" : '0*\(.*\)'`
	[ -z "$run_ns" ] && run_ns=0
	#echo run_s $run_s run_ns $run_ns >> timing
	local old_s="${2%%-*}"
	local old_ns="${2##*-}"
	old_ns=`expr "$old_ns" : '0*\(.*\)'`
	[ -z "$old_ns" ] && old_ns=0
	#echo old_s $old_s old_ns $old_ns >> timing
	local n_s=`date +%s-%N`
	local new_s="${n_s%%-*}"
	local new_ns="${n_s##*-}"
	new_ns=`expr "$new_ns" : '0*\(.*\)'`
	[ -z "$new_ns" ] && new_ns=0
	#echo new_s $new_s new_ns $new_ns >> timing
	if [ "$old_ns" -gt "$new_ns" ]; then
	    local div_ns=$(($_NS-new_ns+old_ns+run_ns))
	else
	    local div_ns=$((new_ns-old_ns+run_ns))
	fi
	echo -n $((new_s-old_s+run_s+div_ns/$_NS)).$((div_ns-div_ns/$_NS*$_NS))
    fi
}

function get_timing {
    local run_s="${1%%\.*}"
    local run_ns="${1##*\.}"
    if [ "$run_ns" -gt $_NS ]; then
	run_s=$((run_s+run_ns/$_NS))
	run_ns=$((run_ns-run_ns/$_NS*$_NS))
    fi
    printf '%15s s, %4s ms' $run_s $((run_ns/1000000))
}


function do_debug {
    [ $DEBUG -eq 0 ] && return 0
    local n=""
    while [ $# -gt 1 ]; do
	local opt=$1
	case $opt in
	    --*) opt=${opt:1} ;;
	esac ; shift
	case $opt in
	    -enter) n="enter routine: $1" ; shift ;;
	    -return) n="return from routine: $1" ; shift ;;
	esac
    done
    echo $n >> DEBUG
}
