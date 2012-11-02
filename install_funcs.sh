# This file should be sourced and used to compile the tools for compiling 
# different libraries.

# List of options for archival stuff
let "BUILD_DIR=1 << 0"
let "CONFIGURE=1 << 1"
let "MAKE_INSTALL=1 << 2"
let "MAKE_TEST=1 << 3"
let "MAKE_CHECK=1 << 4"
let "MAKE_PARALLEL=1 << 5"
let "MAKE_TESTS=1 << 6"
let "IS_MODULE=1 << 7"
let "LOAD_MODULE=1 << 8"

_prefix=""
# Instalation path
function set_installation_path { _prefix=$1 ; }
function get_installation_path { echo $_prefix ; }

_c=""
# Instalation path
function set_c { _c=$1 ; }
function get_c { echo $_c ; }

_modulepath=""
# Module path for creating the modules
function set_module_path { _modulepath=$1 ; }
function get_module_path { echo $_modulepath ; }

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
    local v=`expr match "$d" '.*[-_]\([0-9].*[0-9]\)'`
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
    # Default the module name to this:
    _mod_name[$_N_archives]=$package/$v/$(get_c)
}

# This function allows for setting data related to a package
function pack_set {
    local index=$_N_archives # Default to this
    local alias="" ; local version="" ; local directory=""
    local settings="0" ; local install="" ; local query=""
    local mod_name="" ; local package="" ; local opt=""
    while [ $# -gt 0 ]; do
	# Process what is requested
	local opt=$1
	case $opt in
	    --*) opt=${opt:1} ;;
	esac
	shift
	case $opt in
            -I|-install-prefix)  install="$1" ; shift ;;
            -Q|-install-query)  query="$1" ; shift ;;
	    -a|-alias)  alias="$1" ; shift ;;
            -v|-version)  version="$1" ; shift ;;
            -d|-directory)  directory="$1" ; shift ;;
	    -s|-setting)  settings=$((settings + $1)) ; shift ;; # Can be called several times
	    -m|-module-name)  mod_name="$1" ; shift ;;
	    -p|-package)  package="$1" ; shift ;;
	    *)
		# We do a crude check
		# We have an argument
		$(isnumber $opt)
		if [ $? -eq 0 ]; then # We have a number
		    index=$opt
		else
		    index=$(get_index $opt)
		fi
		shift $#
		echo "We break now on $opt and $#"
	esac
    done
    # We now have index to be the correct spanning
    [ ! -z "$install" ]    && _install_prefix[$index]=$install
    [ ! -z "$query" ]      && _install_query[$index]=$query
    [ ! -z "$alias" ]      && _alias[$index]=$alias
    [ ! -z "$version" ]    && _version[$index]=$version
    [ ! -z "$directory" ]  && _directory[$index]=$directory
    [ 0 -ne "$settings" ]  && _settings[$index]=$settings
    [ ! -z "$mod_name" ]   && _mod_name[$index]=$mod_name
    [ ! -z "$package" ]    && _package[$index]=$package
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
    if [ $# -gt 0 ]; then
	# We have an argument
	$(isnumber $1)
	if [ $? -eq 0 ]; then # We have a number
	    index=$1
	else
	    index=$(get_index $1)
	fi
    fi
    # Check that the index is valid
    [ "$index" -gt "$_N_archives" ] && return 1
    [ "$index" -lt 0 ] && return 1
    # Process what is requested
    case $opt in
	-h|-u|-url|-http)    echo ${_http[$index]} ;;
        -I|-install-prefix)  echo ${_install_prefix[$index]} ;;
        -Q|-install-query)   echo ${_install_query[$index]} ;;
        -a|-alias)           echo ${_alias[$index]} ;;
	-A|-archive)         echo ${_archive[$index]} ;;
        -v|-version)         echo ${_version[$index]} ;;
        -d|-directory)       echo ${_directory[$index]} ;;
        -s|-settings)        echo ${_settings[$index]} ;;
        -m|-module-name)     echo ${_mod_name[$index]} ;;
        -p|-package)         echo ${_package[$index]} ;;
        -e|-ext)             echo ${_ext[$index]} ;;
	*)
	    doerr $1 "No option for pack_get found for $1"
    esac
}


