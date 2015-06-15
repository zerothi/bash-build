

# The index of the default build...
_b_def_idx=0
# Name of setup (lookup-purposes)
declare -A _b_name
# source file
declare -A _b_source
# build path
declare -A _b_build_path
_b_build_path[$_b_def_idx]=$_cwd/.compile
# installation prefix
declare -A _b_prefix
# module installation prefix
declare -A _b_mod_prefix
# how to build the full installation path
declare -A _b_build_prefix
_b_build_prefix[$_b_def_idx]="--package --version"
# how to build the full module path
declare -A _b_build_mod_prefix
_b_build_mod_prefix[$_b_def_idx]="--package --version"
# default modules for this build
declare -A _b_def_mod_reqs
# default settings for this build
declare -A _b_def_settings
# Pointers of lookup
declare -A _b_index
_N_b=-1


# Denote how the module paths and installation paths should be
function build_set {
    [ $DEBUG -ne 0 ] && do_debug --enter build_set
    # We set up default parameters for creating the 
    # default package directory
    local tmp
    while [ $# -gt 0 ]; do
	local opt=$(trim_em $1)
	local spec=$(var_spec -s $opt)
	if [ -z "$spec" ]; then
	    local b_idx=$_b_def_idx
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
	    -default-module-hidden) 
		local tmp=$(get_index $1)
		if [ -z "$tmp" ]; then
		    add_hidden_package "$1"
		fi
		# fall through BASH >= 4
		;&
	    -default-module) 
		local tmp=$(get_index $1)
		if [ ! -z "$tmp" ]; then
		    _b_def_mod_reqs[$b_idx]="${_b_def_mod_reqs[$b_idx]} $(pack_get --mod-req-all $tmp)"
		fi
		_b_def_mod_reqs[$b_idx]="${_b_def_mod_reqs[$b_idx]} $1"
		_b_def_mod_reqs[$b_idx]="$(rem_dup ${_b_def_mod_reqs[$b_idx]})"
		shift ;;
	    -reset-module) 
		_b_def_mod_reqs[$b_idx]=""
		;;
	    -default-setting)
		_b_def_settings[$b_idx]="${_b_def_settings[$b_idx]}$_LIST_SEP$1"
		shift ;;
	    -default-choice)
		_b_def_settings[$b_idx]="${_b_def_settings[$b_idx]}$_LIST_SEP$1"
		shift
		if [ $# -eq 0 ]; then
		    doerr "BUILD-CHOICE" "You need to specify at least one choice"
		fi
		while [ $# -gt 0 ]; do
		    _b_def_settings[$b_idx]="${_b_def_settings[$b_idx]}|$1"
		    shift
		done
		;;
	    -remove-default-setting)
		tmp="${_b_def_settings[$b_idx]//$1/}" ; shift
		# Remove the setting from the list
		tmp="${tmp//$_LIST_SEP$_LIST_SEP/$_LIST_SEP}"
		_b_def_settings[$b_idx]="$tmp"
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
	local b_idx=$_b_def_idx
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
	-default-setting) _ps "${_b_def_settings[$b_idx]}" ;;
	-default-module) _ps "${_b_def_mod_reqs[$b_idx]}" ;; 
	-def-module-version) _ps "$_crt_version" ;; 
	-source) _ps "${_b_source[$b_idx]}" ;; 
	*) doerr "$opt" "Not a recognized option for build_get ($opt and $spec)" ;;
    esac
    [ $DEBUG -ne 0 ] && do_debug --return build_get
}

function new_build {
    # Simple command to initialize a new build
    let _N_b++
    # Initialize all the stuff
    _b_source[$_N_b]="${_b_source[$_b_def_idx]}"
    _b_prefix[$_N_b]="${_b_prefix[$_b_def_idx]}"
    _b_mod_prefix[$_N_b]="${_b_mod_prefix[$_b_def_idx]}"
    _b_build_prefix[$_N_b]="${_b_build_prefix[$_b_def_idx]}"
    _b_build_mod_prefix[$_N_b]="${_b_build_mod_prefix[$_b_def_idx]}"
    _b_build_path[$_N_b]="${_b_build_path[$_b_def_idx]}"
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
	    -reset-module) 
		_b_def_mod_reqs[$_N_b]=""
		;;
	    -default-module-hidden) 
		local tmp=$(get_index $1)
		if [ -z "$tmp" ]; then
		    msg_install --message "Adding hidden package $1"
		    add_hidden_package "$1"
		fi
		# fall through BASH >= 4
		;&
	    -default-module) 
		local tmp=$(get_index $1)
		if [ ! -z "$tmp" ]; then
		    _b_def_mod_reqs[$_N_b]="${_b_def_mod_reqs[$_N_b]} $(pack_get --module-requirement $1)"
		fi
		_b_def_mod_reqs[$_N_b]="${_b_def_mod_reqs[$_N_b]} $1"
		_b_def_mod_reqs[$_N_b]="$(rem_dup ${_b_def_mod_reqs[$_N_b]})"
		shift ;;
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
