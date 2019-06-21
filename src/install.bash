# Install the package
function pack_install {
    local tmp
    typeset -l tmp_lc
    local idx=$_N_archives
    local err=0
    if [[ $# -ne 0 ]]; then
	idx=$(get_index $1)
	shift
    fi

    local ext=$(pack_get -ext $idx)
    local build=$(pack_get -build $idx)
    local alias=$(pack_get -alias $idx)
    local prefix=$(pack_get -prefix $idx)
    local version=$(pack_get -version $idx)
    local mod_name=$(pack_get -module-name $idx)
    local installed=$(pack_get -installed $idx)

    # Ensure we have populated the rejection
    local rejs=$(build_get -rejects[$build])
    for rej in $rejs ; do
	local bld=$(get_index -a $rej)
	if [[ $? -eq 0 && -n "$bld" ]]; then
	    case " $bld " in
		*" $idx "*)
		    pack_set $idx -host-reject $(get_hostname)
		    break
		    ;;
	    esac
	fi
    done

    tmp_lc="$alias"
    if [[ ${#_pack_only[@]} -gt 0 ]]; then
	if [[ 0${_pack_only[$tmp_lc]} -eq 1 ]]; then
	    pack_only $(pack_get -mod-req-all $idx)
	else
	    return 
	fi
    fi

    # First a simple check that it hasn't already been installed...
    if [[ -e $(pack_get -install-query $idx) ]]; then
	if [[ $installed -eq $_I_TO_BE ]]; then
	    pack_set $idx -installed $_I_INSTALLED
	    installed=$_I_INSTALLED
	fi
    fi

    # Check the hash if it is a git clone, and if so check that the hash
    # is not already installed
    local hash='UNDEFINED'
    case x$ext in
	xgit)
	    # Check that we haven't already found this has
	    tmp=$(pack_get -url $idx)
	    hash=${tmp#*@}
	    if [[ "x$tmp" == "x$hash" ]]; then
		hash=$(git ls-remote $tmp HEAD | awk '{print $1}')
	    fi
	    if [[ -e $prefix/.bb.hash ]]; then
		local installed_hash=$(cat $prefix/.bb.hash)
		if [[ "x$hash" == "x$installed_hash" ]]; then
		    pack_set $idx -installed $_I_INSTALLED
		    installed=$_I_INSTALLED
		fi
	    fi
	    ;;
    esac

    # If we request downloading of files, do so immediately
    local bld_archive_path=$(build_get -archive-path[$build])
    local bld_mod_path=$(build_get -module-path[$build])
    if [[ $DOWNLOAD -eq 1 ]]; then
	pack_dwn $idx $bld_archive_path
    fi
    
    # Check that we can install on this host
    local run=1

    # Save the module requirements for later...
    local tmp_idx
    local tmp_inst

    # Make sure that every package before is installed...
    for tmp in $(pack_get -mod-req $idx) ; do
	if [[ -z "${tmp// /}" ]]; then
	    break
	fi
	tmp_idx=$(get_index $tmp)
	tmp_inst=$(pack_get -installed $tmp_idx)
	case $tmp_inst in
	    $_I_TO_BE)
		pack_install $tmp_idx
		[ $(pack_get -installed $tmp_idx) -eq $_I_REJECT ] && run=0 && break
		;;
	    $_I_REJECT)
		# Capture packages that has been rejected.
		# If it depends on rejected packages, it must itself be rejected.
		run=0
		break
		;;
	esac
    done
    
    # If it is installed...
    if [[ $installed -eq $_I_INSTALLED ]]; then
	msg_install -already-installed $idx
	if [[ $FORCEMODULE -eq 0 ]]; then
	    return 0
	fi
    fi

    local mod_reqs_paths="$(pack_get -mod-req-path $idx)"

    tmp="$(pack_get -host-reject $idx)"
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
	pack_set $idx -installed $_I_REJECT
	installed=$_I_REJECT
	msg_install -message "Installation rejected for $(pack_get -package $idx)[$version]" $idx
	return 1
    fi
    
    # Check that the package is not already installed
    if [[ $installed -eq $_I_TO_BE ]]; then
	
	# Check whether the module installation path is *enabled*
	local bld_mod_path_is_used=0
	module is-used $bld_mod_path
	bld_mod_path_is_used=$?
	if [[ $bld_mod_path_is_used -ne 0 ]]; then
	    module use -a $bld_mod_path
	fi
	
	# Show that we will install
	msg_install -start $idx

        # Download archive
	pack_dwn $idx $bld_archive_path

        # Go into the build directory
	pushd $(build_get -build-path[$build]) 1> /dev/null
	err=$?
	if [[ $err -ne 0 ]]; then
	    msg_install -package "Could not go to the build-path: $(build_get -build-path[$build])" $idx
	    exit $err
	fi

	# Remove directory if already existing
	local directory=$(pack_get -directory $idx)
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
	if $(has_setting $INSTALL_FROM_ARCHIVE $idx) ; then
	    pushd . 1> /dev/null
	else
	    extract_archive $idx $bld_archive_path
	    err=$?
	    if [[ $err -ne 0 ]]; then
		msg_install -package "Failed to extract archive from package..." $idx
		exit $err
	    fi

	    # Go into source directory
	    pushd $directory 1> /dev/null
	    err=$?
	    if [[ $err -ne 0 ]]; then
		msg_install -package "Could not go to the source directory: $directory" $idx
		exit $err
	    fi
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
	source $(build_get -source[$build])

	# Begin loading modules before running the commands
	if $(has_setting $BUILD_TOOLS $idx) ; then
	    module load build-tools
	    local st=$?
	    if [[ $st -ne 0 ]]; then
		msg_install -message "Failed loading modules (STATUS=$st): build-tools"
		exit $st
	    fi
	fi

        # Create the list of requirements
	local module_loads
	module_loads="$(list -loop-cmd 'pack_get -module-name' $(pack_get -build-mod-req-all $idx)) $(list -loop-cmd 'pack_get -module-name' $(pack_get -mod-req-module $idx))"
	if [[ -n "${module_loads// /}" ]]; then
	    module load $module_loads
	    local st=$?
	    if [[ $st -ne 0 ]]; then
		msg_install -message "Failed loading modules (STATUS=$st): $module_loads"
		exit $st
	    fi
	fi

	# If the module should be preloaded (for configures which checks that the path exists)
	if $(has_setting $PRELOAD_MODULE $idx) ; then
	    create_module -force \
			  -n "$alias" -v "$version" \
			  -M "$mod_name" \
			  -p "$(pack_get -module-prefix $idx)" \
			  -P "$prefix"
            # Create the prefix directory
            mkdir -p $prefix
	    # Load module for preloading
	    module load $mod_name
	    local st=$?
	    if [[ $st -ne 0 ]]; then
		msg_install -message "Failed loading modules (STATUS=$st): $mod_name"
		exit $st
	    fi
	fi

	# Append all relevant requirements to the relevant environment variables
	# Perhaps this could be generalized with options specifying the ENV_VARS
	local tmp_ld=$(trim_spaces "$(list -LD-rp $mod_reqs_paths)")
	local tmp_inc=$(trim_spaces "$(list -INCDIRS $mod_reqs_paths)")
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

	# Generate the file that contains sourced information
	# to reproduce the environment at build-time
	{
	    echo "#!/bin/bash"
	    echo "# bash-build variable file for ensuring the correct environment"
	    echo "# as when this package was built."
	    echo "# NOTE:"
	    echo "# It is not necessarily *exactly* the same environment since command-line"
	    echo "# flags may have overridden some of them and/or others have been specified."
	    echo ""
	    if $(has_setting $BUILD_TOOLS $idx) ; then
		echo "module load build-tools"
	    fi
	    if [[ -n "${module_loads// /}" ]]; then
		echo "module load $module_loads"
	    fi
	    for tmp in CC FC F77 F90 \
			  MPICC MPICXX MPIFC MPIF77 MPIF90 \
			  AR NM RANLIB \
			  FCFLAGS FFLAGS CFLAGS CXXFLAGS CPPFLAGS LDFLAGS
	    do
		[ -n "${!tmp}" ] && echo "export $tmp='${!tmp}'"
	    done
	} > .bb.current.source.bash

	# Show currently loaded modules before executing commands
	msg_install -modules $idx

	env > .bb.current.env

	(
	    # Run all commands
	    tmp="$(pack_get -commands $idx)"
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
		    msg_install -package "Failed to install package..." $idx
		    exit $err
		fi
	    done
	)
	err=$?
	if [[ $err -ne 0 ]]; then
	    # Show error about the package installed
	    msg_install -package "Quitting script to install package..." $idx
	    exit $err
	fi

	# If configuration files exists, we will copy them
	for tmp in config.log CMakeFiles/CMakeOutput.log CMakeFiles/CMakeError.log CMakeCache.txt
	do
	    if [[ -e $tmp ]]; then
		if [[ -d $prefix ]]; then
		    # copy the config.log to the prefix location
		    mv $tmp $prefix/
		    pushd $prefix 2>/dev/null
		    gzip -f -9 $(basename $tmp)
		    popd 2>/dev/null
		fi
	    fi
	done

	popd 1> /dev/null

        # Remove compilation directory
	if [[ "x$directory" != "x." ]] && [[ "x$directory" != "x./" ]] && [ -d $directory ]; then
	    rm -rf $directory
	fi
	
	popd 1> /dev/null
	msg_install -finish $idx
	
	# Unload the requirement modules
	if [[ -n "${module_loads// /}" ]]; then
	    module unload $module_loads
	fi

	# Unload the module itself in case of PRELOADING
	if $(has_setting $PRELOAD_MODULE $idx) ; then
	    module unload $mod_name
	    # We need to clean up, in order to force the
	    # module creation.
	    rm -f $(pack_get -module-prefix $idx)/$mod_name
	fi

	if $(has_setting $BUILD_TOOLS $idx) ; then
	    module unload build-tools
	fi

	# Generate the file that contains sourced information
	# to reproduce the environment at build-time
	{
	    echo "#!/bin/bash"
	    echo "# bash-build variable file for ensuring the correct environment"
	    echo "# as when this package was built."
	    echo "# NOTE:"
	    echo "# It is not necessarily *exactly* the same environment since command-line"
	    echo "# flags may have overridden some of them and/or others have been specified."
	    echo ""
	    if $(has_setting $BUILD_TOOLS $idx) ; then
		echo "module load build-tools"
	    fi
	    if [[ -n "${module_loads// /}" ]]; then
		echo "module load $module_loads"
	    fi
	    for tmp in CC FC F77 F90 \
			  MPICC MPICXX MPIFC MPIF77 MPIF90 \
			  AR NM RANLIB \
			  FCFLAGS FFLAGS CFLAGS CXXFLAGS CPPFLAGS LDFLAGS
	    do
		[ -n "${!tmp}" ] && echo "export $tmp='${!tmp}'"
	    done
	} > $prefix/bb.source.bash
	    
	export FCFLAGS="$old_fcflags"
	export FFLAGS="$old_fflags"
	export CFLAGS="$old_cflags"
	export CXXFLAGS="$old_cxxflags"
	export CPPFLAGS="$old_cppflags"
	export LDFLAGS="$old_ldflags"
	#export LD_LIBRARY_PATH="$old_ld_lib_path"

        # For sure it is now installed...
	pack_set $idx -installed $_I_INSTALLED
	installed=$_I_INSTALLED

	# Store hash if required
	case x$ext in
	    xgit)
		echo "$hash" > $prefix/.bb.hash
		;;
	esac

	if [[ $bld_mod_path_is_used -ne 0 ]]; then
	    module unuse $bld_mod_path
	fi

    fi

    # Fix the library path...
    if [[ ! -d $(pack_get -LD $idx) ]]; then
	local _lib=""
	for cmd in lib lib64 ; do
	    if [[ -d $prefix/$cmd ]]; then
		_lib="$_lib $cmd"
	    fi
	done
	[[ -n "$_lib" ]] && pack_set $idx -library-suffix "${_lib:1:}"
    fi

    if [[ $installed -eq $_I_INSTALLED ]]; then
	if $(has_setting $IS_MODULE $idx) ; then
            # Create the list of requirements
	    local reqs="$(list -prefix '-R ' $(pack_get -mod-req-module $idx))"
            # We install the module scripts here:
	    create_module \
		-n "$alias" \
		-v "$version" \
		-M "$mod_name" \
		-p "$(pack_get -module-prefix $idx)" \
		-P "$prefix" $reqs $(pack_get -module-opt $idx)
	else
	    # It means it is installed but not a module
	    # In this case we *must* specify it as not a module
	    pack_set $idx -installed $_I_LIB
	    installed=$_I_LIB
	fi
	if $(has_setting $CRT_DEF_MODULE $idx) ; then
	    create_module \
		-module-path $bld_mod_path-apps \
		-n $alias.$version \
		-W "Loading $(pack_get -package $idx): $(get_c)" \
		-v $version \
		-M $alias.$version \
		-P "/directory/should/not/exist" \
		$(list -prefix '-L ' $(pack_get -mod-req-module $idx) $idx)
	fi
    fi
}

# Can be used to return the index in the _arrays for the named variable
# $1 is the shortname for what to search for
function get_index {
    local var=_index
    local all=0
    local v
    while [[ $# -gt 1 ]]; do
	case $1 in
	    --all|-all|-a)
		all=1
		shift
		;;
	    --hash-array|-hash-array)
		var="$2"
		shift 2
		;;
	esac
    done
    local i="$1"
    shift

    if [[ -z "$i" ]]; then
	return 1
    fi
    if (isnumber $i) ; then
	# We do not check for correctness
	# This just slows it down
	#if [[ "$var" == "_index" ]]; then
	#    [[ $name -gt $_N_archives ]] && return 1
	#elif [[ "$var" == "_b_index" ]]; then
	#    [[ $name -gt $_N_b ]] && return 1
	#fi
	#[[ $name -lt 0 ]] && return 1
	printf '%s' "$i"
	return 0
    fi
    
    # Save the thing that we want to process...
    typeset -l name="$(var_spec $i)"
    local version=$(var_spec -s $i)
    # do full variable (for ${!...})
    var="$var[$name]"
    #echo "get_index: $var name($name) version($version)" >&2

    # Do full expansion.
    local idx=${!var}
    if [[ -z "$idx" ]]; then
	return 1
    fi
    case $all in
	1)
	    if [[ -n "$version" ]]; then
		for v in $idx ; do
		    if [[ $(vrs_cmp $(pack_get -version $v) $version) -eq 0 ]]; then
			printf '%s' "$v"
			break
		    fi
		done
	    else
		printf '%s' "$idx"
	    fi
	    ;;
	*)
	    i=-1
            # Select the latest per default..
	    if [[ -n "$version" ]]; then
		for v in $idx ; do
		    if [[ $(vrs_cmp $(pack_get -version $v) $version) -eq 0 ]]; then
			i="$v"
			break
		    fi
		done
	    else
		for v in $idx ; do
		    i="$v"
		done
	    fi
	    printf '%s' "$i"
	    ;;
    esac
}


function install_all {
    # First we collect all options
    local j=0
    local opt
    while [[ $# -ne 0 ]]; do
	trim_em opt $1
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
    for i in $(seq $j $_N_archives) ; do
	pack_install $i
    done
}
