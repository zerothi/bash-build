# File for auxillary commands used in the command line tools

#  Function msg_install
# Helps in printing out information for the user while
# running.
# Used heavily to inform user of things happening during the
# installation.
#  Arguments
#    <package>
#       Any message printed is associated to a package.
#       This package name refers to an already sourced
#       package installation so it can be looked up in the index
#       If not supplied, it will take the last added package
#       and use that as a reference.
#  Options
#    --start|-S
#      Informs of starting an installation of a new package.
#      Also prints the currently loaded modules
#    --finish|-F
#      Informs that a package has finished the installation.
#    --already-installed
#      Informs that a package has already been installed.
#    --message
#      Broadcast a specific message.
#      If this option is used, no information regarding the
#      <package> is used.

function msg_install {
    local n opt pack
    local action=0
    while [[ $# -gt 1 ]]; do
	trim_em opt $1
	case $opt in
	    -start|-S)
		action=1
		n='Installing'
		;;
	    -finish|-F)
		action=2
		n='Finished'
		;;
	    -already-installed)
		action=3
		n='Already installed'
		;;
	    -message)
		shift
		action=4
		n="$1"
		;;
	    -package)
		shift
		action=5
		n="$1"
		;;
	    -modules)
		action=6
		n='List currently loaded modules'
		;;
	    *) break ;;
	esac
	shift
    done
    case $# in
	0)
	    pack=$_N_archives
	    ;;
	*)
	    pack=$(get_index $1)
	    ;;
    esac

    echo '=================================='
    echo "  $n"
    case $action in
	4)
	    ;;
	6)
	    module list 2>&1
	    ;;
	1)
	    echo " File    : $(pack_get --archive $pack)"
	    local _e=$(pack_get --ext $pack)
	    echo " Ext     : $_e"
	    echo " Ext CMD : $(arc_cmd $_e)"
	    ;;
	*)
	    local _p=$(pack_get --package $pack)
	    local _a=$(pack_get --alias $pack)
	    echo " Package : $_p"
	    if [[ "$_p" != "$_a" ]]; then
		echo " Alias   : $_a"
	    fi	
	    echo " Version : $(pack_get --version $pack)"
	    ;;
    esac
    echo '=================================='
}


#  Function docmd
# Runs all passed arguments by first informing the
# user of said command, then executes it.
# Everything is runned using `eval`, hence any standard
# bash compliant function can be used in this environment.
#  Arguments
#    <package>
#       Prints which package the command belongs to.
#    commands
#       All arguments are passed directly to `eval`.
#       The commands will be shown for the user before execution.

function docmd {
    local message="$1"
    shift
    local cmd=($*)
    # Shift to prevent msg_install to be passed extra arguments
    shift $#
    echo ''
    echo ' # ================================================================'
    echo " # $message"
    echo " # PWD: $(pwd)"
    echo " # CMD: ${cmd[@]}"
    echo ' # ================================================================'
    local st
    eval ${cmd[@]}
    st=$?
    if [[ $st -ne 0 ]]; then
	message="Failed CMD (STATUS=$st): ${cmd[@]}"
	msg_install --message "$message"
        return $st
    fi
}

# Array containing the stack of the routines currently in
declare -a _r_stack
_N_r=0

#  Function push_r
# Pushes a routine name to the top of the stack such that
# a traceback may be created.
#

function push_r {
    let _N_r++
    _r_stack[$_N_r]="$1"
    shift
}
    
#  Function pop_r
# Pops a routine and removes it from the stack.
#

function pop_r {
    unset _r_stack[$_N_r]
    let _N_r--
}
    

#  Function trim_em
# Takes one argument, if it has two em-dashes in front,
# it returns the equivalent with only one em-dash.
# Otherwise it returns the argument as received.
#  Arguments
#    var
#       variable to store result in
#    str
#       Removes one em-dash if the `str` starts with two or
#       more em-dashes.

function trim_em {
    local -n var=$1
    var="${2/#--/-}"
}

#  Function trim_spaces
# Removes all superfluous space. Prefix, suffix and double spaces.
# I.e. a string of "  the cat  was small  . Said I"
# would return a string of "the cat was small . Said I"
#  Arguments
#    str
#       Truncates all spaces to a minimum of one space.

