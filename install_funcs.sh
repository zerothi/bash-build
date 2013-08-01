# This file should be sourced and used to compile the tools for compiling 
# different libraries.

# Default debugging variables
[ -z "$TIMING" ] && TIMING=0
_NS=1000000000
[ -z "$DEBUG" ] && DEBUG=0
[ -z "$FORCEMODULE" ] && FORCEMODULE=0

_HAS_HASH=1
if [ "${BASH_VERSION:0:1}" -lt "4" ]; then
    _HAS_HASH=0
fi

_ERROR_FILE=ERROR
# Clean the error file
rm -f $_ERROR_FILE


# List of options for archival stuff
let "BUILD_DIR=1 << 0"
let "MAKE_PARALLEL=1 << 1"
let "IS_MODULE=1 << 2"
let "UPDATE_MODULE_NAME=1 << 3"
let "PRELOAD_MODULE=1 << 4"

_prefix=""
# Instalation path
function set_installation_path {          
    _prefix=$1
    # Create the module folders
    mkdir -p $_prefix/modules
    mkdir -p $_prefix/modules-npa
    mkdir -p $_prefix/modules-npa-apps
}
function get_installation_path { _ps $_prefix ; }

_crt_version=0
# Instalation path
function set_version_def   { _crt_version=1 ; }
function unset_version_def { _crt_version=0 ; }

_parent_package=""
# The parent package (for instance Python)
function set_parent {          _parent_package=$1 ; }
function clear_parent {        _parent_package="" ; }
function get_parent { echo -n $_parent_package ; }

_parent_exec=""
# The parent package (for instance Python)
function set_parent_exec {          _parent_exec=$1 ; }
function get_parent_exec { echo -n $_parent_exec ; }

_modulepath=""
# Module path for creating the modules
function set_module_path {          _modulepath=$1 ; }
function get_module_path { echo -n $_modulepath ; }

_buildpath="./"
# Path for downloading and extracting the packages
function set_build_path {          _buildpath=$1 ; for d in $1 $1/.archives $1/.compile ; do mkdir -p $d ; done ; }
function get_build_path { echo -n $_buildpath ; }


# Add any auxillary commands
source install_aux.sh

# Add the compiler stuff 
source install_compiler.sh

# Add host information
source install_hostinfo.sh


# This function takes one argument
# It is the name of the module that is "hidden", i.e. not
# installed by these scripts. 
# It enables to look them up in the index and thus 
# to use them on equal footing as the others...
function add_hidden_package {
    local mod="$1"
    local package="${mod%/*}"
    local version="${mod#*/}"
    add_package --package $package \
	--version $version \
	path_to_module/$package-$version.tar.gz
    pack_set --index-alias $mod
    pack_set --installed 1 # Make sure it is "installed"
    pack_set --module-name $mod
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
declare -a _mod_opts
# Local variables for hash tables of index (speed up of execution)
[ $_HAS_HASH -eq 1 ] && \
    declare -A _index
# A separator used for commands that can be given consequetively
_LIST_SEP='ø'
# The counter to hold the archives
_N_archives=-1


_def_module_reqs=""
_build_install_path="--package --version"
_build_module_path="--package --version"
# Denote how the module paths and installation paths
# should be
function build_set {
    do_debug --enter build_set
    # We set up default parameters for creating the 
    # default package directory
    local ip=""
    local mp=""
    local def_m=""
    while [ $# -gt 1 ]; do
	local opt=$(trim_em $1) 
	shift
	case $opt in
	    -installation-path|-ip) ip="$1" ; shift ;;
	    -module-path|-mp) mp="$1" ; shift ;;
	    -default-module) 
		def_m="$def_m $1" 
		add_hidden_package $1
		shift ;;
	    *) doerr "$opt" "Not a recognized option for build_set" ;;
	esac
    done
    [ ! -z "$def_m" ] && _def_module_reqs="$def_m"
    [ ! -z "$ip" ] && _build_install_path="$ip"
    [ ! -z "$mp" ] && _build_module_path="$mp"
    do_debug --return build_set
}

# Retrieval of different variables
function build_get {
    do_debug --enter build_get
    # We set up default parameters for creating the 
    # default package directory
    local opt=$(trim_em $1) 
    case $opt in
	-installation-path|-ip) _ps "$_build_install_path" ;;
	-module-path|-mp) _ps "$_build_module_path" ;;
	-default-module) _ps "$_def_module_reqs" ;; 
	*) doerr "$opt" "Not a recognized option for build_get" ;;
    esac
    do_debug --return build_get
}

