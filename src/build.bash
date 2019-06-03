# This source contains data structures and routines
# for managing several build systems.
#
# A build system consists of source files and default
# modules which are used for _all_ packages associated
# with that build.
# Of all builds in the system the user _has_ to choose
# a default build.
#
# For instance one could create a build for the
# gnu-compiler and the intel-compiler.
# Then the default could be gnu while certain
# packages _needed_ to be compiled with the intel-compiler.
# Such complex build systems is constituted using
# these datastructures and routines.


# The currently used default build is associated using this
_b_def_idx=0

# The name of the default build (not necessarily the same as _b_def_idx)
_b_name_default=generic
_b_name_generic=generic

# A build has a name for usage reference
declare -A _b_name
# A source file which contains compiler information.
declare -A _b_source
# A build-path, the directory of compilation
declare -A _b_build_path
# The default compilation path is the current working directory
# and the .compile directory
_b_build_path[$_b_def_idx]=$_cwd/.compile
mkdir -p ${_b_build_path[$_b_def_idx]}
# An installation prefix where <packages> are installed
declare -A _b_prefix
# The installation prefix for the module files
declare -A _b_mod_prefix
# The prefix for the installation paths
# The default is --package --version
# which basically means that the installation path becomes:
#   _b_prefix[0]/$(pack_get --package <package>)/$(pack_get --version <package>)
declare -A _b_build_prefix
_b_build_prefix[$_b_def_idx]="--package --version"
# Same as _build_prefix but for the module names
declare -A _b_build_mod_prefix
_b_build_mod_prefix[$_b_def_idx]="--package --version"
# If this build requires default modules.
# This is handy on HPC clusters where the installed
# compilers are plentyful and you want an installation
# with a specific compiler.
declare -A _b_def_mod_reqs
# Defaults a bunch of settings for all packages associated with
# this build.
declare -A _b_def_settings
# An array containing the sources that are to be rejected for this
# build.
# This consists of all local.reject + $(get_c -n).reject
declare -A _b_reject
# Pointers of lookup (faster indexing)
declare -A _b_index

# Counter to keep track of number of builds.
_N_b=-1

#  Function build_set
# Constructing a build is necessary using this
# wrapper function for constructing the data structures
# explained in the top of this file.
# It is heavily used when creating a build.
#  Arguments
#    <package>
#       Any message printed is associated to a package.
#       This package name refers to an already sourced
#       package installation so it can be looked up in the index
#       If not supplied, it will take the last added package
#       and use that as a reference.
#  Options
#    --archive-path|-ap <path>
#       Set the directory where package files are stored.
#       This is merely a data containing folder.
#       *Currently* this is a global variable for all builds.
#    --installation-path|-ip <path>
#       Set the installation prefix for all packages belonging to
#       this build.
#    --module-path|-mp <path>
#       Set the installation prefix for the modules.
#       This can be different than the installation path of the
#       packages to account for different positions of module files.
#    --build-path|-bp <path>
#       This build's compilation directory.
#       All compilations of this build will occur in this
#       folder.
#       This allows several builds to co-run when the installations
#       occur in differing paths.
#    --build-installation-path|-bip "str"
#       **APT FOR NAME CHANGE**
#       This denotes the path creation for each package.
#       Currently it does a:
#          path=
#          for opt in $str ; do path=$path/$(pack_get $opt) ; done
#       to figure out the accumulated path.
#    --build-module-path|-bmp "str"
#       **APT FOR NAME CHANGE**
#       This denotes the path creation for each package module file.
#       Currently it does a:
#          mod=
#          for opt in $str ; do mod=$mod/$(pack_get $opt) ; done
#       to figure out the accumulated path.
#    --default-module-hidden <package>
#       create a hidden module.
#       This enables one to by-pass directly library paths
#       and other options using modules "faked" by the build
#       system.
#       This is useful when referencing already existing modules
#       that does not get populated in this package installation
#       utility.
#       NOTE: Also calls --default-module to create it.
#    --default-module <package>
#       Append <package> to the default loaded modules
#       for all packages using this build.
#       It reduces the need to add "pack_set --mod-req <package>"
#       in all sources.
#    --reset-module
#       Clears all module requirements created by --default-module
#    --default-setting <setting>
#       Enables global settings for all packages using this build.
#       Reduces need for setting the setting in all sources.
#    --default-choice <name> <choice-1> <choice-2>
#       A special setting which enables a list of choices.
#       Can be used to select different things based on
#       existance.
#       For instance with BLAS libraries one could do:
#         build_set --default-choice blas openblas acml blas
#       which requires the package code to take into consideration
#       these choices.
#    --remove-default-setting
#       Remove a specific setting from the build
#       NOTE: Currently does not remove choices.
#    --default-build
#       Set the default build. I.e. it is not
#       related to a specific build, but lets the
#       user select a default build.
#    --default-module-version
#       Passing this forces the link of the module files
#       to their default.
#       Hence when doing several builds with, for instance, different
#       compilers the current builds will load by default.
#    --non-default-module-version
#       Unset the `--default-module-version`