function trim_spaces {
    local str="$@"
    # remove leading whitespace characters
    str="${str# }"
    # remove trailing whitespace characters
    str="${str% }"
    # remove all double whitespace characters
    printf '%s' "${str//  / }"
}

#  Function var_spec
# Takes a package name and version specification
# and returns what is requested.
# Defaults to returning the package name
#  Arguments
#    package(s)
#       A package specification in either of these formats:
#         foo[bar]
#         foo
#       In the above case is `foo` the package name
#       and `bar` is the version string of package `foo`.
#       Works with multiple packages given as multiple arguments.
#  Options
#    --var|-v
#      Returns the variable name, default.
#    --spec|-s
#      Returns the version string.
#      If a package specification is given without version,
#      an empty string is returned.

function var_spec {
    local opt
    trim_em opt $1
    case $opt in
	-spec|-s)
	    shift

	    if [[ "${1:${#1}-1}" == "]" ]]; then
		opt=${1##*\[}
		opt=${opt//\]/}
	    else
		opt=''
	    fi
	    printf '%s' "${opt// /}"

	    ;;
	-var|-v)
	    shift
	    ;&
	*)

	    opt=${1%%\[*}
	    printf '%s' "${opt// /}"
	    ;;

    esac
}


#  Function str_version
# Enables to retrieve specific versions from a string.
# I.e. it disects a version.
#  Arguments
#    str
#       A string which is a dot separated version number.
#         a.4.5.0
#       Currently it runs 4 levels of versions,
#          a == major
#          4 == minor
#          5 == revision
#          0 == bug
#  Options
#    major|-major|-1
#      Returns the major index (a)
#    minor|-minor|-2
#      Returns the minor index (4)
#    rev|-rev|-3
#      Returns the rev index (5)
#    bug|-bug|-4
#      Returns the bug index (0)

function str_version {
    local Mv mv rv fourth
    local opt=-1
    if [[ $# -eq 2 ]]; then
	trim_em opt $1
	shift
    fi
    local str="${1// /}"
    str="${str//-/.}" # enables easy conversion of versions from <major>-<minor> to <major>.<minor>
    #echo "str_version: splitting version: ($str)" >&2
    # Check which type of versioning we have
    case $str in
	*.*.*.*)
	    Mv="${str%.*.*.*}"
	    str="${str#*.}"
	    mv="${str%.*.*}"
	    str="${str#*.}"
	    rv="${str%.*}"
	    fourth="${str#*.}"
	    ;;
	*.*.*)
	    Mv="${str%.*.*}"
	    str="${str#*.}"
	    mv="${str%.*}"
	    rv="${str#*.}"
	    ;;
	*.*)
	    Mv="${str%.*}"
	    mv="${str#*.}"
	    ;;
	*)
	    Mv=${str}
	    ;;
    esac
    case $opt in 
	major|-major|-1)
	    printf '%s' "$Mv"
	    ;;
	minor|-minor|-2)
	    printf '%s' "$mv"
	    ;;
	rev|-rev|-3)
	    printf '%s' "$rv"
	    ;;
	bug|-bug|-4)
	    printf '%s' "$fourth"
	    ;;
	*)
	    doerr "$opt" "Unknown print-out of version"
	    ;;
    esac	    
}

#  Function vrs_cmp
# Compares two version arguments down till the fourth level.
# It has this return table
#    #1  > #2 : Return 1
#    #1 == #2 : Return 0
#    #1 <  #2 : Return -1
# Uses `str_version` to extract the separate version numbers.
# NOTE: Currently only works with integer comparisons.
#  Arguments
#    version1
#       First version string.
#    version2
#       Second version string.

function vrs_cmp {
    local lhs=$1
    local rhs=$2
    local lv rv
    shift 2
    for o in -1 -2 -3 -4 ; do
	lv=$(str_version $o $lhs)
	[[ -z "$lv" ]] && break
	rv=$(str_version $o $rhs)
	[[ -z "$rv" ]] && break
	if (isnumber $lv) && (isnumber $rv) ; then
	    [[ $lv -gt $rv ]] && printf '%s' "1" && return 0
	    [[ $lv -lt $rv ]] && printf '%s' "-1" && return 0
	else
	    # Currently we do not do character versioning
	    # properly
	    [[ "$lv" != "$rv" ]] && printf '%s' '-1000' && return 0
	fi
    done
    printf '%s' "0"
}


