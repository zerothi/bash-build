# Then install BLAS
add_package \
    --package cblas \
    --directory CBLAS \
    --version $(pack_get --version blas) \
    http://www.netlib.org/blas/blast-forum/cblas.tgz

pack_set --prefix $(pack_get --prefix blas)

# Required as the version has just been set
pack_set --install-query $(pack_get --LD)/libcblas.a

# Create the directory
pack_set --command "mkdir -p $(pack_get --prefix)/include/"

# Prepare the make file
tmp="sed -i -e"
pack_set --command "$tmp 's/\(CC[[:space:]]*=\).*/\1 $CC/g' Makefile.in"
pack_set --command "$tmp 's/\(FC[[:space:]]*=\).*/\1 $FC/g' Makefile.in"
pack_set --command "$tmp 's/\(ARCH[[:space:]]*=\).*/\1 $AR/g' Makefile.in"
pack_set --command "$tmp 's/\(CFLAGS[[:space:]]*=\).*/\1 $CFLAGS -DADD_/g' Makefile.in"
pack_set --command "$tmp 's/\(FFLAGS[[:space:]]*=\).*/\1 $FCFLAGS/g' Makefile.in"
pack_set --command "$tmp 's|\(BLLIB[[:space:]]*=\).*|\1 $(pack_get --LD blas)/libblas.a|g' Makefile.in"
pack_set --command "$tmp 's|\(CBLIB[[:space:]]*=\).*|\1 $(pack_get --LD)/libcblas.a|g' Makefile.in"

# Make commands
pack_set --command "make alllib"
pack_set --command "make alltst > tmp.test 2>&1"
pack_set --command "make runtst >> tmp.test 2>&1"
pack_set_mv_test tmp.test

# Copy over the header files
pack_set --command "cp include/*.h $(pack_get --prefix)/include/"
