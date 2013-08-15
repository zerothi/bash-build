add_package http://www.student.dtu.dk/~nicpa/packages/gulp_4.0.tar.gz

pack_set -s $IS_MODULE

pack_set --host-reject ntch

pack_set --module-opt "--lua-family gulp"

pack_set --install-query $(pack_get --install-prefix)/bin/gulp

pack_set --command "cd Src"

pack_set --module-requirement openmpi

if $(is_c intel) ; then
    pack_set --command "sed -i '1 a\
    LIBS = $MKL_LIB -mkl=sequential -lmkl_blas95_lp64 -lmkl_lapack95_lp64' Makefile"
    
elif $(is_c gnu) ; then
    if [ $(pack_installed atlas) -eq 1 ] ; then
	pack_set --module-requirement atlas
	pack_set --command "sed -i '1 a\
    LIBS = $(list --LDFLAGS --Wlrpath atlas) -llapack_atlas -lf77blas -lcblas -latlas' Makefile"
    else
	pack_set --module-requirement blas --module-requirement lapack
	pack_set --command "sed -i '1 a\
    LIBS = $(list --LDFLAGS --Wlrpath blas lapack) -llapack -lblas' Makefile"
    fi

else
    doerr $(pack_get --package) "Could not determine compiler: $(get_c)"

fi

pack_set --command "sed -i '1 a\
DEFS=-DMPI\n\
OPT = \n\
OPT1 = $CFLAGS\n\
OPT2 = -ffloat-store\n\
BAGGER = \n\
RUNF90 = $MPIF90\n\
RUNCC = $MPICC\n\
FFLAGS = -I.. $FCFLAGS $(list --INCDIRS --LDFLAGS --Wlrpath $(pack_get --module-paths-requirement))\n\
BLAS = \n\
LAPACK = \n\
CFLAGS = -I.. $CFLAGS $(list --INCDIRS --LDFLAGS --Wlrpath $(pack_get --module-paths-requirement))\n\
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


create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement)) \
    -L $(pack_get --alias)