#  Function lc
# Returns the argument as lowercase.
#  Arguments
#    <args>
#       Returns <args> as lowercase characters.

function lc {
    printf '%s' "${1,,}"
    shift
    while [[ $# -gt 0 ]]; do
	printf '%s' " ${1,,}"
	shift
    done
}

#  Function get_file_time
# Returns the date the file has last been edited.
#  Arguments
#    dateformat
#       The date-format used to print the date (see `date`
#       for available formats)
#    file
#       Does a `stat` on file `file` and returns the date.

function get_file_time {
    local format="$1"
    local fdate=$(stat -L -c '%y' $2)
    shift 2
    printf '%s' "`date +"$format" --date="$fdate"`"
}


#  Function isnumber
# Relies on the status return to tell whether
# a string is a number or not.
# Does so by trying to print the argument in `printf`.
#  Arguments
#    str
#       String to check whether it is a number.
#       If it is the status `$?` is 0, otherwise non-zero.
#  Example
# if $(isnumber 2) ; then
#    echo SUCCESS
# else
#    echo FAILURE
# fi

function isnumber { 
    printf '%d' "$1" &>/dev/null
}


#  Function rem_dup
# Removes any duplicates in a string (preserves order).
# It relies on external commands, `sed`, `tr` and `awk.
# The algorithm is:
#   1. remove all empty fields (removes double spaces) and ' ' to '\n'
#   2. awk one-liner for not printing any duplicates
#   3. translate '\n' to ' '
#  Arguments
#    <args>
#       The list of args to remove duplicates from
#       The order is preserved.

function rem_dup {
    # Apparently we cannot use printf '%s' here!!!!
    # Hence the first argument must never be an option
    # for `echo`.
    echo -n "$@" | \
	sed -e 's/[[:space:]]\+/ /g;s/ /\n/g' | \
	awk '!_[$0]++' | \
	tr '\n' ' '
}


#  Function ret_uniq
# Returns all unique entries in arguments.
# Will not return any entry that is encountered more than
# once.
#  Arguments
#    <args>
#       The list of args to return unique values from
#       The order is preserved.

function ret_uniq {
    # Apparently we cannot use printf '%s' here!!!!
    echo -n "$@" | \
	sed -e 's/[[:space:]]\+/ /g;s/ /\n/g' | \
	awk 'BEGIN { c=0 } {
if( $0 in a) {} else {b[c]=$0 ; c++ }
a[$0]++} END {for (i=0 ; i<c;i++) if (a[b[i]]==1) {print b[i]}}' | \
	tr '\n' ' '
}


#  Function arc_cmd
# Returns command that extracts the extension (without verbosity).
# Currently handles these extensions:
#   bz2, lz, xz, gz, tgz, tar, zip
# The following arguments are specially treated:
#   local, fake, sh : returns `echo` as no extraction is necessary
#   py : links the file so that it is local.
#  Arguments
#    ext
#       Checks the extension and returns an un compression command
#       that can un-compress that file.

function arc_cmd {
    typeset -l ext="$1"
    case $ext in
	bz2)
	    printf '%s' 'tar jxf'
	    ;;
	xz)
	    printf '%s' 'tar Jxf'
	    ;;
	tar.gz|gz|tgz)
	    printf '%s' 'tar zxf'
	    ;;
	tar.lz|lz|tlz)
	    printf '%s' 'tar xf'
	    ;;
	tar)
	    printf '%s' 'tar xf'
	    ;;
	zip)
	    printf '%s' 'unzip'
	    ;;
	py|sh)
	    printf '%s' 'ln -fs'
	    ;;
	local|bin|fake)
	    printf '%s' 'echo'
	    ;;
	git)
	    # This of course limits to depth 5, so the url should have additional options
	    printf '%s' 'git clone -q'
	    ;;
	*)
	    doerr "Unrecognized extension $ext in [bz2,xz,lz,tgz,gz,tar,zip,py,sh,git,local/bin/fake]"
	    ;;
    esac
}


