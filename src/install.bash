# Install the package
function pack_install {
    local tmp
    local idx=$_N_archives
    local err=0
    if [[ $# -ne 0 ]]; then
	idx=$(get_index $1)
	shift
    fi
    local ext=$(pack_get --ext $idx)
    local alias=$(pack_get --alias $idx)
    local prefix=$(pack_get --prefix $idx)
    local version=$(pack_get --version $idx)
    local mod_name=$(pack_get --module-name $idx)

    tmp=$(lc $alias)
    if [[ ${#_pack_only[@]} -gt 0 ]]; then
	if [[ 0${_pack_only[$tmp]} -eq 1 ]]; then
	    pack_only $(pack_get --mod-req-all $idx)
	else
	    return 
	fi
    fi

    # First a simple check that it hasn't already been installed...
    if [[ -e $(pack_get --install-query $idx) ]]; then
	if [[ $(pack_get --installed $idx) -eq $_I_TO_BE ]]; then
	    pack_set --installed $_I_INSTALLED $idx
	fi
    fi

    # Check the hash if it is a git clone, and if so check that the hash
    # is not already installed
    case x$ext in
	xgit)
	    # Check that we haven't already found this has
	    if [[ -e $prefix/.bb.hash ]]; then
		local installed_hash=$(cat $prefix/.bb.hash)
		tmp=$(git ls-remote $(pack_get --url $idx) HEAD | awk '{print $1}')
		[[ "x$tmp" == "x$installed_hash" ]] && pack_set --installed $_I_INSTALLED $idx
	    fi
	    ;;
    esac

    # If we request downloading of files, do so immediately
    if [[ $DOWNLOAD -eq 1 ]]; then
	pack_dwn $idx $(build_get --archive-path)
    fi
    
    # Check that we can install on this host
    local run=1

    # Save the module requirements for later...
    local mod_reqs="$(pack_get --mod-req $idx)"
    local tmp_idx

    # Make sure that every package before is installed...
    for tmp in $mod_reqs ; do
	if [[ -z "${tmp// /}" ]]; then
	    break
	fi
	tmp_idx=$(get_index $tmp)
	if [[ $(pack_get --installed $tmp_idx) -eq $_I_TO_BE ]]; then
	    pack_install $tmp_idx
	fi
	# Capture packages that has been rejected.
	# If it depends on rejected packages, it must itself be rejected.
	if [[ $(pack_get --installed $tmp_idx) -eq $_I_REJECT ]]; then
	    run=0
	    break
	fi
    done

    # If it is installed...
    if [[ $(pack_get --installed $idx) -eq $_I_INSTALLED ]]; then
	msg_install --already-installed $idx
	if [[ $FORCEMODULE -eq 0 ]]; then
	    return 0
	fi
    fi

    local mod_reqs_paths="$(pack_get --mod-req-path $idx)"

    tmp="$(pack_get --host-reject $idx)"
    if [[ -n "$tmp" ]]; then
	# Run should be 1 when we get here...
	for host in $tmp ; do
	    if $(is_host $host) ; then
		run=0 && break
	    fi
	done
    fi

    # Create a list of compilation modules required
    pack_crt_list $idx

    if [[ $run -eq 0 ]]; then
	# Notify other required stuff that this can not be installed.
	pack_set --installed $_I_REJECT $idx
	msg_install --message "Installation rejected for $(pack_get --package $idx)[$version]" $idx
	return 1
    fi

    # Check that the package is not already installed
    if [[ $(pack_get --installed $idx) -eq $_I_TO_BE ]]; then

	# Show that we will install
	msg_install --start $idx

        # Download archive
	pack_dwn $idx $(build_get --archive-path)

        # Go into the build directory
	pushd $(build_get --build-path) 1> /dev/null
	err=$?
	if [[ $err -ne 0 ]]; then
	    msg_install --package "Could not go to the build-path: $(build_get --build-path)" $idx
	    exit $err
	fi

	# Remove directory if already existing
	local directory=$(pack_get --directory $idx)
	case $directory in
	    .|./)
		noop
		;;
	    *)
		rm -rf $directory
		;;
	esac

	# Extract the archive.
	# For repositories this will be equivalent to git clone etc.
	extract_archive $idx $(build_get --archive-path)
	err=$?
	if [[ $err -ne 0 ]]; then
	    msg_install --package "Failed to extract archive from package..." $idx
	    exit $err
	fi

	# Go into source directory
	pushd $directory 1> /dev/null
	err=$?
	if [[ $err -ne 0 ]]; then
	    msg_install --package "Could not go to the source directory: $directory" $idx
	    exit $err
	fi

        # We are now in the package, check for optional build-directory
	if $(has_setting $BUILD_DIR $idx) ; then
	    rm -rf build-tmp
	    mkdir -p build-tmp
	    {
		popd
		pushd $directory/build-tmp
	    } 1> /dev/null 
	fi
	
	# Source the file for obtaining correct env-variables
	tmp=$(pack_get --build $idx)
	source $(build_get --source[$tmp])

	# Begin loading modules before running the commands
	if $(has_setting $BUILD_TOOLS $idx) ; then
	    module load build-tools
	fi

        # Create the list of requirements
	local module_loads="$(list --loop-cmd 'pack_get --module-name' $mod_reqs)"
	if [[ -n "${module_loads}" ]]; then
	    module load $module_loads
	fi

	# If the module should be preloaded (for configures which checks that the path exists)
	if $(has_setting $PRELOAD_MODULE $idx) ; then
	    create_module --force \
			  -n "$alias" -v "$version" \
			  -M "$mod_name" \
			  -p "$(pack_get --module-prefix $idx)" \
			  -P "$prefix"
            # Create the prefix directory
            mkdir -p $prefix
	    # Load module for preloading
	    module load $mod_name
	fi

	# Append all relevant requirements to the relevant environment variables
	# Perhaps this could be generalized with options specifying the ENV_VARS
	local tmp_ld=$(trim_spaces "$(list --LD-rp $mod_reqs_paths)")
	local tmp_inc=$(trim_spaces "$(list --INCDIRS $mod_reqs_paths)")
	old_fcflags="$FCFLAGS"
	old_fflags="$FFLAGS"
	old_cflags="$CFLAGS"
	old_cxxflags="$CXXFLAGS"
	old_ldflags="$LDFLAGS"
	old_cppflags="$CPPFLAGS"
	if $(has_setting $NO_PIC $idx) ; then
	    export FCFLAGS="$(trim_spaces ${FCFLAGS//-fPIC/}) $tmp_ld"
	    export FFLAGS="$(trim_spaces ${FFLAGS//-fPIC/}) $tmp_ld"
	    export CFLAGS="$(trim_spaces ${CFLAGS//-fPIC/}) $tmp_ld"
	    export CXXFLAGS="$(trim_spaces ${CXXFLAGS//-fPIC/}) $tmp_ld"
	    export LDFLAGS="$(trim_spaces ${LDFLAGS//-fPIC/}) $tmp_ld"
	    export CPPFLAGS="$(trim_spaces ${CPPFLAGS//-fPIC/}) $tmp_inc"
	else
	    export FCFLAGS="$(trim_spaces $FCFLAGS) $tmp_ld"
	    export FFLAGS="$(trim_spaces $FFLAGS) $tmp_ld"
	    export CFLAGS="$(trim_spaces $CFLAGS) $tmp_ld"
	    export CXXFLAGS="$(trim_spaces $CXXFLAGS) $tmp_ld"
	    export LDFLAGS="$(trim_spaces $LDFLAGS) $tmp_ld"
	    export CPPFLAGS="$(trim_spaces $CPPFLAGS) $tmp_inc"
	fi
	unset tmp_ld tmp_inc

	# Show currently loaded modules before executing commands
	msg_install --modules $idx
	
	# Run all commands
	tmp="$(pack_get --commands $idx)"
	local -a cmds=()
	IFS="$_LIST_SEP" read -ra cmds <<< "$tmp"
	for tmp in "${cmds[@]}" ; do
	    if [[ -z "${tmp// /}" ]]; then
		continue # Skip the empty commands...
	    fi
	    docmd "Archive: $alias ($version)" "$tmp"
	    err=$?
	    if [[ $err -ne 0 ]]; then
		# Show error about the package installed
		msg_install \
		    --package "Failed to install package..." \
		    $idx
		exit $err
	    fi
	done

	popd 1> /dev/null

        # Remove compilation directory
	if [[ "x$directory" != "x." ]] && [[ "x$directory" != "x./" ]]; then
	    rm -rf $directory
	fi
	
	popd 1> /dev/null
	msg_install --finish $idx
	
	# Unload the requirement modules
	if [[ -n "${module_loads}" ]]; then
	    module unload $module_loads
	fi

	# Unload the module itself in case of PRELOADING
	if $(has_setting $PRELOAD_MODULE $idx) ; then
	    module unload $mod_name
	    # We need to clean up, in order to force the
	    # module creation.
	    rm -f $(pack_get --module-prefix $idx)/$mod_name
	fi

	if $(has_setting $BUILD_TOOLS $idx) ; then
	    module unload build-tools
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

	# Store hash if required
	case x$ext in
	    xgit)
		echo "$hash" > $prefix/.bb.hash
		;;
	esac

    fi

    # Fix the library path...
    if [[ ! -d $(pack_get -LD $idx) ]]; then
	local _lib=""
	for cmd in lib lib64 ; do
	    if [[ -d $prefix/$cmd ]]; then
		_lib="$_lib $cmd"
	    fi
	done
	[[ -n "$_lib" ]] && \
	    pack_set --library-suffix "${_lib:1:}" $idx
    fi

    if [[ $(pack_get --installed $idx) -eq $_I_INSTALLED ]]; then
	if $(has_setting $IS_MODULE $idx) ; then
            # Create the list of requirements
	    local reqs="$(list --prefix '-R ' $mod_reqs)"
            # We install the module scripts here:
	    create_module \
		-n "$alias" \
		-v "$version" \
		-M "$mod_name" \
		-p "$(pack_get --module-prefix $idx)" \
		-P "$prefix" $reqs $(pack_get --module-opt $idx)
	fi
	if $(has_setting $CRT_DEF_MODULE $idx) ; then
	    create_module \
		--module-path $(build_get --module-path)-npa-apps \
		-n $alias.$version/$(get_c) \
		-W "Nick R. Papior script for loading $(pack_get --package $idx): $(get_c)" \
		-v $version \
		-M $alias.$version/$(get_c) \
		-P "/directory/should/not/exist" \
		$(list --prefix '-L ' $(pack_get --mod-req $idx) $idx)
	fi
    fi
}

# Can be used to return the index in the _arrays for the named variable
# $1 is the shortname for what to search for
function get_index {
    local var=_index
    local all=0
    while [[ $# -gt 1 ]]; do
	local opt=$(trim_em $1) ; shift
	case $opt in
	    -all|-a)
		all=1
		;;
	    -hash-array)
		var="$1"
		shift
		;;
	esac
    done
    local i=$1
    shift

    if [[ ${#i} -eq 0 ]]; then
	return 1
    fi
    if $(isnumber $i) ; then
	# We do not check for correctness
	# This just slows it down
	#if [[ "$var" == "_index" ]]; then
	#    [[ $name -gt $_N_archives ]] && return 1
	#elif [[ "$var" == "_b_index" ]]; then
	#    [[ $name -gt $_N_b ]] && return 1
	#fi
	#[[ $name -lt 0 ]] && return 1
	_ps "$i"
	return 0
    fi
    
    # Save the thing that we want to process...
    local name=$(lc $(var_spec $i))
    local version=$(var_spec -s $i)
    # do full variable (for ${!...})
    var="$var[$name]"
    #echo "get_index: name($name) version($version)" >&2

    # Do full expansion.
    local idx=${!var}
    if [[ -z "$idx" ]]; then
	return 1
    fi
    local v
    case $all in
	1)
	    if [[ -n "$version" ]]; then
		for v in $idx ; do
		    if [[ $(vrs_cmp $(pack_get --version $v) $version) -eq 0 ]]; then
			_ps "$v"
			break
		    fi
		done
	    else
		_ps "$idx"
	    fi
	    ;;
	*)
	    i=-1
            # Select the latest per default..
	    if [[ -n "$version" ]]; then
		for v in $idx ; do
		    if [[ $(vrs_cmp $(pack_get --version $v) $version) -eq 0 ]]; then
			i="$v"
			break
		    fi
		done
	    else
		for v in $idx ; do
		    i="$v"
		done
	    fi
	    _ps "$i"
	    ;;
    esac
}


function install_all {
    # First we collect all options
    local j=0
    while [[ $# -ne 0 ]]; do
	local opt="$(trim_em $1)" # Save the option passed
	shift
	case $opt in
	    -from|-f)
		j="$(get_index $1)"
		shift
		;;
	    *)
		shift
		;;
	esac
    done
    for i in `seq $j $_N_archives` ; do
	pack_install $i
    done
}
