
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
	[ $v -eq 1 ] && _ps $(_ps $1 | awk -F'[\\[\\]]' '{ print $1}')
	[ $v -eq 2 ] && _ps $(_ps $1 | awk -F'[\\[\\]]' '{ print $2}')
	shift
	# Add delimiter
	[ $# -gt 0 ] && _ps " "
    done
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


if [ $DEBUG -gt 0 ]; then
    echo Debugging var_spec
    echo $(var_spec foo[bar])
    echo $(var_spec -v foo[bar])
    echo $(var_spec -s foo[bar])
    [ "x$(var_spec -s foo)" == "x" ] && echo SUCCESS
fi


