
# Local variables for archives to be installed
declare -A _http
# The settings, this is formatted like <setting-1>$_LIST_SEP<setting-2>
# etc.
declare -A _settings
# Where the package is installed
declare -A _install_prefix
# A package library
#  This is a list like:
#     <opt>$_CHOICE_SEPlib1 ... $_LIST_SEP
declare -A _libs
# Too long for anybody to create
_LIB_DEF='this_default_lib'
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
# Logical variable determines whether the package has been installed
_I_REQ=4 # an internal module only used for its custom dependency list
         # it does not contain any paths itself
_I_LIB=3 # an internal module only used for its library path
_I_MOD=2 # a module supplied from outside, it does not contain paths
_I_INSTALLED=1 # the package has been installed
_I_TO_BE=0 # have not decided what the package should do yet...
_I_REJECT=-1 # the package is rejected in this installation sequence...
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
    add_package -package $package \
	-version $version \
	path_to_module/$package-$version.local
    pack_set -index-alias $mod
    pack_set -installed $_I_INSTALLED # Make sure it is "installed"
    pack_set -module-name $mod
    # Assert that the settings are not created.
    # Hence if the build-settings has been edited
    # We skip those
    _settings[$_N_archives]=''
}

# This function takes no arguments
# It is the name/index of the module that is to be tested
# It is equivalent to calling:
#   name=$(pack_get -alias)
#   version=$(pack_get -version)
#   add_package -package $name-test -version $version fake
#   pack_set -module-requirement $name[$version]
#   pack_set -install-query $(pack_get -prefix $name[$version])/test.output
function add_test_package {
    local name=$(pack_get -alias)
    if [[ $# -gt 0 ]]; then
	TEST_OUT=$1
	shift
    else
	TEST_OUT=$name.test
    fi
    local version=$(pack_get -version)
    add_package -package $name-test \
	-version $version fake
    # Update install-prefix
    local top_prefix=$(pack_get -prefix $name[$version])
    pack_set -prefix $top_prefix
    pack_set -module-requirement $name[$version]
    pack_set -remove-setting module
    pack_set -install-query $top_prefix/${TEST_OUT}*
}

# Routine for sourcing a package file
function source_pack {
    # We need these long names in case the file
    # redefines variables
    local source_pack_f=$1
    shift
    # Get current reached index (i.e. before adding any
    # new packages)
    local source_pack_i=$_N_archives
    source $source_pack_f
    # Try and install the just added packages
    while [[ $source_pack_i -lt $_N_archives ]]; do
	let source_pack_i++
	pack_install $source_pack_i
    done    
}


# Routine for shortcutting a list of values
# through the pack_get 
# i.e.
# pack_list -list-flags "-s /" --package dir
# returns $(pack_get -package)/dir/
function pack_list {
    local opt lf
    while : ; do
	trim_em opt $1
	case $opt in
	    -list-flags|-lf) shift ; lf="$1" ; shift ;;
	    *) break ;;
	esac
    done
    local ret=''
    while [[ $# -gt 0 ]]; do
	trim_em opt $1
	shift
	case $opt in
	    -*) ret="$ret$(list $lf -c "pack_get $opt" $_N_archives)" ;;
	     *) ret="$ret$(list $lf $opt)" ;;
	esac
    done
    printf '%s' "$ret"
}

