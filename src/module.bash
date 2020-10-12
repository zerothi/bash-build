
# Whether we should create TCL or LUA module files
_mod_format='ENVMOD'
_mod_format_ENVMOD='ENVMOD'
_mod_format_LMOD='LMOD'


# Determine whether the module files should contain a
# survey dispatch.
_mod_survey=0
_mod_survey_cmd='`whoami` `date +%Y-%m-%d-%H` $modulename/$version'
_mod_survey_file=''

# Disable LMOD spider cache
export LMOD_IGNORE_CACHE=1
# Disable LMOD pager
export LMOD_PAGER=none


# Query module format
function module_format {
    printf '%s' $_mod_format
}

# Assert that a given path is in the MODULEPATH.
# This is mainly for asserting that every build has their
# module path accessible.
function check_modulepath {
    local path=$1
    shift
    local found=0
    # Loop on paths in MODULEPATH
    for mp in `echo $MODULEPATH | tr ':' ' '`
    do
	if [[ "$mp" == "$path" ]]; then
	    found=1
	fi
    done
    printf '%s' $found
}

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
    local opt
    while [[ $# -gt 0 ]]; do
	trim_em opt $1
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
		if [ ! -e $_mod_survey_file ]; then
		    touch $_mod_survey_file
		    chmod 622 $_mod_survey_file
		fi
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
    local name version echos
    local path help whatis opt
    local env tmp mod cmt
    local use_path mod_path
    local require conflict load lua_family
    local fpath
    local ld_path=0 # signal use of ld_library_path
    local force=0 ; local no_install=0
    local fm_comment='#'
    while [[ $# -gt 0 ]]; do
	trim_em opt $1
	shift
	case $opt in
	    -n|-name)  name="$1" ; shift ;;
	    -v|-version)  version="$1" ; shift ;;
	    -P|-path)  path="$1" ; shift ;;
	    -use-path)  use_path="$use_path $1" ; shift ;;
	    -ld-library-path)  ld_path=1 ;;
	    -p|-module-path)  mod_path="$1" ; shift ;;
	    -M|-module-name)  mod="$1" ; shift ;;
	    -R|-require)  require="$require $1" ; shift ;; # Can be optioned several times
	    -L|-load-module)  load="$load $1" ; shift ;; # Can be optioned several times
	    -RL|-reqs+load-module) 
		load="$load $(pack_get -mod-req-module $1) $1" ; shift ;; # Can be optioned several times
	    -C|-conflict-module)  conflict="$conflict $1" ; shift ;; # Can be optioned several times
	    -undefined-ENV)      env="$env u$1" ; shift ;; # Can be optioned several times
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
	local mfile=$(build_get -module-path)
    else
	local mfile=$mod_path
    fi
    [[ -n "$mod" ]] && mfile=$mfile/$mod
    case $_mod_format in
	$_mod_format_ENVMOD) 
	    fm_comment='#'
	    ;;
	$_mod_format_LMOD)
	    fm_comment='--'
	    mfile="$mfile.lua"
	    ;;
    esac
    [[ -z "$version" ]] && version=empty

    # Filter out modules that are not actual modules
    tmp=
    for mod in $require ; do
	[[ -z "${mod// /}" ]] && continue
	case $(pack_get -installed $mod) in
	    $_I_LIB|$_I_REQ)
		continue
		;;
	esac
	tmp="$tmp $mod"
    done
    require="$tmp"

    # Filter out modules that are not actual modules
    tmp=
    for mod in $load ; do
	[[ -z "${mod// /}" ]] && continue
	case $(pack_get -installed $mod) in
	    $_I_LIB|$_I_REQ)
		continue
		;;
	esac
	tmp="$tmp $mod"
    done
    load="$tmp"

    # Check that all that is required and needs to be loaded is installed
    for mod in $require $load ; do
	[[ -z "${mod// /}" ]] && continue
	case $(pack_get -installed $mod) in
	    $_I_INSTALLED|$_I_MOD)
		continue
		;;
	esac
	msg_install -message "Could not create module [$name/$version] because $(pack_get -p $mod)[$(pack_get -v $mod)] is not installed..."
	return 1
    done
    
    # If the file exists simply return
    if [[ -e "$mfile" ]] && [[ 0 -eq $force ]]; then
        return 0
    fi

    # First create directory if it does not exist:
    mkdir -p $(dirname $mfile)

    # Create the module file
    case $_mod_format in
	$_mod_format_ENVMOD)
	    cat <<EOF > "$mfile"