function build_set {
    # We set up default parameters for creating the 
    # default package directory
    local tmp
    local opt
    local spec
    while [[ $# -gt 0 ]]; do
	trim_em opt $1
	local spec=$(var_spec -s $opt)
	if [[ -z "$spec" ]]; then
	    local b_idx=$_b_def_idx
	else
	    local b_idx=$(get_index --hash-array "_b_index" $spec)
	fi
	if [[ -z "$b_idx" ]]; then
	    doerr "$spec" "Unrecognized build, please create it first"
	    exit 1
	fi
	opt=$(var_spec $opt)
	shift
	case $opt in
	    -archive-path|-ap)
		_archives="$1"
		mkdir -p $1
		shift ;;
	    -installation-path|-ip)
		[[ $b_idx -eq 0 ]] && _prefix="$1"
		_b_prefix[$b_idx]="$1"
		mkdir -p $1
    		shift ;;
	    -module-path|-mp) 
		[[ $b_idx -eq 0 ]] && _modulepath="$1"
		_b_mod_prefix[$b_idx]="$1"
                # Create the module folders
		mkdir -p $1
		shift ;;
	    -build-path|-bp) 
		_buildpath="$1" 
		mkdir -p $_buildpath
		shift ;;
	    -build-installation-path|-bip) 
		[[ $b_idx -eq 0 ]] && _build_install_path="$1"
		_b_build_prefix[$b_idx]="$1"
		mkdir -p $1
		shift ;;
	    -build-module-path|-bmp) 
		[[ $b_idx -eq 0 ]] && _build_module_path="$1"
		_b_build_mod_prefix[$b_idx]="$1"
		mkdir -p $1
		shift ;;
	    -default-module-hidden) 
		local tmp=$(get_index $1)
		if [[ -z "$tmp" ]]; then
		    add_hidden_package "$1"
		fi
		# fall through BASH >= 4
		;&
	    -default-module) 
		local tmp=$(get_index $1)
		if [[ -n "$tmp" ]]; then
		    _b_def_mod_reqs[$b_idx]="${_b_def_mod_reqs[$b_idx]} $(pack_get --mod-req-all $tmp)"
		fi
		_b_def_mod_reqs[$b_idx]="${_b_def_mod_reqs[$b_idx]} $1"
		_b_def_mod_reqs[$b_idx]="$(rem_dup ${_b_def_mod_reqs[$b_idx]})"
		shift ;;
	    -reset-module) 
		_b_def_mod_reqs[$b_idx]=""
		;;
	    -default-setting)
		if [[ "${1:0:${#_LIST_SEP}}" == "$_LIST_SEP" ]]; then
		    _b_def_settings[$b_idx]="${_b_def_settings[$b_idx]}$1"
		else
		    _b_def_settings[$b_idx]="${_b_def_settings[$b_idx]}$_LIST_SEP$1"
		fi
		shift ;;
	    -default-choice)
		_b_def_settings[$b_idx]="${_b_def_settings[$b_idx]}$_LIST_SEP$1"
		shift
		if [[ $# -eq 0 ]]; then
		    doerr "BUILD-CHOICE" "You need to specify at least one choice"
		fi
		while [[ $# -gt 0 ]]; do
		    _b_def_settings[$b_idx]="${_b_def_settings[$b_idx]}$_CHOICE_SEP$1"
		    shift
		done
		;;
	    -remove-default-setting)
		tmp="${_b_def_settings[$b_idx]//$1/}"
		shift
		# Remove the setting from the list
		tmp="${tmp//$_LIST_SEP$_LIST_SEP/$_LIST_SEP}"
		_b_def_settings[$b_idx]="$tmp"
		;;
	    -default-build)
		switch_idx=0
		if [[ $# -gt 0 ]]; then
		    case $1 in
			-*) ;;
			*)
			    local switch_idx=$(get_index --hash-array "_b_index" $1)
			    [[ -z "$switch_idx" ]] && \
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
}


#  Function build_exist
# Check whether a given build exists.
#  Arguments
#    <build-name>
#       if <build-name> exists this function returns *true*
#
# Examples:
# if $(build_exist cuda) then
#    ...
# fi

function build_exist {
    local b_idx=$(get_index --hash-array "_b_index" $1)
    [[ -z "$b_idx" ]] && return 1
    return 0
}

#  Function build_get
# Retrieve information from a specific build.
#  Arguments
#    <package>
#       Any message printed is associated to a package.
#       This package name refers to an already sourced
#       package installation so it can be looked up in the index
#       If not supplied, it will take the last added package
#       and use that as a reference.
#  Options
#    --archive-path|-ap <path>
#       Return the directory where package files are stored.
#    --installation-path|-ip <path>
#       Return the installation prefix for all packages belonging to
#       this build.
#    --module-path|-mp <path>
#       Return the installation prefix for the modules.
#    --build-path|-bp <path>
#       Return this build's compilation directory.
#    --build-installation-path|-bip "str"
#       **APT FOR NAME CHANGE**
#       Return the path creation for each package.
#    --build-module-path|-bmp "str"
#       **APT FOR NAME CHANGE**
#       Return the path creation for each package module file.
#    --default-build
#       Return index of default build.
#    --default-setting
#       Return all settings for the current build
#    --default-module
#       Return all default modules
#    --source
#       Return source file belonging to this build
#    --rejects
#       Return all rejects that are associated with
#       this build

function build_get {
    # We set up default parameters for creating the 
    # default package directory
    local opt
    trim_em opt $1
    shift
    local spec=$(var_spec -s $opt)
    if [[ -z "$spec" ]]; then
	local b_idx=$_b_def_idx
    elif [[ "$spec" == "default" ]]; then
       	local b_idx=$(get_index --hash-array "_b_index" $_b_name_default)
    elif [[ "$spec" == "generic" ]]; then
       	local b_idx=$(get_index --hash-array "_b_index" $_b_name_generic)
    else
	local b_idx=$(get_index --hash-array "_b_index" $spec)
    fi
    [[ -z "$b_idx" ]] && doerr "Build index" "Build not existing ($opt and $spec)"
    opt=$(var_spec $opt)
    case $opt in
	-archive-path|-ap) printf '%s' "$_archives" ;;
	-name) printf '%s' "${_b_name[$b_idx]}" ;;
	-installation-path|-ip) printf '%s' "${_b_prefix[$b_idx]}" ;;
	-module-path|-mp) printf '%s' "${_b_mod_prefix[$b_idx]}" ;;
	-build-path|-bp) printf '%s' "${_b_build_path[$b_idx]}" ;;
	-build-installation-path|-bip) printf '%s' "${_b_build_prefix[$b_idx]}" ;;
	-build-module-path|-bmp) printf '%s' "${_b_build_mod_prefix[$b_idx]}" ;;
	-default-build) printf '%s' "$_b_def_idx" ;; 
	-default-setting) printf '%s' "${_b_def_settings[$b_idx]}" ;;
	-default-module) printf '%s' "${_b_def_mod_reqs[$b_idx]}" ;; 
	-def-module-version) printf '%s' "$_crt_version" ;; 
	-source) printf '%s' "${_b_source[$b_idx]}" ;; 
	-rejects) printf '%s' "${_b_reject[$b_idx]}" ;; 
	*) doerr "$opt" "Not a recognized option for build_get ($opt and $spec)" ;;
    esac
}

