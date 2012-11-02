#!/bin/bash

source ~/.bashrc
module purge

# We have here the installation of all the stuff for gray....

# Use ln to link to this file
if [ $# -ne 0 ]; then
    [ ! -e $1 ] && echo "File $1 does not exist, please create." && exit 1
    source $1
else
    [ ! -e compiler.sh ] && echo "Please create file: compiler.sh" && exit 1
    source compiler.sh
fi

source install_funcs.sh
source install_conf_flags.sh


archive_dir=$(pwd)/archives
compile_dir=$(pwd)/compile
# Create directories
mkdir -p $archive_dir
mkdir -p $compile_dir

# Initialize the installation path
set_installation_path $install_path

# Initialize the module read path
set_module_path $install_path/modules

# Initialize the compiler directory
set_c $compiler

# Begin installation of various packages
# List of archives
# The order is the installation order

source openmpi.bash
source zlib.bash
source python2.bash
source python3.bash
source hdf5.bash
source parallel-netcdf.bash
source netcdf.bash
#source git.bash


if [ 0 -eq 1 ]; then
echo After all sourcing:
echo $_N_archives
echo URL: ${_http[@]}
echo ARCHIVES: ${_archive[@]}
echo EXT: ${_ext[@]}
echo DIRECTORY: ${_directory[@]}
echo PACKAGE: ${_package[@]}
echo ALIAS: ${_alias[@]}

echo PREFIX: ${_install_prefix[@]}
echo $_package
echo $_version
fi 
# Set the umask 5 means read and execute
#umask 0

i=0
# Start installation loop
while : ; do
    archive="$(pack_get --archive $i)"
    [ $? -ne "0" ] && break

    # Check that the thing is not already installed
    if [ ! -e $(pack_get --install-query $i) ]; then

        # Show that we will install
	install -I $i

        # Download archive
	dwn_file $i $archive_dir

        # Extract the archive
	pushd $compile_dir
	extract_archive $archive_dir $i
	pushd $(pack_get --directory $i)
	config_dir=./

        # We are now in the package directory
	if [ $(has_setting $BUILD_DIR $i) ]; then
	    rm -rf build ; mkdir -p build ; popd ; pushd $(pack_get --directory $i)/build
	    config_dir=../
	fi

	# If configure, do the configure step
	if [ $(has_setting $CONFIGURE $i) ]; then
	    CONF_ARGS=( $(populate_configure_flags $i) )
	    TMP_LD="$(create_LD $i)"
	    TMP_LDLIBPATH="$(create_LDLIBPATH $i)"
	    TMP_INC="$(create_INC $i)"
	    TMP_LIBS="$(populate_add_LIBS $i)"
	    ( 
		[ -n "$TMP_LD" ] && export LDFLAGS="$TMP_LD"
		[ -n "$TMP_LDLIBPATH" ] && export LD_LIBRARY_PATH="$TMP_LDLIBPATH:$LD_LIBRARY_PATH"
		[ -n "$TMP_INC" ] && export CFLAGS="$CFLAGS $TMP_INC" && export CPPFLAGS="$CPPFLAGS $TMP_INC"
		[ -n "$TMP_LIBS" ] && export LIBS="$TMP_LIBS"
		docmd $archive $config_dir/configure ${CONF_ARGS[@]}
	    )
	    exit_on_error $? "Configure step incomplete"
	fi
	case $(pack_get --package) in
	    hdf5*)
		sed -i -e 's/\[ \-a /\[ \-e /g' ../tools/h5diff/testh5diff.sh
		for M in Makefile* */Makefile* */*/Makefile* */*/*/Makefile* ; do
		    sed -i -e 's/NPROCS:=6/NPROCS:=3/g' $M
		done
		;;
	esac

        # We expect it to always have a make command!!!!
	docmd $archive make $(get_make_parallel $i)

        # Make checks
	if [ $(has_setting $MAKE_CHECK $i) ]; then
	    docmd $archive make check
	fi

        # Make tests
	if [ $(has_setting $MAKE_TEST $i) ]; then
	    docmd $archive make test
	elif [ $(has_setting $MAKE_TESTS $i) ]; then
	    docmd $archive make tests
	fi

        # Make the installation.... 
        # In this case we need to handle it differently if it does not
        # have the installation
	if [ $(has_setting $MAKE_INSTALL $i) ]; then
	    docmd $archive make install
	else
	    echo "We need to do something different here"
	fi

	echo $(populate_requirements $archive)
	if [ $(has_setting $IS_MODULE $i) ]; then
	# We install the module scripts here:
	    create_module \
		-n $(pack_get --alias $i) \
		-v $(pack_get --version $i) \
		-M $(pack_get --module-name $i) \
		-P $(pack_get --install-prefix $i) \
		-R "$(populate_requirements $archive)"
	fi
	popd
	
        # Remove compilation directory
	rm -rf $(pack_get --directory $i)
	
	popd
	install -F $archive
    fi

    if [ $(has_setting $LOAD_MODULE $i) ]; then
        # We install the module scripts here:
	module load $(pack_get --module-name $i)
    fi

    i=$((i+1))
done

# We install the module scripts here:
create_module \
    -n "\"Nick Papior Andersen's module script for: $(get_c)\"" \
    -v $(date +'%j-%g') \
    -M npa/$(get_c) \
    -P "/directory/should/not/exist" \
    -L "$(pack_get --module-name openmpi)" \
    -L "$(pack_get --module-name zlib)" \
    -L "$(pack_get --module-name hdf5)" \
    -L "$(pack_get --module-name netcdf)"