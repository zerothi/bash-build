
# Local variables for archives to be installed
declare -A _http
# The settings, this is formatted like <setting-1>$_LIST_SEP<setting-2>
# etc.
declare -A _settings
# Where the package is installed
declare -A _install_prefix
# Where the package libraries are found
declare -A _lib_prefix
# What to check for when installed
declare -A _install_query
# An aliased name
declare -A _alias
# The module installation prefix (in case we have several different module paths)
declare -A _mod_prefix
# The module name (when one which to load it must be (module load _mod_name[i])
declare -A _mod_name
# The extension of the archive
declare -A _ext
# The pure archive name (i.e. without http)
declare -A _archive
# The package name (i.e. without extension and version, defaults to be the same as alias)
declare -A _package
# The version number of the package
declare -A _version
# The directory of the extracted package
declare -A _directory
# A command sequence of the extracted package (executed before make commands)
declare -A _cmd
# A module sequence which is the requirements for the package
declare -A _mod_req
# Variable for holding information about "non-installation" hosts
declare -A _reject_host
# A variable that contains all the hosts that it will be installed on
declare -A _only_host
# Logical variable determines whether the package has been installed
_I_REQ=4 # an internal module only used for its custom dependency list
         # it does not contain any paths itself
_I_LIB=3 # an internal module only used for its library path
_I_MOD=2 # a module supplied from outside, it does not contain paths
_I_INSTALLED=1 # the package has been installed
_I_TO_BE=0 # have not decided what the package should do yet...
_I_REJECT=-1 # the package is rejected on this one...
declare -A _installed
# Adds this to the environment variable in the creation of the modules
declare -A _mod_opts
# The name of the build attached to this
declare -A _build
# Local variables for hash tables of index (speed up of execution)
declare -A _index
# The counter to hold the archives
_N_archives=-1

# This function takes one argument
# It is the name of the module that is "hidden", i.e. not
# installed by these scripts. 
# It enables to look them up in the index and thus 
# to use them on equal footing as the others...
function add_hidden_package {
    local mod="$1" ; shift
    local package="${mod%/*}"
    local version="${mod#*/}"
    add_package --package $package \
	--version $version \
	path_to_module/$package-$version.tar.gz
    pack_set --index-alias $mod
    pack_set --installed $_I_INSTALLED # Make sure it is "installed"
    pack_set --module-name $mod
}

