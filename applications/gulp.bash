add_package http://www.student.dtu.dk/~nicpa/packages/gulp_4.0.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/gulp

pack_set --directory $(pack_get --directory)/Src

tmp=$(get_c)
if [ "${tmp:0:5}" == "intel" ]; then
    pack_set --command "sed -i '1 a\
BLAS = $MKL_PATH/lib/libmkl_blas95_lp64.a\n\
LAPACK = $MKL_PATH/lib/libmkl_lapack95_lp64.a' Makefile"
    
elif [ "${tmp:0:3}" == "gnu" ]; then
    pack_set --module-requirement atlas
    tmp=$(pack_get --install-prefix atlas)/lib
    pack_set --command "sed -i '1 a\
BLAS = $tmp/libf77blas.a $tmp/libcblas.a $tmp/libatlas.a\n\
LAPACK = $tmp/liblapack_atlas.a' Makefile"

else
    doerr $(pack_get --package) "Could not determine compiler: $(get_c)"

fi
    pack_set --command "sed -i '1 a\
OPT = \n\
OPT1 = $CFLAGS\n\
OPT2 = -ffloat-store\n\
BAGGER = \n\
RUNF90 = $FC\n\
RUNCC = $CC\n\
FFLAGS = -I.. $FCFLAGS\n\
LIBS = \n\
CFLAGS = -I.. $CFLAGS\n\
ETIME = \n\
GULPENV = \n\
CDABS = cdabs.o\n\
ARCHIVE = $AR rcv\n\
RANLIB = ranlib\n' Makefile"

# Make commands
pack_set --command "make $(get_make_parallel) gulp"
pack_set --command "make $(get_make_parallel) lib"

# Install the package
pack_set --command "mkdir -p $(pack_get --install-prefix)/bin/"
pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/"
pack_set --command "cp gulp $(pack_get --install-prefix)/bin/"
pack_set --command "cp ../libgulp.a $(pack_get --install-prefix)/lib/"

pack_install