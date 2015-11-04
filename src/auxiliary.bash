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
    local n="" ; local action=0
    while [[ $# -gt 1 ]]; do
	local opt=$(trim_em $1)
	case $opt in
	    -start|-S)
		action=1
		n="Installing"
		;;
	    -finish|-F)
		action=2
		n="Finished"
		;;
	    -already-installed)
		action=3
		n="Already installed"
		;;
	    -message)
		shift
		action=4
		n="$1"
		;;
	    *) break ;;
	esac
	shift
    done
    case $# in
	0)
	    local pack=$_N_archives
	    ;;
	*)
	    local pack=$1
	    ;;
    esac

    if [[ $action -ne 4 ]]; then
	local cmd=$(arc_cmd $(pack_get --ext $pack) )
    fi
    echo " ================================== "
    echo "   $n"
    if [[ $action -eq 1 ]]; then
	echo " File    : $(pack_get --archive $pack)"
	echo " Ext     : $(pack_get --ext $pack)"
	echo " Ext CMD : $cmd"
    fi
    if [[ $action -ne 4 ]]; then
	echo " Package : $(pack_get --package $pack)"
	if [[ "$(pack_get --package $pack)" != "$(pack_get --alias $pack)" ]]; then
	    echo " Alias   : $(pack_get --alias $pack)"
	fi	
	echo " Version : $(pack_get --version $pack)"
    fi
    if [[ $action -eq 1 ]]; then
	module list 2>&1
    fi
    echo " ================================== "
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
    local st
    echo ""
    echo " # ================================================================"
    echo " # $message"
    echo " # PWD: $(pwd)"
    echo " # CMD: ${cmd[@]}"
    echo " # ================================================================"
    eval ${cmd[@]}
    st=$?
    if [[ $st -ne 0 ]]; then
	echo "STATUS = $st"
        exit $st
    fi
}


#  Function _ps
# Prints all arguments as a string _without_ new-line characters.
# Uses `printf` for this.
# Using `_ps` in favor of `echo -n` is 2-fold.
#  1. `printf` takes no options, hence you can print `_ps -n`
#  2. `printf` is faster than `echo -n`
#  Arguments
#    message
#       All message arguments are printed, _as is_.

function _ps {
    printf "%s" "$@"
}


#  Function trim_em
# Takes one argument, if it has two em-dashes in front,
# it returns the equivalent with only one em-dash.
# Otherwise it returns the argument as received.
#  Arguments
#    str
#       Removes one em-dash if the `str` starts with two or
#       more em-dashes.

function trim_em {
    _ps "${1/#--/-}"
    shift
}

#  Function trim_spaces
# Removes all superfluous space. Prefix, suffix and double spaces.
# I.e. a string of "  the cat  was small  . Said I"
# would return a string of "the cat was small . Said I"
#  Arguments
#    str
#       Truncates all spaces to a minimum of one space.

