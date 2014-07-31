# This file should be sourced and used to compile the tools for compiling 
# different libraries.

# Default debugging variables
_NS=1000000000
[ -z "$DEBUG" ] && DEBUG=0
[ -z "$FORCEMODULE" ] && FORCEMODULE=0
[ -z "$DOWNLOAD" ] && DOWNLOAD=0

if [ ${BASH_VERSION%%.*} -lt 4 ]; then
    do_err "$BASH_VERSION" "Installation requires to use BASH >= 4.x.x"
fi

_DEBUG_COUNTER=0
function debug { echo "Debug: ${_DEBUG_COUNTER} $@" ; let _DEBUG_COUNTER++ ; }

_ERROR_FILE=ERROR
# Clean the error file
rm -f $_ERROR_FILE

# Whether we should create TCL or LUA module files
_module_format='TCL'

# List of options for archival stuff
let "BUILD_DIR=1 << 0"
let "MAKE_PARALLEL=1 << 1"
let "IS_MODULE=1 << 2"
let "PRELOAD_MODULE=1 << 3"

# A separator used for commands that can be given consequetively
_LIST_SEP='ø'

# The index of the default build...
_b_def_idx=0
# Name of setup (lookup-purposes)
declare -a _b_name
# source file
declare -a _b_source
# build path
declare -a _b_build_path
_b_build_path[$_b_def_idx]=$(pwd)/.compile
# installation prefix
declare -a _b_prefix
# module installation prefix
declare -a _b_mod_prefix
# how to build the full installation path
declare -a _b_build_prefix
_b_build_prefix[$_b_def_idx]="--package --version"
# how to build the full module path
declare -a _b_build_mod_prefix
_b_build_mod_prefix[$_b_def_idx]="--package --version"
# default modules for this build
declare -a _b_def_mod_reqs
# Pointers of lookup
declare -A _b_index
_N_b=-1

_crt_version=0

_parent_package=""
# The parent package (for instance Python)
function set_parent {       _parent_package=$1 ; }
function clear_parent {     _parent_package="" ; }
function get_parent { _ps "$_parent_package" ; }

_parent_exec=""
# The parent package (for instance Python)
function set_parent_exec {       _parent_exec=$1 ; }
function get_parent_exec { _ps "$_parent_exec" ; }

# Add any auxillary commands
source install_aux.sh

# Add the compiler stuff 
source install_compiler.sh

# Add host information
source install_hostinfo.sh

# The place of all the archives
_archives="$(pwd)/.archives"

# Denote how the module paths and installation paths should be
function build_set {
    [ $DEBUG -ne 0 ] && do_debug --enter build_set
    # We set up default parameters for creating the 
    # default package directory
    local def_mod_first=1
    while [ $# -gt 0 ]; do
	local opt=$(trim_em $1)
	local spec=$(var_spec -s $opt)
	if [ -z "$spec" ]; then
	    local b_idx=0
	else
	    local b_idx=$(get_index --hash-array "_b_index" $spec)
	fi
	if [ -z "$b_idx" ]; then
	    doerr "$spec" "Unrecognized build, please create it first"
	    exit 1
	fi
	opt=$(var_spec $opt)
	shift
	case $opt in
	    -archive-path|-ap)
		_archives="$1"
		shift ;;
	    -installation-path|-ip)
		[ $b_idx -eq 0 ] && _prefix="$1"
		_b_prefix[$b_idx]="$1"
		mkdir -p $1
    		shift ;;
	    -module-path|-mp) 
		[ $b_idx -eq 0 ] && _modulepath="$1"
		_b_mod_prefix[$b_idx]="$1"
                # Create the module folders
		mkdir -p $1
		shift ;;
	    -build-path|-bp) 
		_buildpath="$1" 
		mkdir -p $_buildpath
		shift ;;
	    -build-installation-path|-bip) 
		[ $b_idx -eq 0 ] && _build_install_path="$1"
		_b_build_prefix[$b_idx]="$1"
		shift ;;
	    -build-module-path|-bmp) 
		[ $b_idx -eq 0 ] && _build_module_path="$1"
		_b_build_mod_prefix[$b_idx]="$1"
		shift ;;
	    -default-module) 
		if [ $def_mod_first -eq 1 ]; then
		    def_mod_first=0
		    _b_def_mod_reqs[$b_idx]=""
		fi
		local tmp=$(get_index $1)
		[ -z "$tmp" ] && tmp=-1
		if [ $tmp -lt 0 ]; then
		    add_hidden_package "$1"
		fi
		_b_def_mod_reqs[$b_idx]="${_b_def_mod_reqs[$b_idx]} $1"
		shift ;;
	    -module-format)
		_module_format="$1"
		shift
		case $_module_format in
		    TCL) ;;
		    LUA) ;;
		    *)
			doerr "$_module_format" "Unrecognized module format (LUA/TCL)"
		esac
		;;
	    -default-build)
		switch_idx=0
		if [ $# -gt 0 ]; then
		    case $1 in
			-*) ;;
			*)
			    local switch_idx=$(get_index --hash-array "_b_index" $1)
			    [ -z "$switch_idx" ] && \
				doerr "$1" "Unrecognized build"
			    shift
			    ;;
		    esac
		fi
		_b_def_idx=$switch_idx
		;;
	    -default-module-version)
		_crt_version=1
		;;
	    -non-default-module-version)
		_crt_version=0
		;;
	    *) doerr "$opt" "Not a recognized option for build_set" ;;
	esac
    done
    [ $DEBUG -ne 0 ] && do_debug --return build_set
}