# Can be used to return the index in the _arrays for the named variable
# $1 is the shortname for what to search for
function get_index {
    local i=0 ; local package ; local alias ; local archive
    local l=${#1}
    while : ; do
	archive=$(pack_get --archive $i)
	package=$(pack_get --package $i)
	alias=$(pack_get --alias $i)
	if [ "x${archive:0:$l}" == "x$1" ]; then
	    echo $i
	    return 0
	fi
	if [ "x${package:0:$l}" == "x$1" ]; then
	    echo $i
	    return 0
	fi
	if [ "x${alias:0:$l}" == "x$1" ]; then
	    echo $i
	    return 0
	fi
	i=$((i+1))
	[ "$i" -gt "$_N_archives" ] && break
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
    local require=""; local conflict=""; local load=""
    while getopts ":n:v:P:M:H:W:R:C:L:h" opt; do
	case $opt in
            n)  name="$OPTARG" ;;
            v)  version="$OPTARG" ;;
            P)  path="$OPTARG" ;;
            M)  mod="$OPTARG" ;;
            R)  require="$require $OPTARG" ;; # Can be optioned several times
            L)  load="$load $OPTARG" ;; # Can be optioned several times
            C)  conflict="$conflict $OPTARG" ;; # Can be optioned several times
            H)  help="$OPTARG" ;;
            W)  whatis="$OPTARG" ;;
            h)  create_module_usage 0 ;;
            \?) echo "Invalid option: -$OPTARG"
		create_module_usage 1 ;;
            :)  echo "Option -$OPTARG requires an argument."
		create_module_usage 1 ;;
	esac
    done ; shift $((OPTIND-1)) ; OPTIND=1
    require=${require% } ; load=${load% } ; conflict=${conflict% }

    # Create the file to which we need to install the module script
    local mfile=$_modulepath/$mod

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
    if [ -n "$load" ]; then
	cat <<EOF >> $mfile
# This module will load the following modules
module load $load

EOF
    fi

    # Add requirement if needed
    if [ -n "$require" ]; then
	cat <<EOF >> $mfile
# List the requirements for loading which this module does want to use
prereq $require

EOF
    fi
    # Add conflict if needed
    if [ -n "$conflict" ]; then
	cat <<EOF >> $mfile
# List the conflicts which this module does not want to take part in
conflict $conflict

EOF
    fi
    # Add paths if they are available
    _add_module_if -d "$path/bin" $mfile \
	"prepend-path PATH             \$basepath/bin"
    _add_module_if -d "$path/man" $mfile \
	"prepend-path MANPATH          \$basepath/man"
    _add_module_if -d "$path/lib64" $mfile \
	"prepend-path LD_LIBRARY_PATH  \$basepath/lib64"
    _add_module_if -d "$path/lib" $mfile \
	"prepend-path LD_LIBRARY_PATH  \$basepath/lib"
    _add_module_if -d "$path/man" $mfile \
	"prepend-path MANPATH  \$basepath/man"
}

# Append to module file dependent on the existance of a
# directory or file
#   -d <directory>
#   -f <file>
#   $1 module file to append to
#   $2-? append this in one line to the file
function _add_module_if {
    local d="";local f=""
    while getopts ":d:f:h" opt; do
	case $opt in
            d)  d="$OPTARG" ;;
            f)  f="$OPTARG" ;;
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
function install {
    local n=""
    while getopts ":d:f:h" opt; do
	case $opt in
            F)  n="Finished" ;;
            I)  n="Installing" ;;
	esac
    done ; shift $((OPTIND-1)) ; OPTIND=1
    local cmd=$(arc_cmd $(pack_get --ext $1) )
    echo " ================================== "
    echo "            $n"
    echo " File    : $(pack_get --archive $1)"
    echo " Ext     : $(pack_get --ext $1)"
    echo " Ext CMD : $cmd"
    echo " Package : $(pack_get --package $1)"
    echo " Version : $(pack_get --version $1)"
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
        echo " # Archive: $(pack_get --archive $ar)"
    fi
    echo " # LDFLAGS: "$LDFLAGS
    echo " # INCFLAGS: "$INCFLAGS
    echo " # LIBS: "$LIBS
    echo " # PWD: "$(pwd)
    echo " # CMD: "${cmd[@]}
    echo " # ================================================================"
    ${cmd[@]}
    local st=$?
    echo "STATUS = $st"
    if (( $st != 0 )) ; then
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
function lc { echo $1 | tr '[A-Z]' '[a-z]' ; }

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



#init_install mfr_4.11.12.tar.gz
#init_install mfr.4.11.12.zip
#init_install mfr-4.11.12.zip

#set_module_path ./
#create_module -n mfr -v 4.11.12 -p ./test/stnoeh -H "sNTAOH ESA" -W " TNHAOSNE H" -r "as/212 aosnetuh/33"

# Check for a number
function isnumber { 
    printf '%d' "$1" &>/dev/null
}