# Routine for shortcutting a list of values
# through the pack_get 
# i.e.
# pack_list --list-flags "-s /" --package dir
# returns $(pack_get --package)/dir/
function pack_list {
    local opt=""
    local lf=""
    while : ; do
	opt=$(trim_em $1)
	case $opt in
	    -list-flags|-lf) shift ; lf="$1" ; shift ;;
	    *) break ;;
	esac
    done
    local ret=""
    while [ $# -gt 0 ]; do
	opt=$(trim_em $1) ; shift
	case $opt in
	    -*) ret="$ret$(list $lf -c "pack_get $opt" $_N_archives)" ;;
	     *) ret="$ret$(list $lf $opt)" ;;
	esac
    done
    _ps "$ret"
}

# $1 http path
export _add_package_T=0.0
function add_package {
    do_debug --enter add_package
    # Do a timing
    [ $TIMING -ne 0 ] && local time=$(add_timing)
    _N_archives=$(( _N_archives + 1 ))
    # Collect options
    local d=""
    local v=""
    local fn=""
    local package=""
    local alias=""
    while [ $# -gt 1 ]; do
	local opt=$(trim_em $1) 
	shift
	case $opt in
	    -archive|-A) fn=$1 ; shift ;;
	    -directory|-d) d=$1 ; shift ;;
	    -version|-v) v=$1 ; shift ;;
	    -package|-p) package=$1 ; shift ;;
	    -alias|-a) alias=$1 ; shift ;;
	    *) doerr "$opt" "Not a recognized option for add_package" ;;
	esac
    done
    # Save the url 
    local url=$1
    _http[$_N_archives]=$url
    # Save the archive name
    [ -z "$fn" ] && fn=$(basename $url)
    _archive[$_N_archives]=$fn
    # Save the type of archive
    local ext=$(_ps $fn | awk -F. '{print $NF}')
    _ext[$_N_archives]=$ext
    # Infer what the directory is
    local archive_d=${fn%.*tar.$ext}
    [ "${#archive_d}" -eq "${#fn}" ] && archive_d=${fn%.$ext}
    [ -z "$d" ] && d=$archive_d
    _directory[$_N_archives]=$d
    # Save the version
    [ -z "$v" ] && v=`expr match "$archive_d" '[^-_]*[-_]\([0-9.]*\)'`
    if [ -z "$v" ]; then
	v=`expr match "$archive_d" '[^0-9]*\([0-9.]*\)'`
    fi
    _version[$_N_archives]=$v
    # Save the settings
    _settings[$_N_archives]=0
    # Save the package name...
    [ -z "$package" ] && package=${d%$v}
    local len=${#package}
    if [[ ${package:$len-1} =~ [\-\._] ]]; then
	package=${package:0:$len-1}
    fi
    _package[$_N_archives]=$package
    # Save the alias for the package, defaulted to package
    [ -z "$alias" ] && alias=$package
    _alias[$_N_archives]=$alias
    # Save the hash look-up
    if [ $_HAS_HASH -eq 1 ]; then
	local tmp="${_index[$(lc $alias)]}"
    local lc_name="$(lc $alias)"
	if [ ! -z "$tmp" ]; then
	    _index[$lc_name]="$tmp $_N_archives"
	else
	    _index[$lc_name]="$_N_archives"
	fi
    fi
    # Default the module name to this:
    _installed[$_N_archives]=0
    _mod_name[$_N_archives]=$(pack_list -lf "-X -p /" $_build_module_path)
    #_mod_name[$_N_archives]=$package/$v/$(get_c)
    _mod_name[$_N_archives]=${_mod_name[$_N_archives]%/}
    _mod_name[$_N_archives]=${_mod_name[$_N_archives]#/}
    _install_prefix[$_N_archives]=$(pack_list -lf "-X -s /" $_build_install_path)
    _install_prefix[$_N_archives]=${_install_prefix[$_N_archives]%/}
    # Install default values
    _mod_req[$_N_archives]="$(build_get --default-module)"
    _reject_host[$_N_archives]=""
    _only_host[$_N_archives]=""
    msg_install --message "Added $package[$v] to the install list"
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
    local reject_h="" ; local only_h="" ; local inst=2
    local mod_opt=""
    while [ $# -gt 0 ]; do
	# Process what is requested
	local opt="$(trim_em $1)"
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
	    -index-alias)  idx_alias="$1" ; shift ;; ## opted for deletion...
	    -installed)  inst=1 ; shift ;;
            -v|-version)  version="$1" ; shift ;;
            -d|-directory)  directory="$1" ; shift ;;
	    -s|-setting)  settings=$((settings + $1)) ; shift ;; # Can be called several times
	    -m|-module-name)  mod_name="${1%/}" ; shift ;;
	    -module-opt)  mod_opt="$mod_opt $1" ; shift ;;
	    -prefix-and-module)  mod_name="$1" ; install="$(get_installation_path)/$1" ; shift ;;
	    -p|-package)  package="$1" ; shift ;;
	    -host-only)  only_h="$only_h $1" ; shift ;; # Can be called several times
	    -host-reject)  reject_h="$reject_h $1" ; shift ;; # Can be called several times
	    *)
		# We do a crude check
		# We have an argument
		index=$(get_index $opt)
		shift $# ;; 
	esac
    done
    # We now have index to be the correct spanning
    [ ! -z "$cmd" ] && _cmd[$index]="${_cmd[$index]}$cmd $cmd_flags${_LIST_SEP}"
    if [ ! -z "$req" ]; then
	req="${_mod_req[$index]} $req"
	# Remove dublicates:
	req="$(rem_dup $req)"
	_mod_req[$index]="$req"
	[ $TIMING -ne 0 ] && export _pack_set_mr_T=$(add_timing $_pack_set_mr_T $timemr)
    fi
    [ ! -z "$install" ]    && _install_prefix[$index]="$install"
    [ "$inst" -ne "2" ]    && _installed[$index]="$inst"
    [ ! -z "$query" ]      && _install_query[$index]="$query"
    if [ ! -z "$alias" ]; then
	local tmp="" ; local v=""
	local lc_name="$(lc ${_alias[$index]})"
	if [ $_HAS_HASH -eq 1 ]; then
	    for v in ${_index[$lc_name]} ; do
		[ "$v" -ne "$index" ] && tmp="$tmp $v"
	    done
	    if [ -z "$tmp" ]; then
		unset _index[$lc_name]
	    else
		_index[$lc_name]="$tmp"
	    fi
	fi
	_alias[$index]="$alias"
	local lc_name="$(lc $alias)"
	if [ $_HAS_HASH -eq 1 ]; then
	    tmp="${_index[$lc_name]}"
	    if [ -z "$tmp" ]; then
		_index[$lc_name]="$index"
	    else
		_index[$lc_name]="$tmp $index"
	    fi
	fi
    fi
    if [ ! -z "$idx_alias" ]; then  ## opted for deletion... (superseeded by explicit version comparisons...)
	[ $_HAS_HASH -eq 1 ] && \
	    _index[$idx_alias]="$index"
    fi
    [ ! -z "$mod_opt" ]    && _mod_opts[$index]="${_mod_opts[$index]}$mod_opt"
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
    local opt="$(trim_em $1)" # Save the option passed
    case $opt in
	-*) ;;
	*)
	    doerr "$1" "Could not determine the option for pack_get" ;;	    
    esac
    shift
    # We check whether a specific index is requested
    if [ $# -gt 0 ]; then
	while [ $# -gt 0 ]; do
	    local index=$(get_index $1)
	    #echo $1 $index >&2
	    shift
            # Process what is requested
	    case $opt in
		-C|-commands)        _ps "${_cmd[$index]}" ;;
		-h|-u|-url|-http)    _ps "${_http[$index]}" ;;
		-R|-module-requirement) 
                                     _ps "${_mod_req[$index]}" ;;
		-I|-install-prefix|-prefix) 
                                     _ps "${_install_prefix[$index]}" ;;
		-Q|-install-query)   _ps "${_install_query[$index]}" ;;
		-a|-alias)           _ps "${_alias[$index]}" ;;
		-A|-archive)         _ps "${_archive[$index]}" ;;
		-v|-version)         _ps "${_version[$index]}" ;;
		-d|-directory)       _ps "${_directory[$index]}" ;;
		-s|-settings)        _ps "${_settings[$index]}" ;;
		-installed)          _ps "${_installed[$index]}" ;;
		-m|-module-name)     _ps "${_mod_name[$index]}" ;;
		-module-opt)         _ps "${_mod_opts[$index]}" ;;
		-p|-package)         _ps "${_package[$index]}" ;;
		-e|-ext)             _ps "${_ext[$index]}" ;;
		-host-only)          _ps "${_only_host[$index]}" ;;
		-host-reject)        _ps "${_reject_host[$index]}" ;;
		*)
		    doerr "$1" "No option for pack_get found for $1" ;;
	    esac
	    [ $# -gt 0 ] && _ps " "
	done
    else
	local index=$_N_archives # Default to this
        # Process what is requested
	case $opt in
	    -C|-commands)        _ps "${_cmd[$index]}" ;;
	    -h|-u|-url|-http)    _ps "${_http[$index]}" ;;
	    -R|-module-requirement) _ps "${_mod_req[$index]}" ;;
	    -I|-install-prefix|-prefix) _ps "${_install_prefix[$index]}" ;;
	    -Q|-install-query)   _ps "${_install_query[$index]}" ;;
	    -a|-alias)           _ps "${_alias[$index]}" ;;
	    -A|-archive)         _ps "${_archive[$index]}" ;;
	    -v|-version)         _ps "${_version[$index]}" ;;
	    -d|-directory)       _ps "${_directory[$index]}" ;;
	    -s|-settings)        _ps "${_settings[$index]}" ;;
	    -installed)          _ps "${_installed[$index]}" ;;
	    -module-opt)         _ps "${_mod_opts[$index]}" ;;
	    -m|-module-name)     _ps "${_mod_name[$index]}" ;;
	    -p|-package)         _ps "${_package[$index]}" ;;
	    -e|-ext)             _ps "${_ext[$index]}" ;;
	    -host-only)          _ps "${_only_host[$index]}" ;;
	    -host-reject)        _ps "${_reject_host[$index]}" ;;
	    *)
		doerr $1 "No option for pack_get found for $1" ;;
	esac
    fi
    [ $TIMING -ne 0 ] && export _pack_get_T=$(add_timing $_pack_get_T $time)
    do_debug --return pack_get
}

