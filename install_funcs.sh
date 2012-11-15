# This file should be sourced and used to compile the tools for compiling 
# different libraries.

# List of options for archival stuff
let "BUILD_DIR=1 << 0"
let "MAKE_PARALLEL=1 << 1"
let "VERSION_TIME_STAMP=1 << 2"
let "IS_MODULE=1 << 3"
let "UPDATE_MODULE_NAME=1 << 4"
let "PRELOAD_MODULE=1 << 5"

_prefix=""
# Instalation path
function set_installation_path { _prefix=$1 ; }
function get_installation_path { echo $_prefix ; }

_c=""
# Instalation path
function set_c { _c=$1 ; }
function get_c { echo $_c ; }

_parent_package=""
# The parent package (for instance Python)
function set_parent { _parent_package=$1 ; }
function clear_parent { _parent_package="" ; }
function get_parent { echo $_parent_package ; }

_parent_exec=""
# The parent package (for instance Python)
function set_parent_exec { _parent_exec=$1 ; }
function get_parent_exec { echo $_parent_exec ; }

_modulepath=""
# Module path for creating the modules
function set_module_path { _modulepath=$1 ; }
function get_module_path { echo $_modulepath ; }

_buildpath="./"
# Path for downloading and extracting the packages
function set_build_path { _buildpath=$1 ; for d in $1 $1/.archives $1/.compile ; do mkdir -p $d ; done ; }
function get_build_path { echo $_buildpath ; }

# Figure out the number of cores on the machine
_n_procs=$(grep "cpu cores" /proc/cpuinfo | awk '{print $NF ; exit 0 ;}')
export NPROCS=$_n_procs


# Based on the extension which command should be called
# to extract the archive
function arc_cmd {
    local ext="$1"
    if [ "x$ext" == "xbz2" ]; then
	echo "tar jxf"
    elif [ "x$ext" == "xgz" ]; then
	echo "tar zxf"
    elif [ "x$ext" == "xtgz" ]; then
	echo "tar zxf"
    elif [ "x$ext" == "xtar" ]; then
	echo "tar xf"
    elif [ "x$ext" == "xzip" ]; then
	echo unzip
    elif [ "x$ext" == "xpy" ]; then
	echo "ln -fs"
    else
	doerr "Unrecognized extension $ext in [bz2,tgz,gz,tar,zip]"
    fi
}

#
# Using wget we will collect the giving file
# $1 http path 
# $2 outdirectory
function dwn_file {
    local subdir=./
    if [ $# -gt 1 ]; then
	subdir=$2
    fi
    [ -e $subdir/$(pack_get --archive $1) ] && return 0
    wget $(pack_get --url $1) -O $subdir/$(pack_get --archive $1)
}


#
# Extract file 
# $1 subdirectory of archive
# $2 index or name of archive
function extract_archive {
    local d=$(pack_get --directory $2)
    local cmd=$(arc_cmd $(pack_get --ext $2) )
    [ -d $1/$d ] && rm -rf $1/$d
    docmd $(pack_get --archive $2) $cmd $1/$(pack_get --archive $2)
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
# A separator used for commands that can be given consequitively
_LIST_SEP='Ø'
# The counter to hold the archives
_N_archives=-1

# $1 http path
function add_package {
    _N_archives=$(( _N_archives + 1 ))
    # Save the url 
    local url=$1
    _http[$_N_archives]=$url
    # Save the archive name
    local fn=$(basename $url)
    _archive[$_N_archives]=$fn
    # Save the type of archive
    local ext=$(echo $fn | awk -F. '{print $NF}')
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
    # Update version for the package in case of time-stamping
    if [ $(has_setting $VERSION_TIME_STAMP $_N_archives) ]; then
        # Download the archive
	dwn_file $_N_archives $(get_build_path)/.archives
	v="$(get_file_time %g-%j $(get_build_path)/.archives/$(pack_get --archive $_N_archives))"
	_version[$_N_archives]="$v"
    fi
    # Default the module name to this:
    _mod_name[$_N_archives]=$package/$v/$(get_c)
    _install_prefix[$_N_archives]=$(get_installation_path)/$package/$v/$(get_c)
}

# This function allows for setting data related to a package
function pack_set {
    local index=$_N_archives # Default to this
    local alias="" ; local version="" ; local directory=""
    local settings="0" ; local install="" ; local query=""
    local mod_name="" ; local package="" ; local opt=""
    local cmd="" ; local cmd_flags="" ; local req=""
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
            -R|-module-requirement)  req="$req $1" ; shift ;; # called several times
            -Q|-install-query)  query="$1" ; shift ;;
	    -a|-alias)  alias="$1" ; shift ;;
            -v|-version)  version="$1" ; shift ;;
            -d|-directory)  directory="$1" ; shift ;;
	    -s|-setting)  settings=$((settings + $1)) ; shift ;; # Can be called several times
	    -m|-module-name)  mod_name="$1" ; shift ;;
	    -prefix-and-module)  mod_name="$1" ; install="$(get_installation_path)/$1" ; shift ;;
	    -p|-package)  package="$1" ; shift ;;
	    *)
		# We do a crude check
		# We have an argument
		index=$(get_index $opt)
		shift $#
	esac
    done
    # We now have index to be the correct spanning
    [ ! -z "$cmd" ]        && _cmd[$index]="${_cmd[$index]}$cmd $cmd_flags${_LIST_SEP}"
    [ ! -z "$req" ]        && _mod_req[$index]="${_mod_req[$index]}$req"
    [ ! -z "$install" ]    && _install_prefix[$index]="$install"
    [ ! -z "$query" ]      && _install_query[$index]="$query"
    [ ! -z "$alias" ]      && _alias[$index]="$alias"
    [ ! -z "$version" ]    && _version[$index]="$version"
    [ ! -z "$directory" ]  && _directory[$index]="$directory"
    [ 0 -ne "$settings" ]  && _settings[$index]="$settings"
    [ ! -z "$mod_name" ]   && _mod_name[$index]="$mod_name"
    [ ! -z "$package" ]    && _package[$index]="$package"
}