function trim_spaces {
    local str
    local s
    local i
    while [[ $# -gt 0 ]]; do
	s="${1# }" # removes prefix space
	shift
	s=${s% } # removes suffix space
	s=${s//  / } # removes double space
	str="$str $s"
    done
    _ps "${str:1}"
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
    local v=1
    local opt
    opt=$(trim_em $1)
    case $opt in
	-var|-v)
	    v=1
	    shift
	    ;;
	-spec|-s)
	    v=2
	    shift
	    ;;
    esac
    case $v in
	1)
	    while [[ $# -gt 0 ]]; do
		opt=${1%%\[*}
		_ps "${opt// /}"
		# Get next package
		shift
		# Add delimiter
		if [[ $# -gt 0 ]]; then
		    _ps " "
		fi
	    done
	    ;;
	2)
	    while [[ $# -gt 0 ]]; do
		if [[ "${1:${#1}-1}" == "]" ]]; then
		    opt=${1##*\[}
		    opt=${opt//\]/}
		else
		    opt=""
		fi
		#opt="$(_ps $1 | awk -F'[\\[\\]]' '{ print $2}')"
		_ps "${opt// /}"
		# Get next package
		shift
		# Add delimiter
		if [[ $# -gt 0 ]]; then
		    _ps " "
		fi
	    done
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
    local Mv='' ; local mv='' ; local rv='' ; local fourth=''
    local opt=-1
    if [[ $# -eq 2 ]]; then
	opt=$(trim_em $1)
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
	    _ps "$Mv"
	    ;;
	minor|-minor|-2)
	    _ps "$mv"
	    ;;
	rev|-rev|-3)
	    _ps "$rv"
	    ;;
	bug|-bug|-4)
	    _ps "$fourth"
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
    local lhs=$1 ; shift
    local rhs=$1 ; shift
    for o in -1 -2 -3 -4 ; do
	local lv=$(str_version $o $lhs)
	local rv=$(str_version $o $rhs)
	[[ -z "$lv" ]] && break
	[[ -z "$rv" ]] && break
	if $(isnumber $lv) && $(isnumber $rv) ; then
	    [[ $lv -gt $rv ]] && _ps "1" && return 0
	    [[ $lv -lt $rv ]] && _ps "-1" && return 0
	else
	    # Currently we do not do character versioning
	    # properly
	    [[ "$lv" != "$rv" ]] && _ps "-1000" && return 0
	fi
    done
    _ps "0"
}


#  Function lc
# Returns the argument as lowercase.
#  Arguments
#    <args>
#       Returns <args> as lowercase characters.

function lc {
    _ps "${1,,}"
    shift
    while [[ $# -gt 0 ]]; do
	_ps " ${1,,}"
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
    shift
    local fdate=$(stat -L -c "%y" $1)
    shift
    _ps "`date +"$format" --date="$fdate"`"
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
    # Apparently we cannot use _ps here!!!!
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
    # Apparently we cannot use _ps here!!!!
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
#   bz2, xz, gz, tgz, tar, zip
# The following arguments are specially treated:
#   local, fake : returns `echo` as no extraction is necessary
#   py : links the file so that it is local.
#  Arguments
#    ext
#       Checks the extension and returns an un compression command
#       that can un-compress that file.

function arc_cmd {
    local ext="$(lc $1)"
    case $ext in
	bz2)
	    _ps "tar jxf"
	    ;;
	xz)
	    _ps "tar Jxf"
	    ;;
	gz|tgz)
	    _ps "tar zxf"
	    ;;
	tar)
	    _ps "tar xf"
	    ;;
	zip)
	    _ps "unzip"
	    ;;
	py)
	    _ps "ln -fs"
	    ;;
	local|bin|fake)
	    _ps "echo"
	    ;;
	*)
	    doerr "Unrecognized extension $ext in [bz2,xz,tgz,gz,tar,zip,py,local,fake]"
	    ;;
    esac
}


#  Function extract_archive
# Takes a directory and a package name as argument.
# Extracts the archive belonging to package and extracts it
# to the directory.
#  Arguments
#    dir
#       The directory that the archive is extracted to
#    <package>
#       the package name. Looks up the package, extracts the
#       archive from the saved package, and extracts it.

function extract_archive {
    local id="$2"
    local d=$(pack_get --directory $id)
    local ext=$(pack_get --ext $id)
    local cmd=$(arc_cmd $ext)
    local archive=$(pack_get --archive $id)
    # If a previous extraction already exists (delete it!)
    case $d in
	.|./)
	    noop
	    ;;
	*)
	    if [[ -d "$1/$d" ]]; then
		rm -rf "$1/$d"
	    fi
    esac
    case $ext in
	local|bin|fake)
	    return 0
	    ;;
    esac
    docmd "Archive $(pack_get --alias $id) ($(pack_get --version $id))" $cmd $1/$archive
}


#  Function dwn_file
# Downloads files using `wget`, without proxies or certificates.
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
    wget --no-proxy \
	--no-check-certificate \
	$url -O $O
    if [[ $? -ne 0 ]]; then
	rm -f $O
	doerr "$url" "Could not download file succesfully..."
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
		    _ps "$cc"
		    i=1
		else
		    _ps " $cc"
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
#       If the packages are prefixed with a `+` the package
#       will be expanded to the requirements of the package.
#       If a `++` is present, package will be expanded to
#       all requirements and itself.
#  Options
#    -LD-rp
#       returns both library path and fixed running path flags for compiler
#       Same as
#         -Wlrpath -LDFLAGS
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
    local suf="" ; local pre="" ; local lcmd=""
    local cmd ; local retval=""
    # First we collect all options
    local opts="" ; local space=" "
    while : ; do
	local opt="$(trim_em $1)"
	case $opt in
	    -*) ;;
	    *)  break ;;
	esac
	shift
	case $opt in
	    -LD-rp) opts="$opts -LDFLAGS -Wlrpath" ;;
	    -prefix|-p)    pre="$1" ; shift ;;
	    -suffix|-s)    suf="$1" ; shift ;;
	    -loop-cmd|-c)  lcmd="$1" ; shift ;;
	    -no-space|-X)  space="" ;;
	    *)
		opts="$opts $opt" ;;
	esac
    done
    local args=""
    while [[ $# -gt 0 ]]; do
	case $1 in
	    ++*)
		# We gather all requirements to 
		# make it easy
		args="$args $(pack_get --mod-req ${1:2}) ${1:2}"
		;;
	    +*)
		args="$args $(pack_get --mod-req ${1:1})"
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
		pre="-Wl,-rpath=" 
		suf="" 
		lcmd="pack_get --library-path " ;;
	    -LDFLAGS)   
		pre="-L"  
		suf="" 
		lcmd="pack_get --library-path " ;;
	    -INCDIRS) 
		pre="-I"
		suf="/include"
		lcmd="pack_get --prefix " ;;
	    -mod-names) 
		pre=""
		suf=""
		lcmd="pack_get --module-name " ;;
	    *)
		doerr "$opt" "No option for list found for $opt" ;;
	esac
	if [[ -n "$lcmd" ]]; then
	    for cmd in $args ; do
		retval="$retval$space$pre$($lcmd $cmd)$suf"
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
		retval="$retval$space$pre$($lcmd $cmd)$suf"
	    done
	else
	    for cmd in $args ; do
		retval="$retval$space$pre$cmd$suf"
	    done
	fi
    fi
    _ps "$retval"
}

#  Function noop
# Helps in doing nothing.
# Sometimes in if-else-endif statementes an noop operation
# is needed.
# It gobbles all arguments
function noop {
    while [ $# -gt 0 ]; do
	shift
    done
}