# Retrieval of different variables
function build_get {
    [ $DEBUG -ne 0 ] && do_debug --enter build_get
    # We set up default parameters for creating the 
    # default package directory
    local opt=$(trim_em $1)
    shift
    local spec=$(var_spec -s $opt)
    if [ -z "$spec" ]; then
	local b_idx=0
    else
	local b_idx=$(get_index --hash-array "_b_index" $spec)
    fi
    [ -z "$b_idx" ] && doerr "Build index" "Build not existing ($opt and $spec)"
    opt=$(var_spec $opt)
    case $opt in
	-archive-path|-ap) _ps "$_archives" ;;
	-installation-path|-ip) _ps "${_b_prefix[$b_idx]}" ;;
	-module-path|-mp) _ps "${_b_mod_prefix[$b_idx]}" ;;
	-build-path|-bp) _ps "${_b_build_path[$b_idx]}" ;;
	-build-installation-path|-bip) _ps "${_b_build_prefix[$b_idx]}" ;;
	-build-module-path|-bmp) _ps "${_b_build_mod_prefix[$b_idx]}" ;;
	-default-build) _ps "$_b_def_idx" ;; 
	-default-module) _ps "${_b_def_mod_reqs[$b_idx]}" ;; 
	-source) _ps "${_b_source[$b_idx]}" ;; 
	*) doerr "$opt" "Not a recognized option for build_get ($opt and $spec)" ;;
    esac
    [ $DEBUG -ne 0 ] && do_debug --return build_get
}

function new_build {
    # Simple command to initialize a new build
    let _N_b++
    # Initialize all the stuff
    _b_prefix[$_N_b]="${_b_prefix[$_b_def_idx]}"
    _b_mod_prefix[$_N_b]="${_b_mod_prefix[$_b_def_idx]}"
    _b_build_prefix[$_N_b]="${_b_build_prefix[$_b_def_idx]}"
    _b_build_mod_prefix[$_N_b]="${_b_build_mod_prefix[$_b_def_idx]}"
    # Read in options
    while [ $# -gt 1 ]; do
	local opt=$(trim_em $1)
	shift
	case $opt in 
	    # As a bonus, supplying name several time
	    # creates aliases! :)
	    -name) 
		_b_index[$1]=$_N_b
		_b_name[$_N_b]="$1" ; shift ;;
	    -installation-path) 
		_b_prefix[$_N_b]="$1"
		mkdir -p $1
		shift ;;
	    -module-path) 
		_b_mod_prefix[$_N_b]="$1" 
		mkdir -p $1
		shift ;;
	    -build-installation-path|-bip) 
		_b_build_prefix[$_N_b]="$1" ; shift ;;
	    -build-module-path|-bmp)
		_b_build_mod_prefix[$_N_b]="$1" ; shift ;;
	    -build-path|-bp)
		_b_build_path[$_N_b]="$1" ; mkdir -p $1 ; shift ;;
	    -default-module)
		local tmp=$(get_index $1)
		[ -z "$tmp" ] && tmp=-1
		if [ $tmp -lt 0 ]; then
		    echo Adding hidding package $1
		    add_hidden_package "$1"
		fi
		_b_def_mod_reqs[$_N_b]="${_b_def_mod_reqs[$_N_b]} $1" ; shift ;;
	    -source)
		_b_source[$_N_b]="$(readlink -f $1)" ; shift
		[ ! -e ${_b_source[$_N_b]} ] && \
		    doerr "${_b_source[$_N_b]}" "Source file does not exist"
		;;
	    *)
		doerr "$opt" "Unrecognized option in new_build"
		;;
	esac
    done
    if [ $# -gt 0 ]; then
	_b_index[$1]=$_N_b
	_b_name[$_N_b]="$1"
	shift
    fi
}

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

# This function takes no arguments
# It is the name/index of the module that is to be tested
# It is equivalent to calling:
#   name=$(pack_get --alias)
#   version=$(pack_get --version)
#   add_package --package $name-test --version $version fake
#   pack_set --module-requirement $name[$version]
#   pack_set --install-query $(pack_get --install-prefix $name[$version])/test.output
function add_test_package {
    local name=$(pack_get --alias)
    local version=$(pack_get --version)
    add_package --package $name-test \
	--version $version fake
    pack_set --module-requirement $name[$version]
    pack_set --install-query $(pack_get --install-prefix $name[$version])/test.output
}

# Local variables for archives to be installed
declare -a _http
# The settings
declare -a _settings
# Where the package is installed
declare -a _install_prefix
# Where the package libraries are found
declare -a _lib_prefix
# What to check for when installed
declare -a _install_query
# An aliased name
declare -a _alias
# The module installation prefix (in case we have several different module paths)
declare -a _mod_prefix
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
# The name of the build attached to this
declare -a _build
# Local variables for hash tables of index (speed up of execution)
declare -A _index
# The counter to hold the archives
_N_archives=-1