function pack_installed {
    local ret=$(pack_get --installed $1)
    [ -z "$ret" ] && ret=0
    _ps $ret
}


# Function for editing environment variables
# Mainly used for receiving and appending to variables
function edit_env {
    local opt=$(trim_em $1) # Save the option passed
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
    [ "$echo_env" -ne "0" ] && _ps "${!env}" && return 0
    # Process what is requested
    [ ! -z "$append" ] && export ${!env}="${!env}$append"
    [ ! -z "$prepend" ] && eval "export $env='$prepend${!env}'"
}



function install_all {
    # First we collect all options
    local i=0
    while [ $# -ne 0 ]; do
	local opt="$(trim_em $1)" # Save the option passed
	shift
	case $opt in
	    -from|-f)    i="$(get_index $1)" ; shift ;;
	    *) shift ;;
	esac
    done
    for i in `seq $i $_N_archives` ; do
	pack_install $i
    done
}

# Install the package
export _pack_install_T=0.0
function pack_install {
    local time=$(add_timing)
    local mod_reqs=""
    do_debug --enter pack_install
    local idx=$_N_archives
    if [ $# -ne 0 ]; then
	idx=$(get_index $1) ; shift
    fi

    # First a simple check that it hasn't already been installed...
    if [ -e $(pack_get --install-query $idx) ]; then
	_installed[$idx]=1
    fi

    # Save the module requirements for later...
    mod_reqs="$(pack_get --module-requirement $idx)"

    # If it is installed...
    if [ $(pack_get --installed $idx) -eq 1 ]; then
	msg_install --already-installed $idx
	if [ $FORCEMODULE -eq 0 ]; then
	    [ $TIMING -ne 0 ] && export _pack_install_T=$(add_timing $_pack_install_T $time)
	    do_debug --return pack_install
	    return 0
	fi
    fi

    # Check that we can install on this host
    local run=1
    local tmp="$(pack_get --host-only $idx)"
    if [ ! -z "$tmp" ]; then
	run=0
	for host in $tmp ; do
	    if $(is_host $host) ; then
		run=1 && break
	    fi
	done
    fi
    local tmp="$(pack_get --host-reject $idx)"
    if [ ! -z "$tmp" ]; then
	# Run should be 1 when we get here...
	for host in $tmp ; do
	    if $(is_host $host) ; then
		run=0 && break
	    fi
	done
    fi

    # Make sure that every package before is installed...
    for tmp in $mod_reqs ; do
	[ -z "$tmp" ] && break
	if [ $(pack_get --installed $tmp) -eq 0 ]; then
	    pack_install $tmp
	fi
	# Capture packages that has been rejected.
	# If it depends on rejected packages, it must itself be rejected.
	if [ $(pack_get --installed $tmp) -eq -1 ]; then
	    run=0
	    break
	fi
    done

    if [ $run -eq 0 ]; then
	# Notify other required stuff that this can not be installed.
	pack_set --installed -1 $idx
	msg_install --message "Installation rejected for $(pack_get --package $idx)" $idx
	[ $TIMING -ne 0 ] && export _pack_install_T=$(add_timing $_pack_install_T $time)
	do_debug --return pack_install
	return 1
    fi

    # Update the module name now
    if $(has_setting $UPDATE_MODULE_NAME $idx) ; then
	pack_set --module-name "$(pack_get --package $idx)/$(pack_get --version $idx)/$(get_c)" $idx
    fi
        
    # Check that the package is not already installed
    if [ $(pack_get --installed $idx) -eq 0 ]; then

	# If the module should be preloaded (for configures which checks that the path exists)
	if $(has_setting $PRELOAD_MODULE) ; then
	    create_module --force \
		-n "$(pack_get --alias $idx)" \
		-v "$(pack_get --version $idx)" \
		-M "$(pack_get --module-name $idx)" \
		-P "$(pack_get --install-prefix $idx)"
	    # Load module for preloading
	    module load $(pack_get --module-name $idx)
	fi

        # Create the list of requirements
	local module_loads="$(list --loop-cmd 'pack_get --module-name' $mod_reqs)"
	#echo Will load: $_def_module_reqs $module_loads
	#module avail
	module load $_def_module_reqs $module_loads
	#module list

	# Append all relevant requirements to the relevant environment variables
	# Perhaps this could be generalized with options specifying the ENV_VARS
	local tmp="$(list --LDFLAGS --Wlrpath $mod_reqs)"
	old_fcflags="$FCFLAGS"
	export FCFLAGS="$FCFLAGS $tmp"
	old_fflags="$FFLAGS"
	export FFLAGS="$FFLAGS $tmp"
	old_cflags="$CFLAGS"
	export CFLAGS="$CFLAGS $tmp"
	old_cppflags="$CPPFLAGS"
	export CPPFLAGS="$CPPFLAGS $(list --INCDIRS $mod_reqs)"
	old_ldflags="$LDFLAGS"
	export LDFLAGS="$LDFLAGS $tmp"
	#old_ld_lib_path="$LD_LIBRARY_PATH"
	#export LD_LIBRARY_PATH="$LD_LIBRARY_PATH$(list --prefix : --loop-cmd 'pack_get --install-prefix' --suffix '/lib' $mod_reqs)"
	
        # Show that we will install
	msg_install --start $idx

        # Download archive
	dwn_file $idx $(get_build_path)/.archives

        # Extract the archive
	pushd $(get_build_path)/.compile 1> /dev/null
	[ $? -ne 0 ] && exit 1
	# Remove directory if already existing
	local d=$(pack_get --directory $idx)
	if [ "x$d" != "x." ] && [ "x$d" != "x./" ]; then
	    rm -rf $(pack_get --directory $idx)
	fi
	extract_archive $(get_build_path)/.archives $idx
	pushd $(pack_get --directory $idx) 1> /dev/null
	[ $? -ne 0 ] && exit 1

        # We are now in the package directory
	if $(has_setting $BUILD_DIR $idx) ; then
	    rm -rf build-tmp ; mkdir -p build-tmp ; popd 1> /dev/null 
	    pushd $(pack_get --directory $idx)/build-tmp 1> /dev/null
	fi
	
	# Run all commands
	local cmd="$(pack_get --commands $idx)"
	local -a cmds=()
	IFS="$_LIST_SEP" read -ra cmds <<< "$cmd"
	for cmd in "${cmds[@]}" ; do
	    [ -z "${cmd// /}" ] && continue # Skip the empty commands...
	    docmd "$idx" "$cmd"
	done

	popd 1> /dev/null

        # Remove compilation directory
	local d=$(pack_get --directory $idx)
	if [ "x$d" != "x." ] && [ "x$d" != "x./" ]; then
	    rm -rf $(pack_get --directory $idx)
	fi
	
	popd 1> /dev/null
	msg_install --finish $idx
	
	# Unload the requirement modules
	for mod in $module_loads $_def_module_reqs ; do
            module unload $mod
	done

	# Unload the module itself in case of PRELOADING
	if $(has_setting $PRELOAD_MODULE) ; then
	    module unload $(pack_get --module-name $idx)
	    # We need to clean up, in order to force the
	    # module creation.
	    rm -f $(get_module_path)/$(pack_get --module-name $idx)
	fi

	export FCFLAGS="$old_fcflags"
	export FFLAGS="$old_fflags"
	export CFLAGS="$old_cflags"
	export CPPFLAGS="$old_cppflags"
	export LDFLAGS="$old_ldflags"
	#export LD_LIBRARY_PATH="$old_ld_lib_path"

    fi

    # For sure it is now installed...
    _installed[$idx]=1

    if $(has_setting $IS_MODULE $idx) ; then
        # Create the list of requirements
	local reqs="$(list --prefix '-R ' $mod_reqs)"
        # We install the module scripts here:
	create_module \
	    -n $(pack_get --alias $idx) \
	    -v $(pack_get --version $idx) \
	    -M $(pack_get --module-name $idx) \
	    -P $(pack_get --install-prefix $idx) $reqs $(pack_get --module-opt $idx)
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
    local i ; local lookup ; local all=0
    while [ $# -gt 1 ]; do
	local opt=$(trim_em $1) ; shift
	case $opt in
	    -all|-a) all=1  ;;
	esac
    done
    [ ${#1} -eq 0 ] && return 1
    # Save the thing that we want to process...
    local name=$(var_spec "$1")
    local version=$(var_spec -s "$1")
    local l=${#name} ; local lc_name="$(lc $name)"
    if $(isnumber $name) ; then # We have a number
	[ "$name" -gt "$_N_archives" ] && return 1
	[ "$name" -lt 0 ] && return 1
	_ps "$name"
	[ $TIMING -ne 0 ] && export _get_index_T=$(add_timing $_get_index_T $time)
	do_debug --return get_index
	return 0
    fi
    if [ $_HAS_HASH -eq 1 ]; then
	if [[ ${_index[$lc_name]} ]]; then
	    i=0
	else
	    do_debug --msg "HELLO not found $name"
	    [ $TIMING -ne 0 ] && export _get_index_T=$(add_timing $_get_index_T $time)
	    do_debug --return get_index
	    return 1
	fi
	if [ $all -eq 1 ]; then
	    _ps "${_index[$lc_name]}"
	    [ $TIMING -ne 0 ] && export _get_index_T=$(add_timing $_get_index_T $time)
	    do_debug --return get_index
	    return 0
	else
	    local v=""
	    i=-1
            # Select the latest per default..
	    for v in ${_index[$lc_name]} ; do
		if [ ! -z "$version" ]; then
		    if [ "$(pack_get --version $v)" == "$version" ]; then
			i="$v"
			break
		    fi
		else
		    i="$v"
		fi
	    done
	fi
    else
	i=-1
    fi
    [ -z "${i// /}" ] && i=-1
    #echo "$lc_name $version $i $l" >&2
    if [ "0" -le "$i" ] && [ "$i" -le "$_N_archives" ]; then
	_ps "$i"
	[ $TIMING -ne 0 ] && export _get_index_T=$(add_timing $_get_index_T $time)
	do_debug --return get_index
	return 0
    fi
    for lookup in alias archive package ; do
	for i in `seq 0 $_N_archives` ; do
	    local tmp=$(pack_get --$lookup $i)
	    if [ "x$(lc ${tmp:0:$l})" == "x$lc_name" ]; then
		if [ ! -z "$version" ]; then
		    if [ "$(pack_get --version $i)" != "$version" ]; then
            # We need to continue the loop as the version did not match...
			continue 
		    fi
		fi
		_ps "$i"
		[ $TIMING -ne 0 ] && export _get_index_T=$(add_timing $_get_index_T $time)
		do_debug --return get_index
		return 0
	    fi
	done
    done
    [ $TIMING -ne 0 ] && export _get_index_T=$(add_timing $_get_index_T $time)
    #doerr "$name" "Could not find the archive in the list..."
    do_debug --return get_index
    return 1
}

# Has setting returns 1 for success and 0 for fail
#   $1 : <setting>
#   $2 : <index|name of archive>
function has_setting {
    local tmp
    let "tmp=$1 & $(pack_get -s $2)"
    [ $tmp -gt 0 ] && return 0
    return 1
}
    
# Returns the -j <procs> flag for the make command
# If the MAKE_PARALLEL setting has been enabled.
#   $1 : <index of archive>
function get_make_parallel {
    if $(has_setting $MAKE_PARALLEL $1) ; then
	_ps "-j $_n_procs"
    else
	_ps ""
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
    local name;local version;local path; local help; local whatis; local opt
    local env="" ; local tmp=""
    local mod_path=""
    local force=0 ; local no_install=0
    local require=""; local conflict=""; local load=""
    while [ $# -gt 0 ]; do
	opt="$(trim_em $1)" ; shift
	case $opt in
	    -n|-name)  name="$1" ; shift ;;
	    -v|-version)  version="$1" ; shift ;;
	    -P|-path)  path="$1" ; shift ;;
	    -p|-module-path)  mod_path="$1" ; shift ;;
	    -M|-module-name)  mod="$1" ; shift ;;
	    -R|-require)  require="$require $1" ; shift ;; # Can be optioned several times
	    -L|-load-module)  load="$load $1" ; shift ;; # Can be optioned several times
	    -C|-conflict-module)  conflict="$conflict $1" ; shift ;; # Can be optioned several times
	    -set-ENV)      env="$env s$1" ; shift ;; # Can be optioned several times
	    -prepend-ENV)      env="$env p$1" ; shift ;; # Can be optioned several times
	    -append-ENV)      env="$env a$1" ; shift ;; # Can be optioned several times
	    -H|-help)  help="$1" ; shift ;;
	    -W|-what-is)  whatis="$1" ; shift ;;
	    -F|-force)  force=1 ;;
	    *)
		doerr "$opt" "Option for create_module $opt was not recognized"
	esac
    done
    require="$(rem_dup $require)"
    load="$(rem_dup $load)"
    conflict="$(rem_dup $conflict)"

    # Create the file to which we need to install the module script
    if [ -z "$mod_path" ]; then
	local mfile=$(get_module_path)
    else
	local mfile=$mod_path
    fi
    [ -n "$mod" ] && mfile=$mfile/$mod
    
    # If the file exists simply return
    if [ -e "$mfile" ] && [ 0 -eq $force ]; then
        [ $TIMING -ne 0 ] && export _create_module_T=$(add_timing $_create_module_T $time)
        do_debug --return create_module
        return 0
    fi

    # First create directory if it does not exist:
    mkdir -p $(dirname $mfile)
    
    # Create the module file
    cat <<EOF > "$mfile"