# This function allows for setting data related to a package
# Should take at least one parameter (-a|-I...)
function pack_get {
    local opt=$1 # Save the option passed
    case $opt in
	--*) opt=${opt:1} ;;
    esac
    shift
    local index=$_N_archives # Default to this
    # We check whether a specific index is requested
    [ $# -gt 0 ] && index=$(get_index $1)
    # Check that the index is valid
    [ "$index" -gt "$_N_archives" ] && return 1
    [ "$index" -lt 0 ] && return 1
    # Process what is requested
    case $opt in
	-C|-commands)        echo "${_cmd[$index]}" ;;
	-h|-u|-url|-http)    echo "${_http[$index]}" ;;
	-R|-module-requirement) 
                             echo "${_mod_req[$index]}" ;;
        -I|-install-prefix|-prefix) 
                             echo "${_install_prefix[$index]}" ;;
        -Q|-install-query)   echo "${_install_query[$index]}" ;;
        -a|-alias)           echo "${_alias[$index]}" ;;
	-A|-archive)         echo "${_archive[$index]}" ;;
        -v|-version)         echo "${_version[$index]}" ;;
        -d|-directory)       echo "${_directory[$index]}" ;;
        -s|-settings)        echo "${_settings[$index]}" ;;
        -m|-module-name)     echo "${_mod_name[$index]}" ;;
        -p|-package)         echo "${_package[$index]}" ;;
        -e|-ext)             echo "${_ext[$index]}" ;;
	*)
	    doerr $1 "No option for pack_get found for $1" ;;
    esac
}

# Function to return a list of space seperated quantities with prefix and suffix
function list {
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
	    -Wlrpath)      pre="-Wl,-rpath=" ; suf="/lib" ; lcmd="pack_get --install-prefix " ;;
	    -LDFLAGS)      pre="-L" ; suf="/lib" ; lcmd="pack_get --install-prefix " ;;
	    -INCDIRS)      pre="-I" ; suf="/include" ; lcmd="pack_get --install-prefix " ;;
	    *)
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
    echo "$retval"
}