# $1 http path
function add_package {

    # Increment contained packages
    let _N_archives++

    # Collect options
    local d v fn package alias lp opt
    # Default to default index
    local b_idx=$_b_def_idx
    local b_name="${_b_name[$_b_def_idx]}"
    local no_def_mod=0
    while [[ $# -gt 1 ]]; do
	trim_em opt $1
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

    # Convert possible
    
    # Save the build name
    # check for possible build-conversions
    case ${b_name} in
	mpi)
	    # Grab the default mpi name
	    b_name=internal-$_mpi_version
	    ;;
	la)
	    # Grab the default LA name
	    b_name=internal-$_la_version
	    doerr "$b_name" "Default LA build is not implemented"
	    ;;
    esac
    _build[$_N_archives]=$b_name

    # When adding a package we need to ensure that all variables
    # exist for the rest of the package. Hence we source the "source"
    # Notice that the sourcing occurs several times doing the process
    # Note that setting a variable local and using direct
    # assignment will set the return status of local =
    # and not the assignment operator.
    if [[ -n "$b_name" ]]; then
	b_idx=$(get_index -hash-array "_b_index" $b_name)
    fi
    if [[ $? -ne 0 ]]; then
	doerr "$1" "Could not find associated build ($b_name), please create build before commensing compilation"
    fi
    source $(build_get -source[$b_idx])

    # Always force the installation
    _install_query[$_N_archives]=/directory/does/not/exist

    # Save the url 
    local url=$1
    # A fake does not have a directory
    [[ "x$url" == "xfake" ]] && d=./
    _http[$_N_archives]=$url
    # Save the archive name
    [[ -z "$fn" ]] && fn=$(basename $url)
    _archive[$_N_archives]=$fn
    # Save the type of archive
    local ext=${fn##*.}
    _ext[$_N_archives]=$ext
    case "x$ext" in
	xfake|xbin|xsh|xlocal)
	    # A binary/executable does not have a directory
	    d=./
	    ;;
	xgit)
	    # Since the archive cannot be downloaded we
	    # use the direct archive directory
	    _archive[$_N_archives]=$url
	    ;;
    esac
    # Infer what the directory is
    local archive_d=${fn%.*tar.$ext}
    [[ ${#archive_d} -eq ${#fn} ]] && archive_d=${fn%.$ext}
    [[ -z "$d" ]] && d=$archive_d
    _directory[$_N_archives]=$d
    # Save the version
    [[ -z "$v" ]] && v=`expr match "$archive_d" '[^-_]*[-_]\([0-9.]*\)'`
    if [[ -z "$v" ]]; then
	v=`expr match "$archive_d" '[^0-9]*\([0-9.]*\)'`
    fi
    _version[$_N_archives]=$v
    # Save the settings
    _settings[$_N_archives]="$(build_get -default-setting[$b_idx])"
    # Save the package name...
    [[ -z "$package" ]] && package=${archive_d%$v}
    local len=${#package}
    if [[ ${package:$len-1} =~ [\-\._] ]]; then
	package=${package:0:$len-1}
    fi
    _package[$_N_archives]=$package
    # Save the alias for the package, defaulted to package
    [[ -z "$alias" ]] && alias=$package
    _alias[$_N_archives]=$alias
    # Save the hash look-up
    typeset -l lc_name="$alias"
    local tmp="${_index[$lc_name]}"
    if [[ -n "$tmp" ]]; then
	_index[$lc_name]="$tmp $_N_archives"
    else
	_index[$lc_name]="$_N_archives"
    fi
    # The default library is setup
    _libs[$_N_archives]=$_LIB_DEF$_CHOICE_SEP-l$package
    
    # Default the module name to this:
    _installed[$_N_archives]=$_I_TO_BE
    # Module prefix and the name of the module
    _mod_prefix[$_N_archives]="$(build_get -module-path[$b_idx])"
    tmp="$(build_get -build-module-path[$b_idx])"
    _mod_name[$_N_archives]=$(pack_list -lf "-X -p /" $tmp)
    _mod_name[$_N_archives]=${_mod_name[$_N_archives]%/}
    _mod_name[$_N_archives]=${_mod_name[$_N_archives]#/}
    # Install prefix and the installation path
    tmp="$(build_get -build-installation-path[$b_idx])"
    _install_prefix[$_N_archives]=$(build_get -installation-path[$b_idx])/$(pack_list -lf "-X -s /" $tmp)
    _install_prefix[$_N_archives]="${_install_prefix[$_N_archives]%/}"
    # Do not allow any white-space, what so ever
    _install_prefix[$_N_archives]="${_install_prefix[$_N_archives]// /}"

    if [[ -z "$lp" ]]; then
        # Just in case lib already exists
	_lib_prefix[$_N_archives]=lib
	if [[ -d "${_install_prefix[$_N_archives]}/lib" ]]; then
	    if [[ -d "${_install_prefix[$_N_archives]}/lib64" ]]; then
		_lib_prefix[$_N_archives]='lib lib64'
	    fi
	elif [[ -d "${_install_prefix[$_N_archives]}/lib64" ]]; then
	    _lib_prefix[$_N_archives]=lib64
	fi
    else
	_lib_prefix[$_N_archives]="$lp"
    fi
    # Install default values
    _mod_req[$_N_archives]=''
    [[ $no_def_mod -eq 0 ]] && \
	_mod_req[$_N_archives]="$(build_get -default-module[$b_idx])"
    _reject_host[$_N_archives]=''

    msg_install -message "Added $package[$v] to the install list"
}

# This function allows for setting data related to a package
function pack_set {
    local index=$_N_archives # Default to this
    local opt
    [[ $# -eq 0 ]] && return
    local alias version directory settings install query
    local mod_name package cmd cmd_flags req idx_alias
    local reject_h only_h
    local inst=-100
    local mod_prefix m mod_opt lib libs libs_c
    local up_pre_mod=0
    local tmp
    local in_cmd=0
    while [[ $# -gt 0 ]]; do
	# Process what is requested
	trim_em opt $1
	shift
	case $opt in
	    -no-path)
		inst=$_I_MOD ;;
	    -start-cmd)
		cmd="$1" ; shift
		in_cmd=1
		;;
	    -end-cmd)
		in_cmd=0
		;;
            -C|-command|-cmd) cmd="$1" ; shift ;;
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
		local tmp=''
		for m in ${_mod_req[$index]} ; do
		    if [[ "$m" != "$1" ]]; then
			tmp="$tmp $m"
		    fi
		done
		_mod_req[$index]="$tmp"
		shift ;;
            -prepend-module-requirement|-prepend-mod-req)
		tmp="$(pack_get -mod-req-all $1) ${_mod_req[$index]}"
		# reset to really prepend
		_mod_req[$index]=
		[[ -n "$tmp" ]] && req="$req $tmp"
		# We add the host-rejects for this requirement
		tmp="$(pack_get -host-reject $1)"
		[[ -n "$tmp" ]] && reject_h="$reject_h $tmp"
		req="$req $1" ; shift ;; # called several times
            -R|-module-requirement|-mod-req)
		tmp="$(pack_get -mod-req-all $1)"
		[[ -n "$tmp" ]] && req="$req $tmp"
		# We add the host-rejects for this requirement
		tmp="$(pack_get -host-reject $1)"
		[[ -n "$tmp" ]] && reject_h="$reject_h $tmp"
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
		if [[ $# -eq 0 ]]; then
		    doerr "pack_set" "You need to specify at least one choice"
		fi
		while [[ $# -gt 0 ]]; do
		    settings="$settings$_CHOICE_SEP$1"
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
	    -host-reject)  reject_h="$reject_h $1" ; shift ;; # Can be called several times
	    -lib*) # Has to be last due to *
		# Get the library choice
		libs_c=$(var_spec -s $opt)
		if [[ -z "$libs_c" ]]; then
		    libs_c=$_LIB_DEF
		fi
		# collect the libraries for this spec
		libs="$_CHOICE_SEP"
		while [[ $# -gt 1 ]]; do
		    libs="$libs$1 "
		    shift
		done
		libs="$libs$1"
		shift
		;;
	    *)
		if [[ $in_cmd -eq 1 ]]; then
		    cmd_flags="$cmd_flags $1" ; shift
		else
		    # We do a crude check
		    # We have an argument
		    index=$(get_index $opt)
		fi
		;; 
	esac
    done
    if [[ $up_pre_mod -eq 1 ]]; then
	# We have used prefix-and-module
	# we need to correct the fetching of the build path
	# This is only because we haven't used the index thing before
	opt=$(pack_get -build $index)
	install="$(build_get -installation-path[$opt])/$mod_name"
    fi
    # We now have index to be the correct spanning
    [[ -n "$cmd" ]] && _cmd[$index]="${_cmd[$index]}$cmd $cmd_flags${_LIST_SEP}"
    if [[ -n "$req" ]]; then
	req="${_mod_req[$index]} $req"
	# Remove dublicates:
	_mod_req[$index]="$(rem_dup $req)"
    fi
    if [[ -n "$install" ]]; then
	_install_prefix[$index]="${install// /}"
	if [[ -d "$install/lib" ]]; then
	    if [[ -d "$install/lib64" ]]; then
		lib='lib lib64'
	    else
		lib='lib'
	    fi
	elif [[ -d "$install/lib64" ]]; then
	    lib='lib64'
	fi
    fi
    [[ -n "$lib" ]] && _lib_prefix[$index]="$lib"
    if [[ -n "$libs_c" ]]; then
	# Note that $libs already have the $_CHOICE_SEP as the first
	# char...
	local -a sets=()
	IFS="$_LIST_SEP" read -ra sets <<< "${_libs[$index]}"
	# Initialize the libraries
	_libs[$index]="$libs_c$libs"
	# Loop and re-create the "missing" libraries
	local l_c
	local l_l
	for tmp in "${sets[@]}" ; do
	    # Skip empty sets
	    [[ -z "$tmp" ]] && continue
	    # Get library name
	    l_c="${tmp%%$_CHOICE_SEP*}"
	    l_l="${tmp#*$_CHOICE_SEP}"
	    if [[ "x$l_c" != "x$libs_c" ]]; then
		_libs[$index]="${_libs[$index]}$_LIST_SEP$l_c$_CHOICE_SEP$l_l"
	    fi
	done

    fi
    [[ "$inst" -ne '-100' ]]    && _installed[$index]="$inst"
    [[ -n "$query" ]]      && _install_query[$index]="$query"
    if [[ -n "$alias" ]]; then
	local v=''
	typeset -l lc_name="${_alias[$index]}"
	for v in ${_index[$lc_name]} ; do
	    [[ "$v" -ne "$index" ]] && tmp="$tmp $v"
	done
	if [[ -z "$tmp" ]]; then
	    unset _index[$lc_name]
	else
	    _index[$lc_name]="$tmp"
	fi
	_alias[$index]="$alias"
	lc_name="$alias"
	tmp="${_index[$lc_name]}"
	if [[ -z "$tmp" ]]; then
	    _index[$lc_name]="$index"
	else
	    _index[$lc_name]="$tmp $index"
	fi
    fi
    ## opted for deletion... (superseeded by explicit version comparisons...)
    [[ -n "$idx_alias" ]]  && _index[$idx_alias]="$index"
    [[ -n "$mod_opt" ]]    && _mod_opts[$index]="${_mod_opts[$index]}$mod_opt"
    [[ -n "$version" ]]    && _version[$index]="$version"
    [[ -n "$directory" ]]  && _directory[$index]="$directory"
    [[ -n "$settings" ]]   && _settings[$index]="${settings:1}$_LIST_SEP${_settings[$index]}"
    [[ -n "$mod_prefix" ]] && _mod_prefix[$index]="$mod_prefix"
    [[ -n "$mod_name" ]]   && _mod_name[$index]="$mod_name"
    [[ -n "$package" ]]    && _package[$index]="$package"
    [[ -n "$reject_h" ]]   && _reject_host[$index]="${_reject_host[$index]}$reject_h"
}

# This directly inserts the command in the list
# However, it only works for the current module
function pack_cmd {
    _cmd[$_N_archives]="${_cmd[$_N_archives]}$@${_LIST_SEP}"
}

# This function allows for setting data related to a package
# Should take at least one parameter (-a|-I...)
function pack_get {
    # Save the option passed
    local opt
    trim_em opt $1
    case $opt in
	-*) ;;
	*)
	    doerr "$1" "Could not determine the option for pack_get" ;;	    
    esac
    shift

    local tmp=
    
    # We check whether a specific index is requested
    local name=""
    local index
    case $# in
	1)
	    name=$1
	    index=$(get_index $1)
	    shift
	    ;;
	0)
	    index=$_N_archives
	    ;;
    esac
    [[ -z "$index" ]] && \
	doerr pack_get "Could not find index ($name)!"
    
    #echo "pack_get: lookup($1) idx($index)" >&2
    # Process what is requested
    case $opt in
	-build)              printf '%s' "${_build[$index]}" ;;
	-C|-commands)        printf '%s' "${_cmd[$index]}" ;;
	-h|-u|-url|-http)    printf '%s' "${_http[$index]}" ;;
	-module-load)
	    if [[ ! -z "${_mod_req[$index]}" ]]; then
		for m in ${_mod_req[$index]} ; do
		    printf '%s' "$(pack_get -module-name $m) "
		done
	    fi
	    printf '%s' "${_mod_name[$index]}"
	    ;;
	-R|-module-requirement|-mod-req)
	    if [[ ! -z "${_mod_req[$index]}" ]]; then
		for m in ${_mod_req[$index]} ; do
		    case $(pack_get -installed $m) in
			$_I_MOD|$_I_LIB|$_I_INSTALLED|$_I_TO_BE|$_I_REJECT) printf '%s' "$m " ;;
                    esac
		done
	    fi
	    ;;
	-mod-req-path)
	    if [[ ! -z "${_mod_req[$index]}" ]]; then
		for m in ${_mod_req[$index]} ; do
		    case $(pack_get -installed $m) in
			$_I_LIB|$_I_INSTALLED|$_I_TO_BE|$_I_REJECT) printf '%s' "$m " ;;
                    esac
		done
	    fi
	    ;;
	-mod-req-module)
	    if [[ ! -z "${_mod_req[$index]}" ]]; then
		for m in ${_mod_req[$index]} ; do
		    case $(pack_get -installed $m) in
			$_I_MOD|$_I_INSTALLED|$_I_TO_BE|$_I_REJECT) printf '%s' "$m " ;;
                    esac
		done
	    fi
	    ;;
	-module-requirement-all|-mod-req-all) 
            printf '%s' "${_mod_req[$index]}" ;;
	-module-name-requirement|-mod-req-name) 
	    if [[ ! -z "${_mod_req[$index]}" ]]; then
		for m in ${_mod_req[$index]} ; do
		    printf '%s' "$(pack_get -module-name $m) "
		done
	    fi
	    ;;
	-L|-LD|-library-path)
	    for p in ${_lib_prefix[$index]} ; do
		printf '%s' "${_install_prefix[$index]}/$p"
		break
	    done
	    ;;
	-L-all|-LD-all|-library-path-all)
	    local i=0
	    for p in ${_lib_prefix[$index]} ; do
		[[ $i -ge 1 ]] && printf '%s' ' '
		printf '%s' "${_install_prefix[$index]}/$p"
		let i++
	    done
	    ;;
	-L-suffix)    printf '%s' "${_lib_prefix[$index]}" ;;
	-MP|-module-prefix) 
            printf '%s' "${_mod_prefix[$index]}" ;;
	-I|-install-prefix|-prefix) 
            printf '%s' "${_install_prefix[$index]}" ;;
	-Q|-install-query)   printf '%s' "${_install_query[$index]}" ;;
	-a|-alias)           printf '%s' "${_alias[$index]}" ;;
	-A|-archive)         printf '%s' "${_archive[$index]}" ;;
	-v|-version)         printf '%s' "${_version[$index]}" ;;
	-d|-directory)       printf '%s' "${_directory[$index]}" ;;
	-s|-settings)        printf '%s' "${_settings[$index]}" ;;
	-installed)          printf '%s' "${_installed[$index]}" ;;
	-m|-module-name)     printf '%s' "${_mod_name[$index]}" ;;
	-module-opt)         printf '%s' "${_mod_opts[$index]}" ;;
	-p|-package)         printf '%s' "${_package[$index]}" ;;
	-e|-ext)             printf '%s' "${_ext[$index]}" ;;
	-host-reject)        printf '%s' "${_reject_host[$index]}" ;;
        -lib*)
	    # First retrieve the option library
	    local s=$(var_spec -s $opt)
	    # If the option is use the default option
	    [[ -z "$s" ]] && s=$_LIB_DEF
	    # Print the libraries for the choice
	    # Search for the library
	    choice $s "${_libs[$index]}"
	    ;;
	*)
	    doerr "$1" "No option for pack_get found for $1" ;;
    esac
}