#%Module1.0
#####################################################################

set modulename  $name
set version	$version
EOF
    tmp="$(get_c)"
    if [ ! -z "$tmp" ]; then
	tmp=", compiler \$compiler"
	cat <<EOF >> "$mfile"
set compiler	$(get_c)
EOF
    fi

    cat <<EOF >> "$mfile"
set basepath	${path//$version/\$version}

proc ModulesHelp { } {
    puts stderr "\tLoads \$modulename (\$version)"
}

module-whatis "Loads \$modulename (\$version)$tmp."

EOF
    # Add pre loaders if needed
    if [ ! -z "${load// /}" ]; then
	    cat <<EOF >> $mfile
# This module will load the following modules:
EOF
	for tmp in $load ; do
	    if [ $(pack_get --installed $tmp) -ne 0 ]; then
		local tmp_load=$(pack_get --module-name $tmp)
		echo "module load $tmp_load" >> $mfile
	    elif [ $force -eq 0 ]; then
		no_install=1
	    fi
	done
	echo "" >> $mfile
    fi    

    # Add requirement if needed
    if [ ! -z "${require// /}" ]; then
	cat <<EOF >> $mfile
# Requirements for the module:
EOF
	for tmp in $require ; do
	    if [ $(pack_get --installed $tmp ) -ne 0 ]; then
		local tmp_load=$(pack_get --module-name $tmp)
		echo "prereq $tmp_load" >> $mfile
	    elif [ $force -eq 0 ]; then
		no_install=1
	    fi
	done
	echo "" >> $mfile
    fi
    # Add conflict if needed
    if [ ! -z "${conflict// /}" ]; then
	cat <<EOF >> $mfile
# Modules which is in conflict with this module:
EOF
	for tmp in $conflict ; do
	    if [ $(pack_get --installed $tmp ) -ne 0 ]; then
		local tmp_load=$(pack_get --module-name $tmp)
		echo "conflict $tmp_load" >> $mfile
	    elif [ $force -eq 0 ]; then
		no_install=1
	    fi
	done
	echo "" >> $mfile
    fi
    # Add specific envs if needed
    if [ ! -z "${env// /}" ]; then
	cat <<EOF >> $mfile
# Specific environment variables:
EOF
	for tmp in $env ; do
	    # Partition into [s|a|p]
	    local opt=${tmp:0:1}
	    local lenv=${tmp%%=*}
	    lenv=${lenv:1}
	    local lval=${tmp##*=}
            # Add paths if they are available
	    if [ "$opt" == "s" ]; then
		_add_module_if -F $force -d "$lval" $mfile \
		    "setenv $lenv $lval"
	    elif [ "$opt" == "p" ]; then
		_add_module_if -F $force -d "$lval" $mfile \
		    "prepend-path $lenv $lval"
	    elif [ "$opt" == "a" ]; then
		_add_module_if -F $force -d "$lval" $mfile \
		    "append-path $lenv $lval"
	    fi		
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
    _add_module_if -F $force -d "$path/lib/python" $mfile \
	"prepend-path PYTHONPATH  \$basepath/lib/python"
    for PV in 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 ; do
	_add_module_if -F $force -d "$path/lib/python$PV/site-packages" $mfile \
	    "prepend-path PYTHONPATH  \$basepath/lib/python$PV/site-packages"
    done
    if [ $no_install -eq 1 ] && [ $force -eq 0 ]; then
	rm -f $mfile
    fi
    # If we are to create the default version module we 
    # can add this version to the .version file:
    if [ $_crt_version -eq 1 ]; then
	cat <<EOF > $(dirname $mfile)/.version
#%Module1.0
#####################################################################
set ModulesVersion $(basename $mfile)
EOF
    fi
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
	local opt=$(trim_em $1) ; shift
	case $opt in
	    -start|-S) n="Installing" ; action=1 ;;
	    -finish|-F) n="Finished" ; action=2 ;;
	    -already-installed) n="Already installed" ; action=3 ;;
	    -message) n="$1" ; shift ; action=4 ;;
	    *) break ;;
	esac
    done
    if [ $# -gt 0 ]; then
	local pack=$1
    else
	local pack=$_N_archives
    fi
    [ "$action" -ne "4" ] && \
	local cmd=$(arc_cmd $(pack_get --ext $pack) )
    echo " ================================== "
    echo "   $n"
    if [ "$action" -eq "1" ]; then
	echo " File    : $(pack_get --archive $pack)"
	echo " Ext     : $(pack_get --ext $pack)"
	echo " Ext CMD : $cmd"
    fi
    if [ "$action" -ne "4" ]; then
	echo " Package : $(pack_get --package $pack)"
	if [ "$(pack_get --package $pack)" != "$(pack_get --alias $pack)" ]; then
	    echo " Alias   : $(pack_get --alias $pack)"
	fi	
	echo " Version : $(pack_get --version $pack)"
    fi
    if [ "$action" -eq "1" ]; then
	module list 2>&1
	if [ "$?" -ne "0" ]; then
	    doerr "module list" "Could not show module loaded files"
	fi
    fi
    echo " ================================== "
}



# Do the cmd 
# This will automatically check for the error
function docmd {
    local ar="$1"
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
	_ps "$_N_archives"
    else
	_ps "$1"
    fi
}

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
        echo "${prefix}${ln}" >> $_ERROR_FILE
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
	_ps `date +%s-%N`
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
	_ps $((new_s-old_s+run_s+div_ns/$_NS)).$((div_ns-div_ns/$_NS*$_NS))
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
	local opt=$(trim_em $1) ; shift
	case $opt in
	    -msg) n="$1" ; shift ;;
	    -enter) n="enter routine: $1" ; shift ;;
	    -return) n="return from routine: $1" ; shift ;;
	esac
    done
    echo $n >> DEBUG
}