#%Module1.0
#####################################################################

set modulename "$name"
set version $version
EOF
	    if [[ $_mod_survey -ne 0 ]]; then
		cat <<EOF >> "$mfile"

# Check that we may create survey
set cerr [catch {set in_survey \$::env(DCC__SURVEY_IN)}]
if { \$cerr != 0 } {
    set in_survey 0
}
if { \$in_survey == 0 } {
    if { [module-info mode load] } {
        # This is the controlling sequence
        set in_survey 2
        setenv DCC__SURVEY_IN 1
        puts stdout "echo $_mod_survey_cmd >> $_mod_survey_file"
    } else {
        set in_survey 1
    }
}

EOF
	    fi
	    ;;
	$_mod_format_LMOD)
	    cat <<EOF > "$mfile"
$fm_comment LUA file for Lmod

local modulename = "$name"
local version = "$version"
EOF
	    ;;
	*)
	    doerr "create_module" "Unknown module type, [TCL,LUA]"
	    ;;
    esac
    cmt="$(get_c)"
    if [[ -n "$cmt" ]]; then
	case $_mod_format in
	    $_mod_format_ENVMOD)
		cmt=", (\$compiler)"
		cat <<EOF >> "$mfile"
set compiler $(get_c)
EOF
		;;
	    $_mod_format_LMOD) cat <<EOF >> "$mfile"
local compiler = "$(get_c)"
EOF
		;;
	esac
    fi

    case $_mod_format in
	$_mod_format_ENVMOD) 
	    tmp="${path//\/$version\//\/\$version\/}"
	    if [[ -n "$cmt" ]]; then
		tmp="${tmp//\/$(get_c)\//\/\$compiler\/}"
	    fi
	    cat <<EOF >> "$mfile"
set basepath $tmp
EOF
	    fpath="\$basepath"
	    ;;
	$_mod_format_LMOD) cat <<EOF >> "$mfile"
local basepath = "${path%$version*}" .. version .. "${path#*$version}"
EOF
	    ;;
    esac

    case $_mod_format in
	$_mod_format_ENVMOD) cat <<EOF >> "$mfile"

proc ModulesHelp { } {
    puts stderr "\tLoads \$modulename (\$version)"
}

module-whatis "Loads \$modulename (\$version)$cmt."

EOF
	    ;;
	$_mod_format_LMOD) cat <<EOF >> "$mfile"

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
	    local inst=$(pack_get -installed $tmp)
	    case $inst in
		$_I_INSTALLED|$_I_MOD)
		    local tmp_load=$(pack_get -module-name $tmp)
		    case $_mod_format in 
			$_mod_format_ENVMOD) echo "module load $tmp_load" >> "$mfile" ;;
			$_mod_format_LMOD) echo "load(\"$tmp_load\")" >> "$mfile" ;;
		    esac
		    ;;
		*)
		    [[ $force -eq 0 ]] && no_install=1
		    ;;
	    esac
	done
	echo "" >> $mfile
    fi    

    # Add requirement if needed
    if [[ -n "${require// /}" ]]; then
	cat <<EOF >> $mfile
$fm_comment Requirements for the module:
EOF
	for tmp in $require ; do
	    local inst=$(pack_get -installed $tmp)
	    case $inst in
		$_I_INSTALLED|$_I_MOD)
		    local tmp_load=$(pack_get -module-name $tmp)
		    case $_mod_format in 
			$_mod_format_ENVMOD) echo "prereq $tmp_load" >> "$mfile" ;;
			$_mod_format_LMOD) echo "prereq(\"$tmp_load\")" >> "$mfile" ;;
                    esac
		    ;;
		*)
		    [[ $force -eq 0 ]] && no_install=1
		    ;;
	    esac
	done
	echo "" >> $mfile
    fi

    # Add conflict if needed
    if [[ -n "${conflict// /}" ]]; then
	cat <<EOF >> $mfile
