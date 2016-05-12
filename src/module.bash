
# Determine whether the module files should contain a
# survey dispatch.
_mod_survey=0
_mod_survey_cmd='system echo `whoami` `date +%Y-%m-%d-%H` $modulename/$version'
_mod_survey_file=''

# Globally set whether modules should dispatch
# to a survey file.
# This may be handy to figure out how many modules are
# being used, etc.
# Flags for setting module commands
#   -s|--survey:
#     Create survey
#   -cmd|--survey-cmd:
#     Command to create survey with.
#     Defaults to:
#       `whoami` `date +%Y-%m-%d-%H` $modulename/$version'
#   -f|--survey-file:
#     The file where the survey is saved in.
#     This will automatically enable creating a survey
function module_set {
    while [[ $# -gt 0 ]]; do
	opt="$(trim_em $1)"
	shift
	case $opt in
	    -s|-survey)
		_mod_survey=1
		;;
	    -cmd|-survey-cmd)
		_mod_survey_cmd="$1"
		shift
		;;
	    -f|-survey-file)
		_mod_survey_file="$1"
		_mod_survey=1
		shift
		;;
	    *)
		doerr "$opt" "Option for module_set $opt was not recognized"
		;;
	esac
    done
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
    local name; local version; local echos
    local path; local help; local whatis; local opt
    local env="" ; local tmp="" ; local mod=""
    local mod_path="" ;local cmt=
    local force=0 ; local no_install=0
    local require=""; local conflict=""; local load=""
    local lua_family="" ; local fpath=
    local fm_comment="#"
    while [[ $# -gt 0 ]]; do
	opt="$(trim_em $1)" ; shift
	case $opt in
	    -n|-name)  name="$1" ; shift ;;
	    -v|-version)  version="$1" ; shift ;;
	    -P|-path)  path="$1" ; shift ;;
	    -p|-module-path)  mod_path="$1" ; shift ;;
	    -M|-module-name)  mod="$1" ; shift ;;
	    -R|-require)  require="$require $1" ; shift ;; # Can be optioned several times
	    -L|-load-module)  load="$load $1" ; shift ;; # Can be optioned several times
	    -RL|-reqs+load-module) 
		load="$load $(pack_get --mod-req $1) $1" ; shift ;; # Can be optioned several times
	    -C|-conflict-module)  conflict="$conflict $1" ; shift ;; # Can be optioned several times
	    -set-ENV)      env="$env s$1" ; shift ;; # Can be optioned several times
	    -prepend-ENV)      env="$env p$1" ; shift ;; # Can be optioned several times
	    -append-ENV)      env="$env a$1" ; shift ;; # Can be optioned several times
	    -lua-family) lua_family="$1" ; shift ;; # If using the Lmod, we create a family name, else nothing is happening...
	    -echo)
		echos="$1" ; shift ;; # Echo out to the users
	    -H|-help)  help="$1" ; shift ;;
	    -W|-what-is)  whatis="$1" ; shift ;;
	    -F|-force)  force=1 ;;
	    *)
		doerr "$opt" "Option for create_module $opt was not recognized"
		;;
	esac
    done
    fpath=$path
    require="$(rem_dup $require)"
    load="$(rem_dup $load)"
    conflict="$(rem_dup $conflict)"

    # Create the file to which we need to install the module script
    if [[ -z "$mod_path" ]]; then
	local mfile=$(build_get --module-path)
    else
	local mfile=$mod_path
    fi
    [[ -n "$mod" ]] && mfile=$mfile/$mod
    case $_module_format in
	TCL) 
	    fm_comment="#"
	    ;;
	LUA)
	    fm_comment="--"
	    mfile="$mfile.lua"
	    ;;
    esac
    [[ -z "$version" ]] && version=empty

    # Check that all that is required and needs to be loaded is installed
    for mod in $require $load ; do
	[[ -z "${mod// /}" ]] && continue
	[[ $(pack_get --installed $mod) -eq $_I_INSTALLED ]] && continue
	return 1
    done
    
    # If the file exists simply return
    if [[ -e "$mfile" ]] && [[ 0 -eq $force ]]; then
        return 0
    fi

    # First create directory if it does not exist:
    mkdir -p $(dirname $mfile)
    
    # Create the module file
    case $_module_format in
	TCL)
	    cat <<EOF > "$mfile"
#%Module1.0
#####################################################################

set modulename  "$name"
set version	$version
EOF
	    if [[ $_mod_survey -ne 0 ]]; then
		cat <<EOF >> "$mfile"

if { [module-info mode load] } {
    system echo $_mod_survey_cmd >> $_mod_survey_file
}
EOF
	    fi
	    ;;
	LUA)
	    cat <<EOF > "$mfile"
$fm_comment LUA file for Lmod

local modulename    = "$name"
local version       = "$version"
EOF
	    ;;
	*)
	    doerr "create_module" "Unknown module type, [TCL,LUA]"
	    ;;
    esac
    cmt="$(get_c)"
    if [[ -n "$cmt" ]]; then
	case $_module_format in
	    TCL)
		cmt=", (\$compiler)"
		cat <<EOF >> "$mfile"
