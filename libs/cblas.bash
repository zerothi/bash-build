# Then install BLAS
add_package \
    --package cblas \
    --directory CBLAS \
    --version $(pack_get --version blas) \
    http://www.netlib.org/blas/blast-forum/cblas.tgz

pack_set --install-prefix \
    $(get_installation_path)/$(pack_get --alias blas)/$(pack_get --version blas)/$(get_c)

# Required as the version has just been set
pack_set --install-query $(pack_get --install-prefix)/lib/libcblas.a

# Create the directory
pack_set --command "mkdir -p $(pack_get --install-prefix)/include/"

# Prepare the make file
tmp="sed -i -e"
pack_set --command "$tmp 's/\(CC[[:space:]]*=\).*/\1 $CC/g' Makefile.in"
pack_set --command "$tmp 's/\(FC[[:space:]]*=\).*/\1 $FC/g' Makefile.in"
pack_set --command "$tmp 's/\(ARCH[[:space:]]*=\).*/\1 $AR/g' Makefile.in"
pack_set --command "$tmp 's/\(CFLAGS[[:space:]]*=\).*/\1 $CFLAGS -DADD_/g' Makefile.in"
pack_set --command "$tmp 's/\(FFLAGS[[:space:]]*=\).*/\1 $FCFLAGS/g' Makefile.in"
pack_set --command "$tmp 's|\(BLLIB[[:space:]]*=\).*|\1 $(pack_get --install-prefix blas)/lib/libblas.a|g' Makefile.in"
pack_set --command "$tmp 's|\(CBLIB[[:space:]]*=\).*|\1 $(pack_get --install-prefix)/lib/libcblas.a|g' Makefile.in"

# Make commands
pack_set --command "make alllib"
pack_set --command "make alltst"
pack_set --command "make runtst"

# Copy over the header files
pack_set --command "cp include/*.h $(pack_get --install-prefix)/include/"