#  Function extract_archive
# Takes a directory and a package name as argument.
# Extracts the archive belonging to package and extracts it
# to the directory.
#  Arguments
#    <package>
#       the package name. Looks up the package, extracts the
#       archive from the saved package, and extracts it.
#    dir
#       The directory that the archive is located in

function extract_archive {
    local id=$(get_index $1)
    shift
    local loc="$1/"
    local d=$(pack_get --directory $id)
    local ext=$(pack_get --ext $id)
    local archive=$(pack_get --archive $id)
    # If a previous extraction already exists (delete it!)
    case $d in
	.|./)
	    noop
	    ;;
	*)
	    if [[ -d "$loc$d" ]]; then
		rm -rf "$loc$d"
	    fi
	    ;;
    esac
    case $ext in
	local|bin|fake)
	    return 0
	    ;;
	git)
	    loc=''
	    ;;
    esac
    docmd "Archive $(pack_get --alias $id) ($(pack_get --version $id))" $(arc_cmd $ext) $loc$archive
    return $?
}

# Denote the download function
_dwn_exe='wget --no-proxy --no-check-certificate -O'

#  Function dwn_file
# Downloads files using `wget`, without proxies or certificates.
# If the download fails, it will produce an error.
# Hence, if you are located behind a proxy, the script will fail.
#  Arguments
#    url
#       file to download
#    dir
#       downloads the file to this path.

function dwn_file {
    local url=$1 ; shift
    local O=$1 ; shift
    # If it exists return
    [[ -e $O ]] && return 0
    # If the url is fake
    [[ "x$url" == "xfake" ]] && return 0
    # Better circumvent the proxies...
    msg_install --message "Downloading $url to $O"
    $_dwn_exe $O $url
    if [[ $? -ne 0 ]]; then
	rm -f $O
	doerr "$url" 'Could not download file succesfully...'
    fi
}

#  Function choice
# Returns choices from a string and choice give in a string formatted as:
#     <choice-A>$_CHOICE_SEPchoice-A-1$_CHOICE_SEPchoice-A-2$_LIST_SEP<choice-B>$_CHOICE_SEPchoice-B-1
#  Arguments
#    choice
#       the choice to extract from the choice-string
#    choice-string
#       string containing the different choices in this segment

function choice {
    # The selected choice
    local c="$1" ; shift
    # All choices
    local cs="$1" ; shift
    local -a sets=()
    # Convert choices list ot list
    IFS="$_LIST_SEP" read -ra sets <<< "$cs"
    # Loop to get out the choice
    for cc in "${sets[@]}" ; do
	# Only compare up to the next $_CHOICE_SEP
	if [[ "x$c" == "x${cc%%$_CHOICE_SEP*}" ]]; then
	    IFS="$_CHOICE_SEP" read -ra sets <<< "${cc#*$_CHOICE_SEP}"
	    local i=0
	    for cc in "${sets[@]}" ; do
		if [[ $i -eq 0 ]]; then
		    printf '%s' "$cc"
		    i=1
		else
		    printf '%s' " $cc"
		fi
	    done
	    return 0
	fi
    done
    return 1
}


#  Function list
# Returns several options from either a list of <package>s or
# a single package.
# Enables the easy creation of lots of options extracted from
# separate <package>s.
# All "Options" that "appends" means that they are additive
# in meaning.
#  Arguments
#    <packages>
#       If a package is prefixed with a `+` the package
#       will be expanded to the requirements of the package, excluding itself.
#       If `++` is prefixed, package will be expanded to
#       all requirements, including itself.
#  Options
#    -LD-rp
#       returns both library path and fixed running path flags for compiler
#       Same as
#         -Wlrpath -LDFLAGS
#    -LD-rp-lib[[<name>]]
#       returns both library path and fixed running path flags for compiler
#       and the libraries where * will be passed to pack_get -lib[<name>]
#       Same as
#         -Wlrpath -LDFLAGS -lib[<name>]
#    -prefix|-p <prefix>
#       returns the list with <prefix> as a prefix to each entry
#    -suffix|-s <suffix>
#       returns the list with <suffix> as a suffix to each entry
#    -loop-cmd|-c <cmd>
#       Calls $(<cmd> <package>) before appending suffix, prefix,
#       this allows for extracting a lot of different things using `pack_get`
#       commands.
#    -no-space|-X
#       intrinsically `list` returns spaces between objects.
#       This prohibits the spaces and compresses the list.
#    -uniq
#       intrinsically it does not remove dublicates.
#       With this it only returns the unique values.
#    -Wlrpath (appends)
#       Returns the constant running path for the compiler.
#       Same as:
#         -prefix -Wl,-rpath= -loop-cmd "pack_get --library-path"
#    -LDFLAGS (appends)
#       Returns the library path for for the compiler
#       Same as:
#         -prefix -L -loop-cmd "pack_get --library-path"
#    -INCDIRS (appends)
#       Returns the include path for for the compiler
#       Same as:
#         -prefix -I -suffix /include -loop-cmd "pack_get --prefix"
#    -mod-names (appends)
#       Returns the module names of the <package> list
#       Same as:
#         -loop-cmd "pack_get --module-name"

