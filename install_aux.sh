
# File for auxillary commands used in the command line tools

# Print simple string (shortcut for printf "%s" "$1")
function _ps {
    printf "%s" "$@"
}

# Trimmer for options or any other type of variable which has
# an em-dash in front
function trim_em {
    local opt=$1 ; shift
    case $opt in
	--*) opt=${opt:1} ;;
    esac
    _ps "$opt"
}

# trim spaces
function trim_spaces {
    local str=$1 ; shift
    str=${str%% }
    str=${str## }
    local i=0
    while [ $i -ne ${#str} ]; do
	i=${#str}
	# we also remove all double spaces
	str=${str//  / }
    done
    _ps "$str"
}

# A variable is passed to var_spec
# which then returns the var or the spec
#
# Example:
#  $(var_spec --var foo[bar]) == foo
#  $(var_spec --spec foo[bar]) == bar
#  $(var_spec foo[bar]) == foo
#  $(var_spec foo) == foo
#  $(var_spec -s foo) == ''
#  $(var_spec -s foo bar[rab]) == ' rab'
function var_spec {
    local v=1
    while [ $# -gt 0 ]; do
	local opt=$(trim_em "$1")
	case $opt in
	    -var|-v) v=1 ; shift ;;
	    -spec|-s) v=2 ; shift ;;
	esac
        # We add field separators
	if [ $v -eq 1 ]; then
        opt=${1%%\[*}
	    #opt="$(_ps $1 | awk -F'[\\[\\]]' '{ print $1}')"
	    _ps "${opt// /}"
	elif [ $v -eq 2 ]; then
        if [ "${1:${#1}-1}" == "]" ]; then
            opt=${1##*\[}
            opt=${opt//\]/}
        else
            opt=""
        fi
	    #opt="$(_ps $1 | awk -F'[\\[\\]]' '{ print $2}')"
	    _ps "${opt// /}"
	fi
	shift
	# Add delimiter
	[ $# -gt 0 ] && _ps ""
    done
}

# routine for obtaining the versioning number of some string
# It currently must be formatted like: <major>.<minor>.<rev>
function str_version {
    local Mv='' ; local mv='' ; local rv='' ; local fourth=''
    local opt=all
    if [ $# -eq 2 ]; then
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
	all|-all)
	    _ps "$Mv $mv $rv" ;;
	major|-major|-1)
	    [ -z "$Mv" ] && \
		doerr "$str" "Unknown type of version string"	
	    _ps "$Mv" ;;
	minor|-minor|-2)
	    [ -z "$mv" ] && \
		doerr "$str" "Unknown type of version string"	
	    _ps "$mv" ;;
	rev|-rev|-3)
	    [ -z "$rv" ] && \
		doerr "$str" "Unknown type of version string"	
	    _ps "$rv" ;;
	-4)
	    [ -z "$fourth" ] && \
		doerr "$str" "Unknown type of version string"	
	    _ps "$fourth" ;;
	*)
	    doerr "$opt" "Unknown print-out of version"
    esac	    
}

# Compare version of two versions
# If #1 >  #2 returns 1
# If #1 == #2 returns 0
# If #1 <  #2 returns -1
function vrs_cmp {
    local lhs=$1 ; shift
    local rhs=$1 ; shift
    for o in -1 -2 -3 -4 ; do
	local lv=$(str_version $o $lhs)
	local rv=$(str_version $o $rhs)
	[ -z "$lv" ] && break
	[ -z "$rv" ] && break
	if $(isnumber $lv) && $(isnumber $rv) ; then
	    [ $lv -gt $rv ] && _ps "1" && return 0
	    [ $lv -lt $rv ] && _ps "-1" && return 0
	else
	    # Currently we do not do character versioning
	    # properly
	    [ "$lv" != "$rv" ] && _ps "-1000" && return 0
	fi
    done
    _ps "0"
    return 0

    local lMv=$(str_version -1 $1)
    local lmv=$(str_version -2 $1)
    local lrv=$(str_version -3 $1)
    [ -z "$lrv" ] && lrv=1
    local rMv=$(str_version -1 $2)
    local rmv=$(str_version -2 $2)
    local rrv=$(str_version -3 $2)
    [ -z "$rrv" ] && rrv=1
    [ $lMv -gt $rMv ] && _ps "1" && return 0
    [ $lMv -lt $rMv ] && _ps "-1" && return 0
    [ $lmv -gt $rmv ] && _ps "1" && return 0
    [ $lmv -lt $rmv ] && _ps "-1" && return 0
    [ $lrv -gt $rrv ] && _ps "1" && return 0
    [ $lrv -lt $rrv ] && _ps "-1" && return 0
    _ps "0"
}    


# Returns the lowercase of the argument (only translating A-Z)
#
# Example:
#  $(lc fOObaR) == foobar
function lc { _ps "$@" | tr '[A-Z]' '[a-z]' ; }

# Returns the file time in a simple format
function get_file_time {
    local format="$1"
    local fdate=$(stat -c "%y" $2)
    _ps "`date +"$format" --date="$fdate"`"
}

# Routine for used in if statements (by checking the return value)
# This will break if printf's return val is not always defined.
# 
# Example:
#  if $(isnumber 2) ; then
#     echo SUCCESS
#  else
#     echo FAILURE
#  fi
function isnumber { 
    printf '%d' "$1" &>/dev/null
}

# Routine for removing any dublicates in a list
# The algorithm is this:
#  1. translate ' ' to '\n'
#  2. remove all empty fields (removes double spaces)
#  3. awk one-liner for not printing any dublicates
#  4. translate '\n' to ' '
function rem_dup {
    # Apparently we cannot use _ps here!!!!
    echo -n "$@" | tr ' ' '\n' | sed -e '/^[[:space:]]*$/d' | awk '!_[$0]++' | tr '\n' ' '
}


# Based on the extension which command should be called
# to extract the archive
function arc_cmd {
    local ext="$(lc $1)"
    if [ "x$ext" == "xbz2" ]; then
	_ps "tar jxf"
    elif [ "x$ext" == "xxz" ]; then
	_ps "tar Jxf"
    elif [ "x$ext" == "xgz" ]; then
	_ps "tar zxf"
    elif [ "x$ext" == "xtgz" ]; then
	_ps "tar zxf"
    elif [ "x$ext" == "xtar" ]; then
	_ps "tar xf"
    elif [ "x$ext" == "xzip" ]; then
	_ps "unzip"
    elif [ "x$ext" == "xpy" ]; then
	_ps "ln -fs"
    elif [ "x$ext" == "xlocal" ]; then
	_ps "echo"
    elif [ "x$ext" == "xfake" ]; then
	_ps "echo"
    else
	doerr "Unrecognized extension $ext in [bz2,xz,tgz,gz,tar,zip,py,local,fake]"
    fi
}

# Extract file 
# $1 subdirectory of archive
# $2 index or name of archive
function extract_archive {
    local alias="$2"
    local d=$(pack_get --directory $alias)
    local cmd=$(arc_cmd $(pack_get --ext $alias) )
    local archive=$(pack_get --archive $alias)
    # If a previous extraction already exists (delete it!)
    if [ "x$d" != "x." ] && [ "x$d" != "x./" ]; then
	[ -d "$1/$d" ] && rm -rf "$1/$d"
    fi
    local ext=$(pack_get --ext $alias)
    [ "x$ext" == "xlocal" ] && return 0
    docmd "$alias" $cmd $1/$archive
}

# Using wget we will collect the giving file
# $1 http path 
# $2 outdirectory
function dwn_file {
    local ext=$(pack_get --ext $1)
    [ "x$ext" == "xlocal" ] && return 0
    local subdir=./
    if [ $# -gt 1 ]; then
	subdir="$2"
    fi
    local archive=$(pack_get --archive $1)
    [ -e $subdir/$archive ] && return 0
    local url=$(pack_get --url $1)
    [ "x$url" == "xfake" ] && return 0
    wget --no-check-certificate $(pack_get --url $1) -O $subdir/$archive
    if [ $? -ne 0 ]; then
	rm -f $subdir/$archive
	doerr "$archive" "Could not download file succesfully..."
    fi
}

# Function to return a list of space seperated quantities with prefix and suffix
function list {
    do_debug --enter list
    local suf="" ; local pre="" ; local lcmd=""
    local cmd ; local retval=""
    # First we collect all options
    local opts="" ; local space=" "
    while : ; do
	local opt=$(trim_em $1) # Save the option passed
	case $opt in
	    -*) ;;
	    *)  break ;;
	esac
	shift
	case $opt in
	    -prefix|-p)    pre="$1" ; shift ;;
	    -suffix|-s)    suf="$1" ; shift ;;
	    -loop-cmd|-c)  lcmd="$1" ; shift ;;
	    -no-space|-X)  space="" ;;
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
	    -pack-module-reqs)      
		pre="--module-requirement " 
		suf=""
		args="$(pack_get --module-requirement $args) $args" ;;
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
		lcmd="pack_get --install-prefix " ;;
	    *)
		doerr "$opt" "No option for list found for $opt" ;;
	esac
	for cmd in $args ; do
	    if [ ! -z "$lcmd" ]; then
		retval="$retval$space$pre$($lcmd $cmd)$suf"
	    else
		retval="$retval$space$pre$cmd$suf"
	    fi
	done
    done
    if [ -z "$retval" ]; then
	for cmd in $args ; do
	    if [ ! -z "$lcmd" ]; then
		retval="$retval$space$pre$($lcmd $cmd)$suf"
	    else
		retval="$retval$space$pre$cmd$suf"
	    fi
	done
    fi
    _ps "$retval"
    do_debug --return list
}


# Debugging function for printing out every available
# information about a package
function pack_print {
    # It will only take one argument...
    local pack=$_N_archives
    [ $# -gt 0 ] && pack=$1
    echo " >> >> >> >> Package information"
    echo " P/A: $(pack_get -p $pack) / $(pack_get -a $pack)"
    echo " V  : $(pack_get -v $pack)"
    echo " DIR: $(pack_get -d $pack)"
    echo " URL: $(pack_get -http $pack)"
    echo " OUT: $(pack_get -A $pack)"
    echo " CMD: $(pack_get -commands $pack)"
    echo " MP : $(pack_get -module-prefix $pack)"
    echo " IP : $(pack_get -install-prefix $pack)"
    echo " MN : $(pack_get -module-name $pack)"
    echo " IQ : $(pack_get -install-query $pack)"
    echo " REQ: $(pack_get -module-requirement $pack)"
    echo "                                 << << << <<"
}

if [ $DEBUG -gt 0 ]; then
    echo Debugging var_spec
    echo $(var_spec foo[bar])
    echo $(var_spec -v foo[bar])
    echo $(var_spec -s foo[bar])
    [ "x$(var_spec -s foo)" == "x" ] && echo SUCCESS
fi


