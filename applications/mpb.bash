# Install
add_package http://ab-initio.mit.edu/mpb/mpb-1.4.2.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/mpbi-mpi

pack_set --host-reject ntch --host-reject zeroth \
	--host-reject thul --host-reject surt \
    --host-reject slid

pack_set --module-requirement openmpi \
    --module-requirement libctl \
    --module-requirement zlib \
    --module-requirement hdf5 \
    --module-requirement fftw-2

# Check for Intel MKL or not
tmp=$(get_c)
if [ "${tmp:0:5}" == "intel" ]; then
    tmp="--with-blas='$MKL_LIB -mkl=sequential -lmkl_blas95_lp64'"
    tmp="$tmp --with-lapack='$MKL_LIB -mkl=sequential -lmkl_lapack95_lp64'"

elif [ "${tmp:0:3}" == "gnu" ]; then
    pack_set --module-requirement atlas
    tmp="--with-blas='$(list --LDFLAGS --Wlrpath atlas) -lcblas -lf77blas -latlas'"
    tmp="$tmp --with-lapack='$(list --LDFLAGS --Wlrpath atlas) -llapack_atlas'"

else
    doerr "$(pack_get --package)" "Could not recognize the compiler: $(get_c)"

fi
# Add the CTL library
tmp="$tmp --with-libctl=$(pack_get --install-prefix libctl)/share/libctl"

# Install commands that it should run
pack_set --command "autoconf configure.ac > configure"
pack_set --command "./configure" \
    --command-flag "CC='$MPICC' CXX='$MPICXX'" \
    --command-flag "LDFLAGS='$(list --Wlrpath --LDFLAGS $(pack_get --module-requirement))'" \
    --command-flag "CPPFLAGS='-DH5_USE_16_API=1 $(list --INCDIRS $(pack_get --module-requirement))'" \
    --command-flag "--with-mpi" \
    --command-flag "--prefix=$(pack_get --install-prefix) $tmp" 

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

# Install the inversion symmetric part
pack_set --command "make distclean"
pack_set --command "./configure" \
    --command-flag "CC=$MPICC CXX=$MPICXX" \
    --command-flag "LDFLAGS='$(list --Wlrpath --LDFLAGS $(pack_get --module-requirement))'" \
    --command-flag "CPPFLAGS='-DH5_USE_16_API=1 $(list --INCDIRS $(pack_get --module-requirement))'" \
    --command-flag "--with-inv-symmetry" \
    --command-flag "--with-mpi" \
    --command-flag "--prefix=$(pack_get --install-prefix) $tmp" 

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

pack_install



create_module \
    --module-path $(get_installation_path)/modules-npa-apps \
    -n "\"Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)\"" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" $(list --prefix '-L ' $(get_default_modules)) \
    $(list --prefix '-L ' --loop-cmd 'pack_get --module-name' $(pack_get --module-requirement)) \
    -L $(pack_get --module-name) 