set compiler	$(get_c)
EOF
		;;
	    LUA) cat <<EOF >> "$mfile"
local compiler      = "$(get_c)"
EOF
		;;
	esac
    fi

    case $_module_format in
	TCL) 
	    tmp="${path//$version/\$version}"
	    if [[ -n "$cmt" ]]; then
		tmp="${tmp//$(get_c)/\$compiler}"
	    fi
	    cat <<EOF >> "$mfile"
set basepath	$tmp
EOF
	    fpath="\$basepath"
	    ;;
	LUA) cat <<EOF >> "$mfile"
local basepath      = "${path%$version*}" .. version .. "${path#*$version}"
EOF
	    ;;
    esac

    case $_module_format in
	TCL) cat <<EOF >> "$mfile"

proc ModulesHelp { } {
    puts stderr "\tLoads \$modulename (\$version)"
}

module-whatis "Loads \$modulename (\$version)$cmt."

EOF
	    ;;
	LUA) cat <<EOF >> "$mfile"

help("    Loads " .. modulename .. " (" .. version .. ")")
whatis("Loads " .. modulename .. " (" .. version .. ") using " .. compiler .. " compiler.")

EOF
	    ;;
    esac

    # Add pre loaders if needed
    if [[  -n "${load// /}" ]]; then
	cat <<EOF >> "$mfile"
$fm_comment This module will load the following modules:
EOF
	for tmp in $load ; do
	    if [[ $(pack_get --installed $tmp) -ge $_I_INSTALLED ]]; then
		local tmp_load=$(pack_get --module-name $tmp)
		case $_module_format in 
		    TCL) echo "module load $tmp_load" >> "$mfile" ;;
		    LUA) echo "load(\"$tmp_load\")" >> "$mfile" ;;
		esac
	    elif [[ $force -eq 0 ]]; then
		no_install=1
	    fi
	done
	echo "" >> $mfile
    fi    

    # Add requirement if needed
    if [[ -n "${require// /}" ]]; then
	cat <<EOF >> $mfile
$fm_comment Requirements for the module:
EOF
	for tmp in $require ; do
	    if [[ $(pack_get --installed $tmp ) -ge $_I_INSTALLED ]]; then
		local tmp_load=$(pack_get --module-name $tmp)
		case $_module_format in 
                    TCL) echo "prereq $tmp_load" >> "$mfile" ;;
                    LUA) echo "prereq(\"$tmp_load\")" >> "$mfile" ;;
                esac
            elif [[ $force -eq 0 ]]; then
		no_install=1
            fi
	done
	echo "" >> $mfile
    fi
    # Add conflict if needed
    if [[ -n "${conflict// /}" ]]; then
	cat <<EOF >> $mfile
$fm_comment Modules which is in conflict with this module:
EOF
	for tmp in $conflict ; do
	    if [[ $(pack_get --installed $tmp ) -ge $_I_INSTALLED ]]; then
		local tmp_load=$(pack_get --module-name $tmp)
		case $_module_format in 
		    TCL) echo "conflict $tmp_load" >> "$mfile" ;;
		    LUA) echo "conflict(\"$tmp_load\")" >> "$mfile" ;;
		esac
	    elif [[ $force -eq 0 ]]; then
		no_install=1
	    fi
	done
	echo "" >> $mfile
    fi
    # Add specific envs if needed
    if [[ -n "${env// /}" ]]; then
	cat <<EOF >> $mfile
$fm_comment Specific environment variables:
EOF
	for tmp in $env ; do
	    # Partition into [s|a|p]
	    local opt=${tmp:0:1}
	    local lenv=${tmp%%=*}
	    lenv=${lenv:1}
	    local lval=${tmp#*=}
	    
	    #echo "$opt, $lenv $lval $force"
            # Add paths if they are available
	    # We add explicit quotations as certain env-vars
	    # might not adhere to simple text 
	    case $opt in
		s)
		    opt="$(module_fmt_routine --set-env $lenv $lval)"
		    ;;
		p)
		    opt="$(module_fmt_routine --prepend-path $lenv $lval)"
		    ;;
		a)
		    opt="$(module_fmt_routine --append-path $lenv $lval)"
		    ;;
		*)
		    opt=""
		    ;;
	    esac
	    # These options should probably always
	    # be "on" , they are specified by the options by the user
	    # and not, per-see "optional"
	    [[ -n "$opt" ]] && \
		add_module_if -F 1 -d "$lval" "$mfile" "$opt" 
	done
	echo "" >> $mfile
    fi
    # Add paths if they are available
    add_module_if -F $force -d "$path/bin" $mfile \
	"$(module_fmt_routine --prepend-path PATH $fpath/bin)"
    add_module_if -F $force -d "$path/lib/pkgconfig" $mfile \
	"$(module_fmt_routine --prepend-path PKG_CONFIG_PATH $fpath/lib/pkgconfig)"
    add_module_if -F $force -d "$path/lib64/pkgconfig" $mfile \
	"$(module_fmt_routine --prepend-path PKG_CONFIG_PATH $fpath/lib64/pkgconfig)"
    add_module_if -F $force -d "$path/man" $mfile \
	"$(module_fmt_routine --prepend-path MANPATH $fpath/man)"
    add_module_if -F $force -d "$path/share/man" $mfile \
	"$(module_fmt_routine --prepend-path MANPATH $fpath/share/man)"
    # The LD_LIBRARY_PATH is DANGEROUS!
    #add_module_if -F $force -d "$path/lib" $mfile \
