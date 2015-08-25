# Install the package
function pack_install {
    local idx=$_N_archives
    if [ $# -ne 0 ]; then
	idx=$(get_index $1) ; shift
    fi
    local alias=$(pack_get --alias $idx)
    local prefix=$(pack_get --prefix $idx)

    local tmp=$(lc $alias)
    if [ ${#_pack_only[@]} -gt 0 ]; then
	if [ 0${_pack_only[$tmp]} -eq 1 ]; then
	    pack_only $(pack_get --mod-req-all $idx)
	else
	    return 
	fi
    fi

    # First a simple check that it hasn't already been installed...
    if [ -e $(pack_get --install-query $idx) ]; then
	if [ $(pack_get --installed $idx) -eq $_I_TO_BE ]; then
	    pack_set --installed $_I_INSTALLED $idx
	fi
    fi

    # If we request downloading of files, do so immediately
    if [ $DOWNLOAD -eq 1 ]; then
	pack_dwn $idx $(build_get --archive-path)
    fi
    
    # Check that we can install on this host
    local run=1

    # Save the module requirements for later...
    local mod_reqs="$(pack_get --mod-req $idx)"
    local tmp
    local tmp_idx

    # Make sure that every package before is installed...
    for tmp in $mod_reqs ; do
	[ -z "${tmp// /}" ] && break
	tmp_idx=$(get_index $tmp)
	if [ $(pack_get --installed $tmp_idx) -eq $_I_TO_BE ]; then
	    pack_install $tmp_idx
	fi
	# Capture packages that has been rejected.
	# If it depends on rejected packages, it must itself be rejected.
	if [ $(pack_get --installed $tmp_idx) -eq $_I_REJECT ]; then
	    run=0
	    break
	fi
    done

    # If it is installed...
    if [ $(pack_get --installed $idx) -eq $_I_INSTALLED ]; then
	msg_install --already-installed $idx
	if [ $FORCEMODULE -eq 0 ]; then
	    return 0
	fi
    fi

    local mod_reqs_paths="$(pack_get --mod-req-path $idx)"

    local tmp="$(pack_get --host-only $idx)"
    if [ ! -z "$tmp" ]; then
	run=0
	for host in $tmp ; do
	    if $(is_host $host) ; then
		run=1 && break
	    fi
	done
    fi
    local tmp="$(pack_get --host-reject $idx)"
    if [ ! -z "$tmp" ]; then
	# Run should be 1 when we get here...
	for host in $tmp ; do
	    if $(is_host $host) ; then
		run=0 && break
	    fi
	done
    fi

    # Create a list of compilation modules required
    pack_crt_list $idx

    if [ $run -eq 0 ]; then
	# Notify other required stuff that this can not be installed.
	pack_set --installed $_I_REJECT $idx
	msg_install --message "Installation rejected for $(pack_get --package $idx)" $idx
	return 1
    fi

    # Check that the package is not already installed
    if [ $(pack_get --installed $idx) -eq $_I_TO_BE ]; then

	# Source the file for obtaining correct env-variables
	local tmp=$(pack_get --build $idx)
	source $(build_get --source[$tmp])

        # Create the list of requirements
	local module_loads="$(list --loop-cmd 'pack_get --module-name' $mod_reqs)"
	module load $module_loads

	# If the module should be preloaded (for configures which checks that the path exists)
	if $(has_setting $PRELOAD_MODULE $idx) ; then
	    create_module --force \
		-n "$alias" \
		-v "$(pack_get --version $idx)" \
		-M "$(pack_get --module-name $idx)" \
		-p "$(pack_get --module-prefix $idx)" \
		-P "$prefix"
        # Create the prefix directory
        mkdir -p $prefix
	    # Load module for preloading
	    module load $(pack_get --module-name $idx)
	fi

	# Append all relevant requirements to the relevant environment variables
	# Perhaps this could be generalized with options specifying the ENV_VARS
	local tmp=$(trim_spaces "$(list --LD-rp $mod_reqs_paths)")
	old_fcflags="$FCFLAGS"
	export FCFLAGS="$(trim_spaces $FCFLAGS) $tmp"
	old_fflags="$FFLAGS"
	export FFLAGS="$(trim_spaces $FFLAGS) $tmp"
	old_cflags="$CFLAGS"
	export CFLAGS="$(trim_spaces $CFLAGS) $tmp"
	old_cxxflags="$CXXFLAGS"
	export CXXFLAGS="$(trim_spaces $CXXFLAGS) $tmp"
	old_ldflags="$LDFLAGS"
	export LDFLAGS="$(trim_spaces $LDFLAGS) $tmp"
	tmp=$(trim_spaces "$(list --INCDIRS $mod_reqs_paths)")
	old_cppflags="$CPPFLAGS"
	export CPPFLAGS="$(trim_spaces $CPPFLAGS) $tmp"
	#old_ld_lib_path="$LD_LIBRARY_PATH"
	#export LD_LIBRARY_PATH="$LD_LIBRARY_PATH$(list --prefix : --loop-cmd 'pack_get --prefix' --suffix '/lib' $mod_reqs_paths)"

        # Show that we will install
	msg_install --start $idx
	
        # Download archive
	pack_dwn $idx $(build_get --archive-path)

        # Extract the archive
	pushd $(build_get --build-path) 1> /dev/null
	[ $? -ne 0 ] && exit 1

	# Remove directory if already existing
	local directory=$(pack_get --directory $idx)
	if [ "x$directory" != "x." ] && [ "x$directory" != "x./" ]; then
	    rm -rf $directory
	fi
	extract_archive $(build_get --archive-path) $idx
	pushd $directory 1> /dev/null
	[ $? -ne 0 ] && exit 1

        # We are now in the package directory
	if $(has_setting $BUILD_DIR $idx) ; then
	    rm -rf build-tmp ; mkdir -p build-tmp ; popd 1> /dev/null 
	    pushd $directory/build-tmp 1> /dev/null
	fi
	
	# Run all commands
	local cmd="$(pack_get --commands $idx)"
	local -a cmds=()
	IFS="$_LIST_SEP" read -ra cmds <<< "$cmd"
	for cmd in "${cmds[@]}" ; do
	    [ -z "${cmd// /}" ] && continue # Skip the empty commands...
	    docmd "$idx" "$cmd"
	done

	popd 1> /dev/null

        # Remove compilation directory
	if [ "x$directory" != "x." ] && [ "x$directory" != "x./" ]; then
	    rm -rf $directory
	fi
	
	popd 1> /dev/null
	msg_install --finish $idx
	
	# Unload the requirement modules
        module unload $module_loads

	# Unload the module itself in case of PRELOADING
	if $(has_setting $PRELOAD_MODULE $idx) ; then
	    module unload $(pack_get --module-name $idx)
	    # We need to clean up, in order to force the
	    # module creation.
	    rm -f $(pack_get --module-prefix $idx)/$(pack_get --module-name $idx)
	fi

	export FCFLAGS="$old_fcflags"
	export FFLAGS="$old_fflags"
	export CFLAGS="$old_cflags"
	export CXXFLAGS="$old_cxxflags"
	export CPPFLAGS="$old_cppflags"
	export LDFLAGS="$old_ldflags"
	#export LD_LIBRARY_PATH="$old_ld_lib_path"

        # For sure it is now installed...
	pack_set --installed $_I_INSTALLED $idx

    fi

    # Fix the library path...
    # We favour lib64
    if [ ! -d $(pack_get -LD $idx) ]; then
	for cmd in lib lib64 ; do
	    if [ -d $prefix/$cmd ]; then
		pack_set --library-suffix $cmd $idx
	    fi
	done
    fi

    if [ $(pack_get --installed $idx) -eq $_I_INSTALLED ]; then
	if $(has_setting $IS_MODULE $idx) ; then
        # Create the list of requirements
	    local reqs="$(list --prefix '-R ' $mod_reqs)"
            # We install the module scripts here:
	    create_module \
		-n "$alias" \
		-v "$(pack_get --version $idx)" \
		-M "$(pack_get --module-name $idx)" \
		-p "$(pack_get --module-prefix $idx)" \
		-P "$prefix" $reqs $(pack_get --module-opt $idx)
	fi
	if $(has_setting $CRT_DEF_MODULE $idx) ; then
	    create_module \
		--module-path $(build_get --module-path)-npa-apps \
		-n "Nick Papior Andersen script for loading $(pack_get --package $idx): $(get_c)" \
		-v $(pack_get --version $idx) \
		-M $(pack_get --alias $idx).$(pack_get --version $idx)/$(get_c) \
		-P "/directory/should/not/exist" \
		$(list --prefix '-L ' $(pack_get --mod-req $idx)) \
		-L $(pack_get --alias $idx)
	fi
    fi
}

# Can be used to return the index in the _arrays for the named variable
# $1 is the shortname for what to search for
function get_index {
    local var=_index
    local i ; local lookup ; local all=0
    while [ $# -gt 1 ]; do
	local opt=$(trim_em $1) ; shift
	case $opt in
	    -all|-a) all=1                ;;
	    -hash-array) var="$1" ; shift ;;
	esac
    done
    local l=$1 ; shift
    [ ${#l} -eq 0 ] && return 1
    # Save the thing that we want to process...
    local name=$(var_spec $l)
    local version=$(var_spec -s $l)
    name="$(lc $name)"
    # do full variable (for ${!...})
    l=${#name}
    var="$var[$name]"
    #echo "get_index: name($name) version($version)" >&2
    if $(isnumber $name) ; then
	if [ "$var" == "_index" ]; then
	    [ $name -gt ${#_index[@]} ] && return 1
	elif [ "$var" == "_b_index" ]; then
	    [ $name -gt ${#_b_index[@]} ] && return 1
	fi
	[ $name -lt 0 ] && return 1
	_ps "$name"
	return 0
    fi
    # Do full expansion.
    local idx=${!var}
    i=0
    if [ -z "$idx" ]; then
	return 1
    fi
    local v
    if [ $all -eq 1 ]; then
	if [ ! -z "$version" ]; then
	    for v in $idx ; do
		if [ $(vrs_cmp $(pack_get --version $v) $version) -eq 0 ]; then
		    _ps "$v"
		    break
		fi
	    done
	else
	    _ps "$idx"
	fi
	return 0
    else
	i=-1
        # Select the latest per default..
	for v in $idx ; do
	    if [ ! -z "$version" ]; then
		if [ $(vrs_cmp $(pack_get --version $v) $version) -eq 0 ]; then
		    i="$v"
		    break
		fi
	    else
		i="$v"
	    fi
	done
    fi
    [ -z "${i// /}" ] && i=-1
    _ps "$i"
    return 0
}


function install_all {
    # First we collect all options
    local j=0
    while [ $# -ne 0 ]; do
	local opt="$(trim_em $1)" # Save the option passed
	shift
	case $opt in
	    -from|-f)    j="$(get_index $1)" ; shift ;;
	    *) shift ;;
	esac
    done
    for i in `seq $j $_N_archives` ; do
	pack_install $i
    done
}