$fm_comment Modules which is in conflict with this module:
EOF
	for tmp in $conflict ; do
	    local inst=$(pack_get -installed $tmp)
	    case $inst in
		$_I_INSTALLED|$_I_MOD)
		    local tmp_load=$(pack_get -module-name $tmp)
		    case $_mod_format in 
			$_mod_format_ENVMOD) echo "conflict $tmp_load" >> "$mfile" ;;
			$_mod_format_LMOD) echo "conflict(\"$tmp_load\")" >> "$mfile" ;;
		    esac
		    ;;
		*)
		    # Only force a no-install if the conflict is not it-self
		    if [[ $tmp != $name ]]; then
			[[ $force -eq 0 ]] && no_install=1
		    fi
		    ;;
	    esac
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
		u)
		    opt="$(module_fmt_routine -undefined-env $lenv $lval)"
		    ;;
		s)
		    opt="$(module_fmt_routine -set-env $lenv $lval)"
		    ;;
		p)
		    opt="$(module_fmt_routine -prepend-path $lenv $lval)"
		    ;;
		a)
		    opt="$(module_fmt_routine -append-path $lenv $lval)"
		    ;;
		*)
		    opt=''
		    ;;
	    esac
	    # These options should probably always
	    # be "on" , they are specified by the options by the user
	    # and not, per-see "optional"
	    [[ -n "$opt" ]] && \
		add_module_if -F 1 "$mfile" "$opt"
	done
	echo "" >> $mfile
    fi
    # Always create an environment variable named:
    #   ${name}_PREFIX to have the installation
    #   directory accessible at all times.
    # This is nice for header only projects etc.
    add_module_if -F $force -d "$path" $mfile \
        "$(module_fmt_routine -set-env ${name}_PREFIX $fpath)"
    # Add paths if they are available
    add_module_if -F $force -d "$path/bin" $mfile \
	"$(module_fmt_routine -prepend-path PATH $fpath/bin)"
    add_module_if -F $force -d "$path/lib/pkgconfig" $mfile \
	"$(module_fmt_routine -prepend-path PKG_CONFIG_PATH $fpath/lib/pkgconfig)"
    add_module_if -F $force -d "$path/lib64/pkgconfig" $mfile \
	"$(module_fmt_routine -prepend-path PKG_CONFIG_PATH $fpath/lib64/pkgconfig)"
    add_module_if -F $force -d "$path/share/pkgconfig" $mfile \
	"$(module_fmt_routine -prepend-path PKG_CONFIG_PATH $fpath/share/pkgconfig)"
    #add_module_if -F $force -d "$path/man" $mfile \
	#"$(module_fmt_routine -prepend-path MANPATH $fpath/man)"
    #add_module_if -F $force -d "$path/share/man" $mfile \
	#"$(module_fmt_routine -prepend-path MANPATH $fpath/share/man)"
    add_module_if -F $force -d "$path/share/aclocal" $mfile \
	"$(module_fmt_routine -prepend-path M4PATH $fpath/share/aclocal)"
    add_module_if -F $force -d "$path/share/aclocal" $mfile \
	"$(module_fmt_routine -prepend-path ACLOCAL_PATH $fpath/share/aclocal)"
    add_module_if -F $force -d "$path/share/cmake" $mfile \
	"$(module_fmt_routine -prepend-path CMAKE_PREFIX_PATH $fpath/share/cmake)"
    add_module_if -F $force -d "$path/lib/cmake" $mfile \
	"$(module_fmt_routine -prepend-path CMAKE_PREFIX_PATH $fpath/lib/cmake)"
    add_module_if -F $force -d "$path/lib64/cmake" $mfile \
	"$(module_fmt_routine -prepend-path CMAKE_PREFIX_PATH $fpath/lib64/cmake)"
    tmp=$(ls -d $path/share/$name* 2>/dev/null)
    if [[ -n "$tmp" ]]; then
	add_module_if -F $force -d "$tmp" $mfile \
	    "$(module_fmt_routine -prepend-path CMAKE_PREFIX_PATH $tmp)"
    fi
    # The LD_LIBRARY_PATH is DANGEROUS!
    if [[ $ld_path -eq 1 ]]; then
	add_module_if -F $force -d "$path/lib" $mfile \
		      "$(module_fmt_routine -prepend-path LD_LIBRARY_PATH $fpath/lib)"
	add_module_if -F $force -d "$path/lib64" $mfile \
		      "$(module_fmt_routine -prepend-path LD_LIBRARY_PATH $fpath/lib64)"
    fi
    add_module_if -F $force -d "$path/lib/python" $mfile \
	"$(module_fmt_routine -prepend-path PYTHONPATH $fpath/lib/python)"
    for PV in 2.7 3.6 3.7 3.8 3.9 3.10 ; do
	add_module_if -F $force -d "$path/lib/python$PV/site-packages" $mfile \
	    "$(module_fmt_routine -prepend-path PYTHONPATH $fpath/lib/python$PV/site-packages)"
	add_module_if -F $force -d "$path/lib64/python$PV/site-packages" $mfile \
	    "$(module_fmt_routine -prepend-path PYTHONPATH $fpath/lib64/python$PV/site-packages)"
    done
    if [[ -n "$lua_family" ]]; then
	case $_mod_format in
	    $_mod_format_LMOD)
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
	case $_mod_format in
	    $_mod_format_ENVMOD)
		cat <<EOF >> "$mfile"