# Install the package
function pack_install {
    local idx=$_N_archives
    if [ $# -ne 0 ]; then
	idx=$1
    fi
    
    # We install the package
    local archive=""
    archive="$(pack_get --archive $idx)"
    [ $? -ne "0" ] && return 1

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
	local module_loads=""
	cmds="$(pack_get --module-requirement $idx)"
	# Clear the requirement if it is not found
	if [ ! -z "$cmds" ]; then
	    for cmd in $cmds ; do
		module_loads="$module_loads $(pack_get --module-name $cmd)"
	    done
	fi
	[ ! -z "$module_loads" ] && \
	    module load $module_loads
	
        # Show that we will install
	msg_install --start $idx

        # Download archive
	dwn_file $idx $(get_build_path)/.archives
	
        # Extract the archive
	pushd $(get_build_path)/.compile
	# Remove directory if already existing
	rm -rf $(pack_get --directory $idx)
	extract_archive $(get_build_path)/.archives $idx
	pushd $(pack_get --directory $idx)
	
        # We are now in the package directory
	if [ $(has_setting $BUILD_DIR $idx) ]; then
	    rm -rf build-tmp ; mkdir -p build-tmp ; popd ; pushd $(pack_get --directory $idx)/build-tmp
	fi
	
	# Run all commands
	local cmd="$(pack_get --commands $idx)"
	local -a cmds=()
	IFS="$_LIST_SEP" read -ra cmds <<< "$cmd"
	for cmd in "${cmds[@]}" ; do
	    docmd "$archive" "$cmd"
	done

	popd

        # Remove compilation directory
	rm -rf $(pack_get --directory $idx)
	
	popd
	msg_install --finish $idx
	
	# Unload the requirement modules
	[ ! -z "$module_loads" ] && \
	    module unload $module_loads

	# Unload the module itself in case of PRELOADING
	if [ $(has_setting $PRELOAD_MODULE) ]; then
	    module unload $(pack_get --module-name $idx)
	fi

    else
	msg_install --already-installed $idx
    fi

    if [ $(has_setting $IS_MODULE $idx) ]; then
        # Create the list of requirements
	local reqs=""
	cmds="$(pack_get --module-requirement $idx)"
	# Clear the requirement if it is not found
	if [ ! -z "$cmds" ]; then
	    for cmd in $cmds ; do
		reqs="$reqs -R $(pack_get --module-name $cmd)"
	    done
	fi
        # We install the module scripts here:
	create_module \
	    -n $(pack_get --alias $idx) \
	    -v $(pack_get --version $idx) \
	    -M $(pack_get --module-name $idx) \
	    -P $(pack_get --install-prefix $idx) $reqs
    fi
}

# Can be used to return the index in the _arrays for the named variable
# $1 is the shortname for what to search for
function get_index {
    local i ; local lookup
    local l=${#1}
    $(isnumber $1)
    if [ $? -eq 0 ]; then # We have a number
	echo $1
	return 0
    fi
    for lookup in alias archive package ; do
	i=0
	while : ; do
	    local tmp=$(pack_get --$lookup $i)
	    if [ "x$(lc ${tmp:0:$l})" == "x$(lc $1)" ]; then
		echo $i
		return 0
	    fi
	    i=$((i+1))
	    [ "$i" -gt "$_N_archives" ] && break
	done
    done
    doerr $1 "Could not find the archive in the list..."
}

# Has setting returns 1 for success and 0 for fail
#   $1 : <setting>
#   $2 : <index|name of archive>
function has_setting {
    local tmp
    let "tmp=$1 & $(pack_get -s $2)"
    [ $tmp -gt 0 ] && echo true
    echo ""
}
    
# Returns the -j <procs> flag for the make command
# If the MAKE_PARALLEL setting has been enabled.
#   $1 : <index of archive>
function get_make_parallel {
    if [ $(has_setting $MAKE_PARALLEL $1) ]; then
	echo "-j $_n_procs"
    else
	echo ""
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
}

# Append to module file dependent on the existance of a
# directory or file
#   -d <directory>
#   -f <file>
#   $1 module file to append to
#   $2-? append this in one line to the file
function _add_module_if {
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
	return 0
    fi; return 1
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
	esac
    done
    local cmd=$(arc_cmd $(pack_get --ext $1) )
    echo " ================================== "
    echo "            $n"
    if [ "$action" -eq "1" ]; then
	echo " File    : $(pack_get --archive $1)"
	echo " Ext     : $(pack_get --ext $1)"
	echo " Ext CMD : $cmd"
    fi
    echo " Package : $(pack_get --package $1)"
    if [ "$(pack_get --package $1)" != "$(pack_get --alias $1)" ]; then
	echo " Alias   : $(pack_get --alias $1)"
    fi	
    echo " Version : $(pack_get --version $1)"
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
    if [[ "$ar" != "" ]] ; then
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
	echo $_N_archives
    else
	echo $1
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
    echo `date +"$format" --date="$fdate"`    
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
