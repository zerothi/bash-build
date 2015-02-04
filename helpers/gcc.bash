add_package --build generic \
    ftp://ftp.fu-berlin.de/unix/languages/gcc/releases/gcc-4.9.2/gcc-4.9.2.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --module-requirement build-tools
pack_set $(list --prefix '--module-requirement ' \
    gmp mpfr mpc isl cloog)

pack_set --install-query $(pack_get --prefix)/bin/gcc

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--prefix $(pack_get --prefix)" \
    --command-flag "--with-gmp=$(pack_get --prefix gmp)" \
    --command-flag "--with-mpfr=$(pack_get --prefix mpfr)" \
    --command-flag "--with-mpc=$(pack_get --prefix mpc)" \
    --command-flag "--with-isl=$(pack_get --prefix isl)" \
    --command-flag "--with-cloog=$(pack_get --prefix cloog)" \
    --command-flag "--enable-lto --enable-threads" \
    --command-flag "--enable-languages=c,c++,fortran,go,objc,obj-c++" \
    --command-flag "--with-multilib-list=m64"
#    --command-flag "LDFLAGS=$(list --LDFLAGS --Wlrpath gmp mpfr mpc isl cloog)"

# Make commands
pack_set --command "make BOOT_LDFLAGS='$(list --LDFLAGS --Wlrpath gmp mpfr mpc isl cloog)' $(get_make_parallel)"
# make check requires autogen installed
#pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
#pack_set_mv_test tmp.test

pack_install

create_module \
    --module-path $(build_get --module-path)-npa \
    -n "Nick Papior Andersen's script for loading $(pack_get --package)." \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --mod-req)) \
    -L $(pack_get --alias)