puts stderr "$echos"
EOF
		;;
	    $_mod_format_LMOD)
		cat <<EOF >> "$mfile"
LmodMessage("$echos")
EOF
		;;
	esac
    fi


    case $_mod_format in
	$_mod_format_ENVMOD)
    	    if [[ $_mod_survey -ne 0 ]]; then
		cat <<EOF >> "$mfile"

# Reset in_survey
if { \$in_survey == 2 } {
    unsetenv DCC__SURVEY_IN
}
EOF
	    fi
	    ;;
    esac

    # Add path to the directory
    if [[ -n "$use_path" ]]; then
	echo "" >> "$mfile"
	echo "" >> "$mfile"
	echo "$fm_comment Enable a sub-path via this module" >> "$mfile"
	case $_mod_format in
	    $_mod_format_ENVMOD)
		for tmp in $use_path ; do
		    echo "module use --append $tmp" >> "$mfile"
		done
		;;
	    $_mod_format_LMOD)
		doerr "LMOD" "currently not supporting use-path"
		;;
	esac
    fi
    
    if [[ $no_install -eq 1 ]] && [[ $force -eq 0 ]]; then
	rm -f $mfile
    fi
    # If we are to create the default version module we 
    # can add this version to the .version file:
    if [[ $_crt_version -eq 1 ]]; then
	case $_mod_format in
	    $_mod_format_ENVMOD)
		cat <<EOF > $(dirname $mfile)/.version
#%Module1.0
#####################################################################
set ModulesVersion $(basename $mfile)
EOF
		;;
	    $_mod_format_LMOD)
		pushd $(dirname $mfile) 1> /dev/null
		ln -fs $(basename $mfile) default
		popd 1> /dev/null 
		;;
	esac
    fi
}

# Returns the module specific routine call
function module_fmt_routine {
    local lval='' ; local lenv=''
    local opt
    while [[ $# -gt 0 ]]; do
	trim_em opt $1
	shift
	case "$opt" in
	    -prepend-path)
		case $_mod_format in
		    $_mod_format_ENVMOD) printf '%s' "prepend-path $1 $2" ;;
		    $_mod_format_LMOD) printf '%s' "prepend_path(\"$1\",\"$2\")" ;;
		esac
		shift ; shift ;;
	    -append-path)
		case $_mod_format in
		    $_mod_format_ENVMOD) printf '%s' "append-path $1 $2" ;;
		    $_mod_format_LMOD) printf '%s' "append_path(\"$1\",\"$2\")" ;;
		esac
		shift ; shift ;;
	    -undefined-env)
		case $_mod_format in
		    $_mod_format_ENVMOD)
			printf '%s' "if { ![info exists ::env($1)] } {"
			printf '%s' " setenv $1 $2"
			printf '%s' "}"
			;;
		    $_mod_format_LMOD)
			printf '%s\n' "if not os.getenv(\"$1\") then"
			printf '%s\n' "setenv(\"$1\",\"$2\",true)"
			printf '%s' "end"
			;;
		esac
		shift ; shift ;;
	    -set-env)
		case $_mod_format in
		    $_mod_format_ENVMOD) printf '%s' "setenv $1 $2" ;;
		    $_mod_format_LMOD) printf '%s' "setenv(\"$1\",\"$2\",true)" ;;
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
    local d='';local f='' ;local F=0;
    local X=0
    local opt
    while [[ $# -gt 0 ]]; do
	trim_em opt $1
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
    
    local check=''
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