function list {
    local suf pre lcmd cmd retval v opts opt args
    # First we collect all options
    local space=' '
    while : ; do
	trim_em opt $1
	case $opt in
	    -*) ;;
	    *)
		break ;;
	esac
	shift
	case $opt in
	    -LD-rp) opts="$opts -LDFLAGS -Wlrpath" ;;
	    -LD-rp-lib*)
		local lib=$(var_spec -s $opt)
		if [[ -z "$lib" ]]; then
		    opts="$opts -LDFLAGS -Wlrpath -lib"
		else
		    opts="$opts -LDFLAGS -Wlrpath -lib[$lib]"
		fi
		;;
	    -prefix|-p)    pre="$1" ; shift ;;
	    -suffix|-s)    suf="$1" ; shift ;;
	    -loop-cmd|-c)  lcmd="$1" ; shift ;;
	    -no-space|-X)  space='' ;;
	    *)
		opts="$opts $opt" ;;
	esac
    done
    while [[ $# -gt 0 ]]; do
	case $1 in
	    ++*)
		# We gather all requirements to 
		# make it easy
		args="$args $(pack_get -mod-req ${1:2}) ${1:2}"
		;;
	    +*)
		args="$args $(pack_get -mod-req ${1:1})"
		;;
	    *)
		args="$args $1"
		;;
	esac
	shift
    done
    # Remove all duplicates
    args="$(rem_dup $args)"
    for opt in $opts ; do
	case $opt in
	    -Wlrpath)
		pre='-Wl,-rpath='
		suf='' 
		lcmd='pack_get -library-path-all ' ;;
	    -LDFLAGS)   
		pre='-L'  
		suf='' 
		lcmd='pack_get -library-path-all ' ;;
	    -INCDIRS) 
		pre='-I'
		suf='/include'
		lcmd='pack_get -prefix ' ;;
	    -lib*)
		pre=''
		suf=''
		lcmd="pack_get $opt " ;;
	    -mod-names) 
		pre=''
		suf=''
		lcmd='pack_get -module-name ' ;;
	    *)
		doerr "$opt" "No option for list found for $opt" ;;
	esac
	if [[ -n "$lcmd" ]]; then
	    for cmd in $args ; do
		for v in $($lcmd $cmd) ; do
		    retval="$retval$space$pre$v$suf"
		done
	    done
	else
	    for cmd in $args ; do
		retval="$retval$space$pre$cmd$suf"
	    done
	fi
    done
    if [[ -z "$retval" ]]; then
	if [[ -n "$lcmd" ]]; then
	    for cmd in $args ; do
		for v in $($lcmd $cmd) ; do
		    retval="$retval$space$pre$v$suf"
		done
	    done
	else
	    for cmd in $args ; do
		retval="$retval$space$pre$cmd$suf"
	    done
	fi
    fi
    if [[ "x$space" == "x " ]]; then
	printf '%s' "${retval:1}"
    else
	printf '%s' "$retval"
    fi
}

#  Function noop
# Helps in doing nothing.
# Sometimes in if-else-endif statementes a noop operation
# is needed.
# It gobbles all arguments.
function noop {
    shift $#
}


#  Function tmp_file
# This creates a temporary file which may be
# used to create content and later moved.
function tmp_file {
    local file=$(mktemp /tmp/bbuild.XXXXXX)
    trap 'rm -f -- "$file"' INT TERM HUP EXIT
    printf '%s' $file
}