function new_build {
    local tmp
    # Simple command to initialize a new build
    let _N_b++
    # Initialize all the stuff
    _b_source[$_N_b]="${_b_source[$_b_def_idx]}"
    _b_prefix[$_N_b]="${_b_prefix[$_b_def_idx]}"
    _b_mod_prefix[$_N_b]="${_b_mod_prefix[$_b_def_idx]}"
    _b_build_prefix[$_N_b]="${_b_build_prefix[$_b_def_idx]}"
    _b_build_mod_prefix[$_N_b]="${_b_build_mod_prefix[$_b_def_idx]}"
    _b_build_path[$_N_b]="${_b_build_path[$_b_def_idx]}"
    _b_def_mod_reqs[$_N_b]=""
    # Read in options
    local opt
    while [[ $# -gt 1 ]]; do
	trim_em opt $1
	shift
	case $opt in 
	    # As a bonus, supplying name several time
	    # creates aliases! :)
	    -name) 
		_b_index[$(lc $1)]=$_N_b
		_b_name[$_N_b]="$1"
		if [[ $1 == default ]]; then
		    doerr "build-name" "A build cannot be name 'default'!"
		    exit 1
		fi
		shift ;;
	    -installation-path) 
		_b_prefix[$_N_b]="$1"
		mkdir -p $1
		shift ;;
	    -module-path) 
		_b_mod_prefix[$_N_b]="$1" 
		mkdir -p $1
		module is-used $1
		[ $? -ne 0 ] && module use -p $1
		shift ;;
	    -build-installation-path|-bip) 
		_b_build_prefix[$_N_b]="$1"
		shift ;;
	    -build-module-path|-bmp)
		_b_build_mod_prefix[$_N_b]="$1"
		shift ;;
	    -build-path|-bp)
		_b_build_path[$_N_b]="$1"
		mkdir -p $1
		shift ;;
	    -reset-module) 
		_b_def_mod_reqs[$_N_b]=""
		;;
	    -default-module-hidden) 
		tmp=$(get_index $1)
		if [[ -z "$tmp" ]]; then
		    msg_install --message "Adding hidden package $1"
		    add_hidden_package "$1"
		fi
		# fall through BASH >= 4
		;&
	    -default-module)
		tmp=$(get_index $1)
		if [[ -n "$tmp" ]]; then
		    _b_def_mod_reqs[$_N_b]="${_b_def_mod_reqs[$_N_b]} $(pack_get --module-requirement $tmp)"
		fi
		_b_def_mod_reqs[$_N_b]="${_b_def_mod_reqs[$_N_b]} $1"
		_b_def_mod_reqs[$_N_b]="$(rem_dup ${_b_def_mod_reqs[$_N_b]})"
		shift
		;;
	    -source)
		_b_source[$_N_b]="$(readlink -f $1)"
		shift
		[[ ! -e ${_b_source[$_N_b]} ]] && \
		    doerr "${_b_source[$_N_b]}" "Source file does not exist"
		;;
	    *)
		doerr "$opt" "Unrecognized option in new_build"
		;;
	esac
    done
    if [[ $# -gt 0 ]]; then
	_b_index[$1]=$_N_b
	_b_name[$_N_b]="$1"
	shift
    fi
    
    # Check for valid build-names
    case ${_b_name[$_N_b]} in
	mpi|la)
	    doerr "${_b_name[$_N_b]}" "Build names may not be any of: mpi|la"
	    ;;
    esac
    
    # Populate the local rejects for this build
    # This is all the default rejects
    for tmp in ${_host_reject[@]} ; do
	_b_reject[$_N_b]="${_b_reject[$_N_b]} $tmp"
    done
    # Add the local source rejects
    # First source the current build, to retrieve the
    # compiler information
    source ${_b_source[$_N_b]}

    local -a lines
    local f
    for f in $(get_hostname).$(get_c -n).reject $(get_c -n).reject .$(get_c -n).reject ; do
	if [[ -e $f ]]; then
	    read -d '\n' -a lines < $f
	    for tmp in ${lines[@]} ; do
		_b_reject[$_N_b]="${_b_reject[$_N_b]} $tmp"
	    done
	fi
    done
}



# Debugging function for printing out every available
# information about a build
function build_print {
    # It will only take one argument...
    local build=$_N_b
    [[ $# -gt 0 ]] && build=$(get_index --hash-array "_b_index" $1)
    shift
    echo " >> >> >> >> Build information"
    echo " NAM: $(build_get -name[$build])"
    echo " AP : $(build_get -ap[$build])"
    echo " IP : $(build_get -ip[$build])"
    echo " BP : $(build_get -bp[$build])"
    echo " BP X $(pack_list -lf "-X -p /" $(build_get -bp[$build]))"
    echo " BIP: $(build_get -bip[$build])"
    echo " BIPX $(pack_list -lf "-X -s /" $(build_get -bip[$build]))"
    echo " BMP: $(build_get -bmp[$build])"
    echo " BMPX $(pack_list -lf "-X -p /" $(build_get -bmp[$build]))"
    echo " DM : $(build_get -default-module[$build])"
    echo " S  : $(build_get -source[$build])"
    echo " SET: $(build_get -default-setting[$build])"
    echo "                                 << << << <<"
}
