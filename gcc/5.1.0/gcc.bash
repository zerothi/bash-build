add_package --build generic \
    ftp://ftp.fu-berlin.de/unix/languages/gcc/releases/gcc-5.1.0/gcc-5.1.0.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set $(list --prefix '--module-requirement ' build-tools \
    gmp[6.0.0a] mpfr[3.1.2] mpc[1.0.3] isl[0.14])

pack_set --install-query $(pack_get --prefix)/bin/gcc

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--prefix $(pack_get --prefix)" \
    --command-flag "--with-gmp=$(pack_get --prefix gmp[6.0.0a])" \
    --command-flag "--with-mpfr=$(pack_get --prefix mpfr[3.1.2])" \
    --command-flag "--with-mpc=$(pack_get --prefix mpc[1.0.3])" \
    --command-flag "--with-isl=$(pack_get --prefix isl[0.14])" \
    --command-flag "--enable-lto --enable-threads" \
    --command-flag "--enable-stage1-languages=c,c++,fortran,go,objc,obj-c++" \
    --command-flag "--with-multilib-list=m64"

# Make commands
pack_set --command "make BOOT_LDFLAGS='$(list --LD-rp gmp[6.0.0a] mpfr[3.1.2] mpc[1.0.3] isl[0.14])' $(get_make_parallel)"
# make check requires autogen installed
#pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
#pack_set_mv_test tmp.test

# Add to LD_LIBRARY_PATH, this ensures that at least 
# these libraries always will be present in LD
pack_set --module-opt "--prepend-ENV LD_LIBRARY_PATH=$(pack_get --prefix)/lib64"