# This function takes no arguments
# It is the name/index of the module that is to be tested
# It is equivalent to calling:
#   name=$(pack_get --alias)
#   version=$(pack_get --version)
#   add_package --package $name-test --version $version fake
#   pack_set --module-requirement $name[$version]
#   pack_set --install-query $(pack_get --prefix $name[$version])/test.output
function add_test_package {
    local name=$(pack_get --alias)
    local version=$(pack_get --version)
    add_package --package $name-test \
	--version $version fake
    # Update install-prefix
    pack_set --prefix $(pack_get --prefix $name[$version])
    pack_set --module-requirement $name[$version]
    pack_set --remove-setting module
    if [ $# -gt 0 ]; then
	pack_set --install-query $(pack_get --prefix $name[$version])/$1
	shift
    else
	pack_set --install-query $(pack_get --prefix $name[$version])/tmp.*
    fi
}

# Routine for sourcing a package file
function source_pack {
    local f=$1 ; shift
    local i
    local fp=$(basename $f)
    fp=${fp%.*}

    # Get current reached index
    local cur_idx=$_N_archives

    # Source the file
    source $f

    # Subsequently figure out if any excludes exists
    local rej
    local -a lines=()

    # 1. read any global reject
    for rej in local.reject .reject \
	$(get_c -n).reject .$(get_c -n).reject
    do
	if [ -e $rej ]; then
	    read -d '\n' -a lines < $rej
	    set_reject_list ${lines[@]}
	fi
    done

    # Try and install the just added packages
    i=$cur_idx
    let i++
    while [ $i -le $_N_archives ]; do
	pack_install $i
	let i++
    done    
}

# Parameters are used to create rejections
# Handy when reading a file containing rejections
function set_reject_list {
    local v
    local idx
    while [ $# -gt 0 ]; do
	idx=$(get_index -a $1)
	if [ $? -eq 0 ]; then
	    for v in $idx ; do
		# No error, we have the index
		pack_set --host-reject $(get_hostname) $v
	    done
	fi
	shift
    done
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
function add_package {
    [ $DEBUG -ne 0 ] && do_debug --enter add_package

    # Increment contained packages
    let _N_archives++

    # Collect options
    local d="" ; local v=""
    local fn="" ; local package=""
    local alias="" 
    # Default to default index
    local b_name="${_b_name[$_b_def_idx]}"
    local no_def_mod=0
    local lp=""
    while [ $# -gt 1 ]; do
	local opt=$(trim_em $1) 
	shift
	case $opt in
	    -build) b_name="$1" ; shift ;;
	    -archive|-A) fn=$1 ; shift ;;
	    -directory|-d) d=$1 ; shift ;;
	    -version|-v) v=$1 ; shift ;;
	    -package|-p) package=$1 ; shift ;;
	    -alias|-a) alias=$1 ; shift ;;
	    -no-default-modules) no_def_mod=1 ;;
	    -lib-path|-lp) lp=$1 ; shift
		case $lp in
		    /*) 
			lp=${lp#\/}
			;;
		    *) # do nothing
			;;
		esac ;;
	    *) doerr "$opt" "Not a recognized option for add_package" ;;
	esac
    done
    # Save the build name
    _build[$_N_archives]=$b_name

    # When adding a package we need to ensure that all variables
    # exist for the rest of the package. Hence we source the "source"
    # Notice that the sourcing occurs several times doing the process
    # Note that setting a variable local and using direct
    # assignment will set the return status of local =
    # and not the assignment operator.
    local b_idx
    b_idx=$(get_index --hash-array "_b_index" $b_name)
    if [ $? -ne 0 ]; then
	doerr "$1" "Could not find associated build ($b_name), please create build before commensing compilation"
    fi
    source $(build_get --source[$b_idx])

    # Save the url 
    local url=$1
    _http[$_N_archives]=$url
    if [ "x$url" == "xfake" ]; then
	d=./
	_install_query[$_N_archives]=/directory/does/not/exist
    fi
    # Save the archive name
    [ -z "$fn" ] && fn=$(basename $url)
    _archive[$_N_archives]=$fn
    # Save the type of archive
    local ext=${fn##*.}
    _ext[$_N_archives]=$ext
    # A binary does not have a directory
    [ "x$ext" == "xbin" ] && d=./
    # Infer what the directory is
    local archive_d=${fn%.*tar.$ext}
    [ ${#archive_d} -eq ${#fn} ] && archive_d=${fn%.$ext}
    [ -z "$d" ] && d=$archive_d
    _directory[$_N_archives]=$d
    # Save the version
    [ -z "$v" ] && v=`expr match "$archive_d" '[^-_]*[-_]\([0-9.]*\)'`
    if [ -z "$v" ]; then
	v=`expr match "$archive_d" '[^0-9]*\([0-9.]*\)'`
    fi
    _version[$_N_archives]=$v
    # Save the settings
    _settings[$_N_archives]="$(build_get --default-setting $b_idx)"
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
    _installed[$_N_archives]=$_I_TO_BE
    # Module prefix and the name of the module
    _mod_prefix[$_N_archives]="$(build_get --module-path[$b_idx])"
    tmp="$(build_get --build-module-path[$b_idx])"
    _mod_name[$_N_archives]=$(pack_list -lf "-X -p /" $tmp)
    _mod_name[$_N_archives]=${_mod_name[$_N_archives]%/}
    _mod_name[$_N_archives]=${_mod_name[$_N_archives]#/}
    # Install prefix and the installation path
    tmp="$(build_get --build-installation-path[$b_idx])"
    _install_prefix[$_N_archives]=$(build_get --installation-path[$b_idx])/$(pack_list -lf "-X -s /" $tmp)
    _install_prefix[$_N_archives]=${_install_prefix[$_N_archives]%/}
    if [ -z "$lp" ]; then
	_lib_prefix[$_N_archives]=lib
        # Just in case lib64 already exists
	[ -d ${_install_prefix[$_N_archives]}/lib64 ] && \
	    _lib_prefix[$_N_archives]=lib64
    else
	_lib_prefix[$_N_archives]=$lp
    fi
    # Install default values
    _mod_req[$_N_archives]=""
    [ $no_def_mod -eq 0 ] && \
	_mod_req[$_N_archives]="$(build_get --default-module[$b_idx])"
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
    local settings="" ; local install="" ; local query=""
    local mod_name="" ; local package="" ; local opt=""
    local cmd="" ; local cmd_flags="" ; local req="" ; local idx_alias=""
    local reject_h="" ; local only_h="" ; local inst=-100
    local mod_prefix="" local m=
    local mod_opt="" ; local lib="" ; local up_pre_mod=0
    local tmp=
    while [ $# -gt 0 ]; do
	# Process what is requested
	local opt="$(trim_em $1)"
	shift
	case $opt in
	    -no-path)
		inst=$_I_MOD ;;
            -C|-command)  cmd="$1" ; shift ;;
            -CF|-command-flag)  cmd_flags="$cmd_flags $1" ; shift ;; # called several times
            -I|-install-prefix|-prefix)  install="$1" ; shift ;;
	    -L|-library-suffix)  lib="$1" ; shift
		case $lib in
		    /*)
			lib=${lib#\/}
			;;
		    *)  # do nothing
			;;
		esac ;;
            -MP|-module-prefix)  mod_prefix="$1" ; shift ;;
            -module-remove|-mod-rem)  
		local tmp=""
		for m in ${_mod_req[$index]} ; do
		    if [ "$m" != "$1" ]; then
			tmp="$tmp $m"
		    fi
		done
		_mod_req[$index]="$tmp"
		shift ;;
            -R|-module-requirement|-mod-req)  
		tmp="$(pack_get --mod-req-all $1)"
		[ ! -z "$tmp" ] && req="$req $tmp"
		# We add the host-rejects for this requirement
		tmp="$(pack_get --host-reject $1)"
		[ ! -z "$tmp" ] && reject_h="$reject_h $tmp"
		tmp="$(pack_get --host-only $1)"
		[ ! -z "$tmp" ] && only_h="$only_h $tmp"
		req="$req $1" ; shift ;; # called several times
            -Q|-install-query)  query="$1" ; shift ;;
	    -a|-alias)  alias="$1" ; shift ;;
	    -index-alias)  idx_alias="$1" ; shift ;; ## opted for deletion...
	    -installed)  inst="$1" ; shift ;;
            -v|-version)  version="$1" ; shift ;;
            -d|-directory)  directory="$1" ; shift ;;
	    -s|-setting)  settings="$settings$_LIST_SEP$1" ; shift ;; # Can be called several times
	    -choice)
		settings="$settings$_LIST_SEP$1"
		shift
		if [ $# -eq 0 ]; then
		    doerr "pack_set" "You need to specify at least one choice"
		fi
		while [ $# -gt 0 ]; do
		    settings="$settings|$1"
		    shift
		done
		;;
	    -rem-s|-remove-setting)  
		tmp="${_settings[$index]//$1/}" ; shift
		# Remove the setting from the list
		tmp="${tmp//$_LIST_SEP$_LIST_SEP/$_LIST_SEP}"
		_settings[$index]="$tmp"
		;;
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
    fi
    # We now have index to be the correct spanning
    [ ! -z "$cmd" ] && _cmd[$index]="${_cmd[$index]}$cmd $cmd_flags${_LIST_SEP}"
    if [ ! -z "$req" ]; then
	req="${_mod_req[$index]} $req"
	# Remove dublicates:
	_mod_req[$index]="$(rem_dup $req)"
    fi
    if [ ! -z "$install" ]; then
	_install_prefix[$index]="$install"
	[ -d "$install/lib" ] && lib="lib"
	[ -d "$install/lib64" ] && lib="lib64"
    fi
    [ ! -z "$lib" ]        && _lib_prefix[$index]="$lib"
    [ "$inst" -ne "-100" ]    && _installed[$index]="$inst"
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
    [ ! -z "$settings" ]   && _settings[$index]="${settings:1}$_LIST_SEP${_settings[$index]}"
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
		-R|-module-requirement|-mod-req)
		    for m in ${_mod_req[$index]} ; do
			case $(pack_get --installed $m) in
			    $_I_MOD|$_I_INSTALLED|$_I_TO_BE) _ps "$m " ;;
                        esac
		    done ;;
		-mod-req-path)
		    for m in ${_mod_req[$index]} ; do
			case $(pack_get --installed $m) in
			    $_I_LIB|$_I_INSTALLED|$_I_TO_BE) _ps "$m " ;;
                        esac
		    done ;;
		-module-requirement-all|-mod-req-all) 
                    _ps "${_mod_req[$index]}" ;;
		-module-name-requirement|-mod-req-name) 
		    for m in ${_mod_req[$index]} ; do
			_ps "$(pack_get --module-name $m) "
		    done ;;
		-L|-LD|-library-path)    _ps "${_install_prefix[$index]}/${_lib_prefix[$index]}" ;;
		-L-suffix)    _ps "${_lib_prefix[$index]}" ;;
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
	    -R|-module-requirement|-mod-req)
		for m in ${_mod_req[$index]} ; do
		    case $(pack_get --installed $m) in
			$_I_INSTALLED|$_I_MOD) _ps "$m " ;;
                    esac
		done ;;
	    -mod-req-path)
		for m in ${_mod_req[$index]} ; do
		    case $(pack_get --installed $m) in
			$_I_INSTALLED|$_I_LIB) _ps "$m " ;;
                    esac
		done ;;
	    -module-requirement-all|-mod-req-all) 
		_ps "${_mod_req[$index]}" ;;
	    -module-name-requirement|-mod-req-name)
		for m in ${_mod_req[$index]} ; do
		    _ps "$(pack_get --module-name $m) "
		done ;;
	    -MI|-module-prefix)  _ps "${_mod_prefix[$index]}" ;;
	    -L|-LD|-library-path)    _ps "${_install_prefix[$index]}/${_lib_prefix[$index]}" ;;
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
    local ret=$1 ; shift
    local idx
    idx=$(get_index $ret)
    if [ $? -ne 0 ]; then
	ret=$_I_REJECT
    else
	ret=$(pack_get --installed $idx)
	[ -z "$ret" ] && ret=0
	if [ $ret -eq $_I_TO_BE ]; then
	    pack_install $1 > /dev/null
	    ret=$(pack_get --installed $idx)
	fi
    fi
    _ps $ret
}