# Returns a list of the choices for the package
#   $1 : name according to the choice
#   $2 : package
function pack_choice {
    local inst=0
    local opt
    # First check options
    while : ; do
	trim_em opt $1
	case $opt in
	    -installed|-i)
		# return first choice that is installed
		inst=1
		shift
		;;
	    *)
		break
		;;
	esac
    done
    local c=$1 ; shift
    local p=''
    [[ $# -gt 0 ]] && p="$1" && shift
    # Get choice-list
    p="$(pack_get -s $p)"
    # Return choice
    if [[ $inst -eq 1 ]]; then
	for opt in $(choice $c "$p") ; do
	    if [[ $(pack_installed $opt) -eq $_I_INSTALLED ]]; then
		printf '%s' "$opt"
		return 0
	    fi
	done
	return 1
    else
	choice $c "$p"
	return $?
    fi
}


#  Function pack_store
# Automatically adds commands to the current <package>
# which moves a test output to the installation folder
# of the <package> and gzips it.
#  Arguments
#    file
#       The test file to be moved.
#    dest-file (optional)
#       The name of the file when moved, defaults to `file`
function pack_store {
    local f=$1 ; shift
    local o=$f
    [[ $# -gt 0 ]] && o=$1 ; shift
    # move and gzip
    pack_cmd "mkdir -p $(pack_get -prefix)"
    pack_cmd "mv $f $(pack_get -prefix)/$o"
    pack_cmd "gzip -f $(pack_get -prefix)/$o"
}

# Debugging function for printing out every available
# information about a package
function pack_print {
    # It will only take one argument...
    local pack=$_N_archives
    [[ $# -gt 0 ]] && pack=$(get_index $1)
    echo " >> >> >> >> Package information"
    echo " P/A: $(pack_get -p $pack) / $(pack_get -a $pack)"
    echo " V  : $(pack_get -v $pack)"
    echo " BLD: $(pack_get -build $pack)"
    echo " DIR: $(pack_get -d $pack)"
    echo " URL: $(pack_get -http $pack)"
    echo " OUT: $(pack_get -A $pack)"
    echo " CMD: $(pack_get -commands $pack)"
    echo " MP : $(pack_get -module-prefix $pack)"
    echo " IP : $(pack_get -prefix $pack)"
    echo " LD : $(pack_get -L-all $pack)"
    echo " MN : $(pack_get -module-name $pack)"
    echo " IQ : $(pack_get -install-query $pack)"
    echo " REQ: $(pack_get -module-requirement $pack)"
    echo " REJ: $(pack_get -host-reject $pack)"
    echo " OPT: $(pack_get -module-opt $pack)"
    
    # Print out all the libraries associated
    # with this package
    local -a sets=()
    # Get all different libraries
    IFS="$_LIST_SEP" read -ra sets <<< "${_libs[$pack]}"
    local libc
    local lib
    local c
    for c in "${sets[@]}" ; do
	# Skip empty sets
	[[ -z "$c" ]] && continue
	# Get library name
	libc="${c%%$_CHOICE_SEP*}"
	lib="${c#*$_CHOICE_SEP}"
	if [[ "x$libc" == "x$_LIB_DEF" ]]; then
	    echo " LIBS[default]: $lib"
	else
	    echo " LIBS[$libc]: $lib"
	fi
    done
    echo "                                 << << << <<"
}


#  Function pack_dwn
# Downloads files using `dwn_file`.
#  Arguments
#    <package>
#       the package name. The package contains
#       information regarding the external archive http address.
#    path
#       downloads the archive to this path.
function pack_dwn {
    local idx=$(get_index $1)
    shift
    local ext=$(pack_get -ext $idx)
    case "x$ext" in
	xlocal|xgit|xsvn)
	    return 0
	    ;;
    esac
    local subdir=./
    if [[ $# -gt 0 ]]; then
	subdir="$1"
	shift
    fi
    local archive=$(pack_get -archive $idx)
    local url=$(pack_get -url $idx)
    dwn_file $url $subdir/$archive
}

# Update the package version number by looking at the date in the file
function pack_set_file_version {
    local idx=$_N_archives
    [[ $# -gt 0 ]] && idx=$(get_index $1)
    # Download the archive
    pack_dwn $idx $(build_get -archive-path)
    local v="$(get_file_time %g-%j $(build_get -archive-path)/$(pack_get -archive $idx))"
    pack_set -version "$v"
     # Default the module name to this:
    local b_name="$(pack_get -build $idx)"
    local tmp="$(build_get -build-module-path[$b_name])"
    tmp=$(pack_list -lf "-X -p /" $tmp)
    tmp=${tmp%/}
    tmp=${tmp#/}
    pack_set $idx -module-name $tmp
    local tmp="$(build_get -build-installation-path[$b_name])"
    pack_set $idx -prefix $(build_get -installation-path[$b_name])/$(pack_list -lf "-X -s /" $tmp)
    tmp=$(pack_get -prefix $idx)
    pack_set $idx -prefix ${tmp%/}
}

function pack_installed {
    local ret=$1 ; shift
    local idx
    idx=$(get_index $ret)
    if [[ $? -ne 0 ]]; then
	ret=$_I_REJECT
    else
	ret=$(pack_get -installed $idx)
	[[ -z "$ret" ]] && ret=0
	if [[ $ret -eq $_I_TO_BE ]]; then
	    pack_install $1 > /dev/null
	    ret=$(pack_get -installed $idx)
	fi
    fi
    printf '%s' $ret
}