_install_prefix_no_path="HIDDEN"
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
function add_package {
    [ $DEBUG -ne 0 ] && do_debug --enter add_package
    let _N_archives++
    # Collect options
    local d="" ; local v=""
    local fn="" ; local package=""
    local alias="" 
    # Default to default index
    local b_name="${_b_name[$_b_def_idx]}"
    local no_def_mod=0
    local lp="/lib"
    while [ $# -gt 1 ]; do
	local opt=$(trim_em $1) 
	shift
	case $opt in
	    -build) b_name="$1" ; shift ;;
	    -archive|-A) fn=$1 ; shift ;;
	    -directory|-d) d=$1 ; shift ;;
	    -version|-v) v=$1 ; shift ;;
	    -package|-p) package=$1 ; shift ;;
	    -no-default-modules) no_def_mod=1 ;;
	    -lib-path|-lp) lp=$1 ; 
		case $lp in
		    /*) # do nothing
			;;
		    *) lp="/$lp"
			;;
		esac ; shift ;;
	    -alias|-a) alias=$1 ; shift ;;
	    *) doerr "$opt" "Not a recognized option for add_package" ;;
	esac
    done
    # Save the build name
    _build[$_N_archives]=$b_name

    # When adding a package we need to ensure that all variables
    # exist for the rest of the package. Hence we source the "source"
    # Notice that the sourcing occurs several times doing the process
    source $(build_get --source[$b_name])

    # Save the url 
    local url=$1
    _http[$_N_archives]=$url
    if [ "$url" == "fake" ]; then
	d=./
	_install_query[$_N_archives]=/directory/does/not/exist
    fi
    # Save the archive name
    [ -z "$fn" ] && fn=$(basename $url)
    _archive[$_N_archives]=$fn
    # Save the type of archive
    local ext=${fn##*.}
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
    local tmp="${_index[$(lc $alias)]}"
    local lc_name="$(lc $alias)"
    if [ ! -z "$tmp" ]; then
	_index[$lc_name]="$tmp $_N_archives"
    else
	_index[$lc_name]="$_N_archives"
    fi
    # Default the module name to this:
    _installed[$_N_archives]=0
    # Module prefix and the name of the module
    _mod_prefix[$_N_archives]="$(build_get --module-path[$b_name])"
    tmp="$(build_get --build-module-path[$b_name])"
    _mod_name[$_N_archives]=$(pack_list -lf "-X -p /" $tmp)
    _mod_name[$_N_archives]=${_mod_name[$_N_archives]%/}
    _mod_name[$_N_archives]=${_mod_name[$_N_archives]#/}
    # Install prefix and the installation path
    tmp="$(build_get --build-installation-path[$b_name])"
    _install_prefix[$_N_archives]=$(build_get --installation-path[$b_name])/$(pack_list -lf "-X -s /" $tmp)
    _install_prefix[$_N_archives]=${_install_prefix[$_N_archives]%/}
    _lib_prefix[$_N_archives]=${_install_prefix[$_N_archives]}$lp
    # Install default values
    _mod_req[$_N_archives]=""
    [ $no_def_mod -eq 0 ] && \
	_mod_req[$_N_archives]="$(build_get --default-module[$b_name])"
    _reject_host[$_N_archives]=""
    _only_host[$_N_archives]=""

    msg_install --message "Added $package[$v] to the install list"
    [ $DEBUG -ne 0 ] && do_debug --return add_package
}

# This function allows for setting data related to a package
function pack_set {
    [ $DEBUG -ne 0 ] && do_debug --enter pack_set
    local index=$_N_archives # Default to this
    local alias="" ; local version="" ; local directory=""
    local settings="0" ; local install="" ; local query=""
    local mod_name="" ; local package="" ; local opt=""
    local cmd="" ; local cmd_flags="" ; local req="" ; local idx_alias=""
    local reject_h="" ; local only_h="" ; local inst=2
    local mod_prefix=""
    local mod_opt="" ; local lib="" ; local up_pre_mod=0
    while [ $# -gt 0 ]; do
	# Process what is requested
	local opt="$(trim_em $1)"
	shift
	case $opt in
	    -no-path)
		install="$_install_prefix_no_path" ;;
            -C|-command)  cmd="$1" ; shift ;;
            -CF|-command-flag)  cmd_flags="$cmd_flags $1" ; shift ;; # called several times
            -I|-install-prefix)  install="$1" ; shift ;;
	    -L|-library-suffix)  lib="$1" 
		case $lib in
		    /*) # do nothing
			;;
		    *) lib="/$lib"
			;;
		esac ; shift ;;
            -MP|-module-prefix)  mod_prefix="$1" ; shift ;;
            -R|-module-requirement)  
		local tmp="$(pack_get --module-requirement $1)"
		[ ! -z "$tmp" ] && req="$req $tmp"
		# We add the host-rejects for this requirement
		local tmp="$(pack_get --host-reject $1)"
		[ ! -z "$tmp" ] && reject_h="$reject_h $tmp"
		local tmp="$(pack_get --host-only $1)"
		[ ! -z "$tmp" ] && only_h="$only_h $tmp"
		req="$req $1" ; shift ;; # called several times
            -Q|-install-query)  query="$1" ; shift ;;
	    -a|-alias)  alias="$1" ; shift ;;
	    -index-alias)  idx_alias="$1" ; shift ;; ## opted for deletion...
	    -installed)  inst="$1" ; shift ;;
            -v|-version)  version="$1" ; shift ;;
            -d|-directory)  directory="$1" ; shift ;;
	    -s|-setting)  settings=$((settings + $1)) ; shift ;; # Can be called several times
	    -m|-module-name)  mod_name="${1%/}" ; shift ;;
	    -module-opt)  mod_opt="$mod_opt $1" ; shift ;;
	    -prefix-and-module)  mod_name="$1" ; up_pre_mod=1 ; shift ;;
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
    if [ $up_pre_mod -eq 1 ]; then
	# We have used prefix-and-module
	# we need to correct the fetching of the build path
	# This is only because we haven't used the index thing before
	local opt=$(pack_get --build $index)
	install="$(build_get --installation-path[$opt])/$mod_name"
	lib=/lib # ensure setting library path
    fi
    # We now have index to be the correct spanning
    [ ! -z "$cmd" ] && _cmd[$index]="${_cmd[$index]}$cmd $cmd_flags${_LIST_SEP}"
    if [ ! -z "$req" ]; then
	req="${_mod_req[$index]} $req"
	# Remove dublicates:
	req="$(rem_dup $req)"
	_mod_req[$index]="$req"
    fi
    [ ! -z "$install" ]    && _install_prefix[$index]="$install"
    [ ! -z "$lib" ]        && _lib_prefix[$index]="${_install_prefix[$index]}$lib"
    [ "$inst" -ne "2" ]    && _installed[$index]="$inst"
    [ ! -z "$query" ]      && _install_query[$index]="$query"
    if [ ! -z "$alias" ]; then
	local tmp="" ; local v=""
	local lc_name="$(lc ${_alias[$index]})"
	for v in ${_index[$lc_name]} ; do
	    [ "$v" -ne "$index" ] && tmp="$tmp $v"
	done
	if [ -z "$tmp" ]; then
	    unset _index[$lc_name]
	else
	    _index[$lc_name]="$tmp"
	fi
	_alias[$index]="$alias"
	local lc_name="$(lc $alias)"
	tmp="${_index[$lc_name]}"
	if [ -z "$tmp" ]; then
	    _index[$lc_name]="$index"
	else
	    _index[$lc_name]="$tmp $index"
	fi
    fi
    if [ ! -z "$idx_alias" ]; then  ## opted for deletion... (superseeded by explicit version comparisons...)
	_index[$idx_alias]="$index"
    fi
    [ ! -z "$mod_opt" ]    && _mod_opts[$index]="${_mod_opts[$index]}$mod_opt"
    [ ! -z "$version" ]    && _version[$index]="$version"
    [ ! -z "$directory" ]  && _directory[$index]="$directory"
    [ 0 -ne "$settings" ]  && _settings[$index]="$settings"
    [ ! -z "$mod_prefix" ] && _mod_prefix[$index]="$mod_prefix"
    [ ! -z "$mod_name" ]   && _mod_name[$index]="$mod_name"
    [ ! -z "$package" ]    && _package[$index]="$package"
    [ ! -z "$only_h" ]     && _only_host[$index]="${_only_host[$index]}$only_h"
    [ ! -z "$reject_h" ]   && _reject_host[$index]="${_reject_host[$index]}$reject_h"
    [ $DEBUG -ne 0 ] && do_debug --return pack_set
}

# This function allows for setting data related to a package
# Should take at least one parameter (-a|-I...)
function pack_get {
    [ $DEBUG -ne 0 ] && do_debug --enter pack_get
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
	    [ -z "$index" ] && \
		doerr pack_get "Could not find index of $1"
	    #echo "pack_get: lookup($1) idx($index)" >&2
	    shift
            # Process what is requested
	    case $opt in
		-build)              _ps "${_build[$index]}" ;;
		-C|-commands)        _ps "${_cmd[$index]}" ;;
		-h|-u|-url|-http)    _ps "${_http[$index]}" ;;
		-module-load) 
		    for m in ${_mod_req[$index]} ; do
			_ps "$(pack_get --module-name $m) "
		    done 
		    _ps "${_mod_name[$index]}"
		    ;;
		-R|-module-requirement) 
                                     _ps "${_mod_req[$index]}" ;;
		-module-paths-requirement) 
		    for m in ${_mod_req[$index]} ; do
			if [ "$(pack_get --install-prefix $m)" == "$_install_prefix_no_path" ]; then
			    continue
			else
			    _ps "$m "
			fi
		    done ;;
		-module-name-requirement) 
		    for m in ${_mod_req[$index]} ; do
			_ps "$(pack_get --module-name $m) "
		    done ;;
		-L|-library-path)    _ps "${_lib_prefix[$index]}" ;;
		-MP|-module-prefix) 
                                     _ps "${_mod_prefix[$index]}" ;;
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
	    -R|-module-requirement)
		                 _ps "${_mod_req[$index]}" ;;
	    -module-paths-requirement) 
		for m in ${_mod_req[$index]} ; do
		    if [ "$(pack_get --install-prefix $m)" == "$_install_prefix_no_path" ]; then
			continue
		    else
			_ps "$m "
		    fi
		done ;;
	    -module-name-requirement)
		for m in ${_mod_req[$index]} ; do
		    _ps "$(pack_get --module-name $m) "
		done ;;
	    -MI|-module-prefix)  _ps "${_mod_prefix[$index]}" ;;
	    -L|-library-path)    _ps "${_lib_prefix[$index]}" ;;
	    -I|-install-prefix|-prefix) 
                                 _ps "${_install_prefix[$index]}" ;;
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
    [ $DEBUG -ne 0 ] && do_debug --return pack_get
}

function pack_installed {
    local ret=$(pack_get --installed $1)
    [ -z "$ret" ] && ret=0
    if [ $ret -eq 0 ]; then
	pack_install $1 > /dev/null
	ret=$(pack_get --installed $1)
    fi
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
    local j=0
    while [ $# -ne 0 ]; do
	local opt="$(trim_em $1)" # Save the option passed
	shift
	case $opt in
	    -from|-f)    j="$(get_index $1)" ; shift ;;
	    *) shift ;;
	esac
    done
    for i in `seq $j $_N_archives` ; do
	pack_install $i
    done
}

# Install the package
function pack_install {
    local mod_reqs="" ; local mod_reqs_paths=""
    [ $DEBUG -ne 0 ] && do_debug --enter pack_install
    local idx=$_N_archives
    if [ $# -ne 0 ]; then
	idx=$(get_index $1) ; shift
    fi

    # First a simple check that it hasn't already been installed...
    if [ -e $(pack_get --install-query $idx) ]; then
	pack_set --installed 1 $idx
    fi

    # Save the module requirements for later...
    mod_reqs="$(pack_get --module-requirement $idx)"
    mod_reqs_paths="$(pack_get --module-paths-requirement $idx)"

    # If we request downloading of files, do so immediately
    if [ $DOWNLOAD -eq 1 ]; then
	dwn_file $idx $(build_get --archive-path)
    fi

    # If it is installed...
    if [ $(pack_get --installed $idx) -eq 1 ]; then
	msg_install --already-installed $idx
	if [ $FORCEMODULE -eq 0 ]; then
	    [ $DEBUG -ne 0 ] && do_debug --return pack_install
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
	[ -z "${tmp// /}" ] && break
	tmp_idx=$(get_index $tmp)
	if [ $(pack_get --installed $tmp_idx) -eq 0 ]; then
	    pack_install $tmp_idx
	fi
	# Capture packages that has been rejected.
	# If it depends on rejected packages, it must itself be rejected.
	if [ $(pack_get --installed $tmp_idx) -eq -1 ]; then
	    run=0
	    break
	fi
    done

    if [ $run -eq 0 ]; then
	# Notify other required stuff that this can not be installed.
	pack_set --installed -1 $idx
	msg_install --message "Installation rejected for $(pack_get --package $idx)" $idx
	[ $DEBUG -ne 0 ] && do_debug --return pack_install
	return 1
    fi

    # Check that the package is not already installed
    if [ $(pack_get --installed $idx) -eq 0 ]; then

	# Source the file for obtaining correct env-variables
	local tmp=$(pack_get --build $idx)
	source $(build_get --source[$tmp])

        # Create the list of requirements
	local module_loads="$(list --loop-cmd 'pack_get --module-name' $mod_reqs)"
	module load $module_loads

	# If the module should be preloaded (for configures which checks that the path exists)
	if $(has_setting $PRELOAD_MODULE $idx) ; then
	    create_module --force \
		-n "$(pack_get --alias $idx)" \
		-v "$(pack_get --version $idx)" \
		-M "$(pack_get --module-name $idx)" \
		-p "$(pack_get --module-prefix $idx)" \
		-P "$(pack_get --install-prefix $idx)"
	    # Load module for preloading
	    module load $(pack_get --module-name $idx)
	fi

	# Append all relevant requirements to the relevant environment variables
	# Perhaps this could be generalized with options specifying the ENV_VARS
	local tmp=$(trim_spaces "$(list --LDFLAGS --Wlrpath $mod_reqs_paths)")
	old_fcflags="$FCFLAGS"
	export FCFLAGS="$(trim_spaces "$FCFLAGS") $tmp"
	old_fflags="$FFLAGS"
	export FFLAGS="$(trim_spaces "$FFLAGS") $tmp"
	old_cflags="$CFLAGS"
	export CFLAGS="$(trim_spaces "$CFLAGS") $tmp"
	old_ldflags="$LDFLAGS"
	export LDFLAGS="$(trim_spaces "$LDFLAGS") $tmp"
	tmp=$(trim_spaces "$(list --INCDIRS $mod_reqs_paths)")
	old_cppflags="$CPPFLAGS"
	export CPPFLAGS="$(trim_spaces "$CPPFLAGS") $tmp"
	#old_ld_lib_path="$LD_LIBRARY_PATH"
	#export LD_LIBRARY_PATH="$LD_LIBRARY_PATH$(list --prefix : --loop-cmd 'pack_get --install-prefix' --suffix '/lib' $mod_reqs_paths)"

        # Show that we will install
	msg_install --start $idx
	
        # Download archive
	dwn_file $idx $(build_get --archive-path)

        # Extract the archive
	pushd $(build_get --build-path) 1> /dev/null
	[ $? -ne 0 ] && exit 1
	# Remove directory if already existing
	local d=$(pack_get --directory $idx)
	if [ "x$d" != "x." ] && [ "x$d" != "x./" ]; then
	    rm -rf $(pack_get --directory $idx)
	fi
	extract_archive $(build_get --archive-path) $idx
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
        module unload $module_loads

	# Unload the module itself in case of PRELOADING
	if $(has_setting $PRELOAD_MODULE $idx) ; then
	    module unload $(pack_get --module-name $idx)
	    # We need to clean up, in order to force the
	    # module creation.
	    rm -f $(pack_get --module-prefix $idx)/$(pack_get --module-name $idx)
	fi

	export FCFLAGS="$old_fcflags"
	export FFLAGS="$old_fflags"
	export CFLAGS="$old_cflags"
	export CPPFLAGS="$old_cppflags"
	export LDFLAGS="$old_ldflags"
	#export LD_LIBRARY_PATH="$old_ld_lib_path"

        # For sure it is now installed...
	pack_set --installed 1 $idx

    fi

    if $(has_setting $IS_MODULE $idx) ; then
        # Create the list of requirements
	local reqs="$(list --prefix '-R ' $mod_reqs)"
	if [ $(pack_get --installed $idx) -eq 1 ]; then
            # We install the module scripts here:
	    create_module \
		-n "$(pack_get --alias $idx)" \
		-v "$(pack_get --version $idx)" \
		-M "$(pack_get --module-name $idx)" \
		-p "$(pack_get --module-prefix $idx)" \
		-P "$(pack_get --install-prefix $idx)" $reqs $(pack_get --module-opt $idx)
	fi
    fi
    [ $DEBUG -ne 0 ] && do_debug --return pack_install
}

# Can be used to return the index in the _arrays for the named variable
# $1 is the shortname for what to search for
function get_index {
    #[ $DEBUG -ne 0 ] && do_debug --enter get_index
    local var=_index
    local i ; local lookup ; local all=0
    while [ $# -gt 1 ]; do
	local opt=$(trim_em $1) ; shift
	case $opt in
	    -all|-a) all=1                ;;
	    -hash-array) var="$1" ; shift ;;
	esac
    done
    [ ${#1} -eq 0 ] && return 1
    # Save the thing that we want to process...
    local name=$(var_spec $1)
    local version=$(var_spec -s $1)
    local l=${#name} ; local lc_name="$(lc $name)"
    #[ ! -z "$version" ] && \
#	echo "get_index: name($name) version($version)" >&2
    # do full variable (for ${!...})
    var="$var[$lc_name]"
    if $(isnumber $name) ; then # We have a number
	[ "$name" -gt "$_N_archives" ] && return 1
	[ "$name" -lt 0 ] && return 1
	_ps "$name"
	#[ $DEBUG -ne 0 ] && do_debug --return get_index
	return 0
    fi
    # Do full expansion.
    local idx=${!var}
    i=0
    #echo $idx
    if [ -z "$idx" ]; then
	[ $DEBUG -ne 0 ] && do_debug --msg "We did not find the requested: $name"
	#[ $DEBUG -ne 0 ] && do_debug --return get_index
	return 1
    fi
    if [ $all -eq 1 ]; then
	_ps "$idx"
	#[ $DEBUG -ne 0 ] && do_debug --return get_index
	return 0
    else
	#[ ! -z "$version" ] && \
	#    echo "get_index: loop ($idx)" >&2
	local v=""
	i=-1
        # Select the latest per default..
	for v in $idx ; do
	    if [ ! -z "$version" ]; then
		if [ $(vrs_cmp $(pack_get --version $v) $version) -eq 0 ]; then
		    i="$v"
		    break
		fi
	    else
		i="$v"
	    fi
	done
    fi
    [ -z "${i// /}" ] && i=-1
    _ps "$i"
    return 0
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
function create_module {
    [ $DEBUG -ne 0 ] && do_debug --enter create_module
    local name; local version; local echos
    local path; local help; local whatis; local opt
    local env="" ; local tmp=""
    local mod_path=""
    local force=0 ; local no_install=0
    local require=""; local conflict=""; local load=""
    local lua_family=""
    local fm_comment="#"
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
	    -RL|-reqs+load-module) 
		load="$load $(pack_get --module-requirement $1) $1" ; shift ;; # Can be optioned several times
	    -C|-conflict-module)  conflict="$conflict $1" ; shift ;; # Can be optioned several times
	    -set-ENV)      env="$env s$1" ; shift ;; # Can be optioned several times
	    -prepend-ENV)      env="$env p$1" ; shift ;; # Can be optioned several times
	    -append-ENV)      env="$env a$1" ; shift ;; # Can be optioned several times
	    -lua-family) lua_family="$1" ; shift ;; # If using the Lmod, we create a family name, else nothing is happening...
	    -echo)
		echos="$1" ; shift ;; # Echo out to the users
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
	local mfile=$(build_get --module-path)
    else
	local mfile=$mod_path
    fi
    [ -n "$mod" ] && mfile=$mfile/$mod
    case $_module_format in
	TCL) 
	    fm_comment="#"
	    ;;
	LUA)
	    fm_comment="--"
	    mfile="$mfile.lua"
	    ;;
    esac
    [ -z "$version" ] && version=empty

    # Check that all that is required and needs to be loaded is installed
    for mod in $require $load ; do
	[ -z "${mod// /}" ] && continue
	[ $(pack_get --installed $mod) -eq 1 ] && continue
        [ $DEBUG -ne 0 ] && do_debug --return create_module
	return 1
    done
    
    # If the file exists simply return
    if [ -e "$mfile" ] && [ 0 -eq $force ]; then
        [ $DEBUG -ne 0 ] && do_debug --return create_module
        return 0
    fi

    # First create directory if it does not exist:
    mkdir -p $(dirname $mfile)
    
    # Create the module file
    case $_module_format in
	TCL)
	    cat <<EOF > "$mfile"
#%Module1.0
#####################################################################

set modulename  "$name"
set version	$version
EOF
	    ;;
	LUA)
	    cat <<EOF > "$mfile"
$fm_comment LUA file for Lmod

local modulename    = "$name"
local version       = "$version"
EOF
	    ;;
	*)
	    doerr "create_module" "Unknown module type, [TCL,LUA]"
	    ;;
    esac
    tmp="$(get_c)"
    if [ ! -z "$tmp" ]; then
	case $_module_format in
	    TCL)
		cat <<EOF >> "$mfile"
set compiler	$(get_c)
EOF
		;;
	    LUA) tmp=", compiler \$compiler"
		cat <<EOF >> "$mfile"
local compiler      = "$(get_c)"
EOF
		;;
	esac
    fi

    case $_module_format in
	TCL) cat <<EOF >> "$mfile"
set basepath	${path//$version/\$version}
EOF
	    ;;
	LUA) cat <<EOF >> "$mfile"
local basepath      = "${path%$version*}" .. version .. "${path#*$version}"
EOF
	    ;;
    esac

    case $_module_format in
	TCL) cat <<EOF >> "$mfile"

proc ModulesHelp { } {
    puts stderr "\tLoads \$modulename (\$version)"
}

module-whatis "Loads \$modulename (\$version)$tmp."

EOF
	    ;;
	LUA) cat <<EOF >> "$mfile"

help("    Loads " .. modulename .. " (" .. version .. ")")
whatis("Loads " .. modulename .. " (" .. version .. ") using " .. compiler .. " compiler.")

EOF
	    ;;
    esac

    # Add pre loaders if needed
    if [ ! -z "${load// /}" ]; then
	cat <<EOF >> "$mfile"
$fm_comment This module will load the following modules:
EOF
	for tmp in $load ; do
	    if [ $(pack_get --installed $tmp) -ne 0 ]; then
		local tmp_load=$(pack_get --module-name $tmp)
		case $_module_format in 
		    TCL) echo "module load $tmp_load" >> "$mfile" ;;
		    LUA) echo "load(\"$tmp_load\")" >> "$mfile" ;;
		esac
	    elif [ $force -eq 0 ]; then
		no_install=1
	    fi
	done
	echo "" >> $mfile
    fi    

    # Add requirement if needed
    if [ ! -z "${require// /}" ]; then
	cat <<EOF >> $mfile
$fm_comment Requirements for the module:
EOF
	for tmp in $require ; do
	    if [ $(pack_get --installed $tmp ) -ne 0 ]; then
		local tmp_load=$(pack_get --module-name $tmp)
		case $_module_format in 
		    TCL) echo "prereq $tmp_load" >> "$mfile" ;;
		    LUA) echo "prereq(\"$tmp_load\")" >> "$mfile" ;;
		esac
	    elif [ $force -eq 0 ]; then
		no_install=1
	    fi
	done
	echo "" >> $mfile
    fi
    # Add conflict if needed
    if [ ! -z "${conflict// /}" ]; then
	cat <<EOF >> $mfile
$fm_comment Modules which is in conflict with this module:
EOF
	for tmp in $conflict ; do
	    if [ $(pack_get --installed $tmp ) -ne 0 ]; then
		local tmp_load=$(pack_get --module-name $tmp)
		case $_module_format in 
		    TCL) echo "conflict $tmp_load" >> "$mfile" ;;
		    LUA) echo "conflict(\"$tmp_load\")" >> "$mfile" ;;
		esac
	    elif [ $force -eq 0 ]; then
		no_install=1
	    fi
	done
	echo "" >> $mfile
    fi
    # Add specific envs if needed
    if [ ! -z "${env// /}" ]; then
	cat <<EOF >> $mfile
$fm_comment Specific environment variables:
EOF
	for tmp in $env ; do
	    # Partition into [s|a|p]
	    local opt=${tmp:0:1}
	    local lenv=${tmp%%=*}
	    lenv=${lenv:1}
	    local lval=${tmp##*=}
            # Add paths if they are available
	    if [ "$opt" == "s" ]; then
		opt="$(_module_fmt_routine --set-env $lenv $lval)"
	    elif [ "$opt" == "p" ]; then
		opt="$(_module_fmt_routine --prepend-path $lenv $lval)"
	    elif [ "$opt" == "a" ]; then
		opt="$(_module_fmt_routine --append-path $lenv $lval)"
	    else
		opt=""
	    fi		
	    [ ! -z "$opt" ] && \
		_add_module_if -F $force -d "$lval" "$mfile" "$opt" 
	done
	echo "" >> $mfile
    fi
    # Add paths if they are available
    _add_module_if -F $force -d "$path/bin" $mfile \
	"$(_module_fmt_routine --prepend-path PATH $path/bin)"
    _add_module_if -F $force -d "$path/lib/pkgconfig" $mfile \
	"$(_module_fmt_routine --prepend-path PKG_CONFIG_PATH $path/lib/pkgconfig)"
    _add_module_if -F $force -d "$path/lib64/pkgconfig" $mfile \
	"$(_module_fmt_routine --prepend-path PKG_CONFIG_PATH $path/lib64/pkgconfig)"
    _add_module_if -F $force -d "$path/man" $mfile \
	"$(_module_fmt_routine --prepend-path MANPATH $path/man)"
    _add_module_if -F $force -d "$path/man" $mfile \
	"$(_module_fmt_routine --prepend-path MANPATH $path/share/man)"
    # The LD_LIBRARY_PATH is DANGEROUS!
    #_add_module_if -F $force -d "$path/lib" $mfile \
#	"$(_module_fmt_routine --prepend-path LD_LIBRARY_PATH $path/lib)"
 #   _add_module_if -F $force -d "$path/lib64" $mfile \
#	"$(_module_fmt_routine --prepend-path LD_LIBRARY_PATH $path/lib64)"
    _add_module_if -F $force -d "$path/lib/python" $mfile \
	"$(_module_fmt_routine --prepend-path PYTHONPATH $path/lib/python)"
    for PV in 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 ; do
	_add_module_if -F $force -d "$path/lib/python$PV/site-packages" $mfile \
	    "$(_module_fmt_routine --prepend-path PYTHONPATH $path/lib/python$PV/site-packages)"
    done
    if [ ! -z "$lua_family" ]; then
	case $_module_format in
	    LUA)
		cat <<EOF >> "$mfile"


$fm_comment Add family:
family("$lua_family")
EOF
		;;
	esac
    fi
    
    if [ ! -z "$echos" ]; then
	cat <<EOF >> "$mfile"


$fm_comment echo to the user:
EOF
	case $_module_format in
	    TCL)
		cat <<EOF >> "$mfile"
puts stderr "$echos"
EOF
		;;
	    LUA)
		cat <<EOF >> "$mfile"
LmodMessage("$echos")
EOF
		;;
	esac
    fi
    
    
    if [ $no_install -eq 1 ] && [ $force -eq 0 ]; then
	rm -f $mfile
    fi
    # If we are to create the default version module we 
    # can add this version to the .version file:
    if [ $_crt_version -eq 1 ]; then
	case $_module_format in
	    TCL)
		cat <<EOF > $(dirname $mfile)/.version
#%Module1.0
#####################################################################
set ModulesVersion $(basename $mfile)
EOF
		;;
	    LUA)
		pushd $(dirname $mfile) 1> /dev/null
		ln -s $(basename $mfile) default
		popd 1> /dev/null 
		;;
	esac
    fi
    [ $DEBUG -ne 0 ] && do_debug --return create_module
}

# Returns the module specific routine call
function _module_fmt_routine {
    local lval="" ; local lenv=""
    while [ $# -gt 0 ]; do
	opt="$(trim_em $1)" ; shift
	case "$opt" in
	    -prepend-path)
		case $_module_format in
		    TCL) _ps "prepend-path $1 $2" ;;
		    LUA) _ps "prepend_path(\"$1\",\"$2\")" ;;
		esac
		shift ; shift ;;
	    -append-path)
		case $_module_format in
		    TCL) _ps "append-path $1 $2" ;;
		    LUA) _ps "append_path(\"$1\",\"$2\")" ;;
		esac
		shift ; shift ;;
	    -set-env)
		case $_module_format in
		    TCL) _ps "setenv $1 $2" ;;
		    LUA) _ps "setenv(\"$1\",\"$2\",true)" ;;
		esac
		shift ; shift ;;
	esac
    done
}
		
		

# Append to module file dependent on the existance of a
# directory or file
#   -d <directory>
#   -f <file>
#   $1 module file to append to
#   $2-? append this in one line to the file
function _add_module_if {
    local d="";local f="" ;local F=0;
    local X=0
    while getopts ":d:f:F:Xh" opt; do
	case $opt in
            d)  d="$OPTARG" ;;
            f)  f="$OPTARG" ;;
            F)  F="$OPTARG" ;;
	    X)  X=1 ;;
            h)  echo "Invalid option in add_module_if" 
		exit 0 ;;
            \?) echo "Invalid option: -$OPTARG"
		exit 1 ;;
            :)  echo "Option -$OPTARG requires an argument."
		exit 1 ;;
	esac
    done ; shift $((OPTIND-1)) ; OPTIND=1
    local mf="$1" ; shift
    local check=""
    [ -n "$d" ] && check=$d ; [ -n "$f" ] && check=$f
    if [ $X -eq 1 ]; then
	# we have expressed that this module should be created
	# if there are any executables in the directory...
	local keep=0
	for lf in $check/* ; do
	    if [ -x $lf ] && [ ! -d $lf ]; then
		keep=1
	    fi
	done
	[ $keep -eq 0 ] && check=/directory/does/not/exist
    else
	[ "$F" -ne "0" ] && check=$HOME # Force the check to succeed
    fi
    if [ -e $check ]; then
	cat <<EOF >> $mf
$@
EOF
	return 0
    fi
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
    if [ $1 -ne 0 ]; then
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

# Update the package version number by looking at the date in the file
function pack_set_file_version {
    local idx=$_N_archives
    [ $# -gt 0 ] && idx=$(get_index $1)
    # Download the archive
    dwn_file $idx $(build_get --archive-path)
    local v="$(get_file_time %g-%j $(build_get --archive-path)/$(pack_get --archive $idx))"
    pack_set --version "$v"
     # Default the module name to this:
    local b_name="$(pack_get --build $idx)"
    local tmp="$(build_get --build-module-path[$b_name])"
    tmp=$(pack_list -lf "-X -p /" $tmp)
    tmp=${tmp%/}
    tmp=${tmp#/}
    pack_set --module-name $tmp $idx
}


function do_debug {
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