#	"$(module_fmt_routine --prepend-path LD_LIBRARY_PATH $fpath/lib)"
 #   add_module_if -F $force -d "$path/lib64" $mfile \
#	"$(module_fmt_routine --prepend-path LD_LIBRARY_PATH $fpath/lib64)"
    add_module_if -F $force -d "$path/lib/python" $mfile \
	"$(module_fmt_routine --prepend-path PYTHONPATH $fpath/lib/python)"
    for PV in 2.6 2.7 3.4 3.5 3.6 ; do
	add_module_if -F $force -d "$path/lib/python$PV/site-packages" $mfile \
	    "$(module_fmt_routine --prepend-path PYTHONPATH $fpath/lib/python$PV/site-packages)"
	add_module_if -F $force -d "$path/lib64/python$PV/site-packages" $mfile \
	    "$(module_fmt_routine --prepend-path PYTHONPATH $fpath/lib64/python$PV/site-packages)"
    done
    if [[ -n "$lua_family" ]]; then
	case $_module_format in
	    LUA)
		cat <<EOF >> "$mfile"


$fm_comment Add family:
family("$lua_family")
EOF
		;;
	esac
    fi
    
    if [[ -n "$echos" ]]; then
	cat <<EOF >> "$mfile"


$fm_comment echo to the user:
EOF
	case $_module_format in
	    TCL)
		cat <<EOF >> "$mfile"
puts stderr "$echos"
EOF
		;;
	    LUA)
		cat <<EOF >> "$mfile"
LmodMessage("$echos")
EOF
		;;
	esac
    fi
    
    
    if [[ $no_install -eq 1 ]] && [[ $force -eq 0 ]]; then
	rm -f $mfile
    fi
    # If we are to create the default version module we 
    # can add this version to the .version file:
    if [[ $_crt_version -eq 1 ]]; then
	case $_module_format in
	    TCL)
		cat <<EOF > $(dirname $mfile)/.version
#%Module1.0
#####################################################################
set ModulesVersion $(basename $mfile)
EOF
		;;
	    LUA)
		pushd $(dirname $mfile) 1> /dev/null
		ln -fs $(basename $mfile) default
		popd 1> /dev/null 
		;;
	esac
    fi
}

# Returns the module specific routine call
function module_fmt_routine {
    local lval="" ; local lenv=""
    while [[ $# -gt 0 ]]; do
	opt="$(trim_em $1)"
	shift
	case "$opt" in
	    -prepend-path)
		case $_module_format in
		    TCL) _ps "prepend-path $1 $2" ;;
		    LUA) _ps "prepend_path(\"$1\",\"$2\")" ;;
		esac
		shift ; shift ;;
	    -append-path)
		case $_module_format in
		    TCL) _ps "append-path $1 $2" ;;
		    LUA) _ps "append_path(\"$1\",\"$2\")" ;;
		esac
		shift ; shift ;;
	    -set-env)
		case $_module_format in
		    TCL) _ps "setenv $1 $2" ;;
		    LUA) _ps "setenv(\"$1\",\"$2\",true)" ;;
		esac
		shift ; shift ;;
	esac
    done
}

# Append to module file dependent on the existance of a
# directory or file
#   -d <directory>
#   -f <file>
#   $1 module file to append to
#   $2-? append this in one line to the file
function add_module_if {
    local d="";local f="" ;local F=0;
    local X=0
    local opt
    while [[ $# -gt 0 ]]; do
	opt=$(trim_em $1)
	case $opt in
	    -d|-dir)
		# The directory which should be checked for
		# existance
		shift
		d="$1"
		shift
		;;
	    -f|-file)
		# The file which should be checked for
		# existance (precedence over directory)
		shift
		f="$1"
		shift
		;;
	    -F|-force)
		# Force the env-creation
		shift
		F="$1"
		shift
		;;
	    *)
		break
		;;
	esac
    done
    # Get module file
    local mf="$1" 
    shift
    
    local check=""
    if [[ $F -eq 1 ]]; then
	# Force check to succeed
	check=$HOME
    elif [[ -n "$f" ]]; then
	check=$f
    elif [[ -n "$d" ]]; then
	check=$d
    fi
    if [[ -e $check ]]; then
	cat <<EOF >> $mf
$@
EOF
	return 0
    fi
    return 1
}
