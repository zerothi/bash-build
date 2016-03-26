for v in 4.3 ; do
add_package http://www.student.dtu.dk/~nicpa/packages/gulp-$v.tar.gz

pack_set --module-opt "--lua-family gulp"

pack_set --install-query $(pack_get --prefix)/bin/gulp

pack_cmd "cd Src"

pack_set --module-requirement mpi

file=Makefile
if $(is_c intel) ; then
    pack_cmd "sed -i '1 a\
    LIBS = $MKL_LIB -mkl=sequential -lmkl_blas95_lp64 -lmkl_lapack95_lp64' $file"
    
else

    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    pack_cmd "sed -i '1 a\
LIBS = $(list --LD-rp +$la) $(pack_get -lib $la)' $file"

fi

pack_cmd "sed -i '1 a\
DEFS=-DMPI\n\
OPT = \n\
OPT1 = $CFLAGS\n\
OPT2 = -ffloat-store\n\
BAGGER = \n\
RUNF90 = $MPIF90\n\
RUNCC = $MPICC\n\
FFLAGS = -I.. $FCFLAGS $(list --INCDIRS --LD-rp $(pack_get --mod-req-path))\n\
BLAS = \n\
LAPACK = \n\
CFLAGS = -I.. $CFLAGS $(list --INCDIRS --LD-rp $(pack_get --mod-req-path))\n\
ETIME = \n\
GULPENV = \n\
CDABS = cdabs.o\n\
ARCHIVE = $AR rcv\n\
RANLIB = ranlib\n' $file"

# Make commands
pack_cmd "make $(get_make_parallel) gulp"
pack_cmd "make $(get_make_parallel) lib"

# Install the package
pack_cmd "mkdir -p $(pack_get --prefix)/bin/"
pack_cmd "mkdir -p $(pack_get --LD)/"
pack_cmd "cp gulp $(pack_get --prefix)/bin/"
pack_cmd "cp ../libgulp.a $(pack_get --LD)/"

# Move the doc and libraries
pack_cmd "mv ../Docs $(pack_get --prefix)/"
pack_cmd "mv ../Libraries $(pack_get --prefix)/"
# Add env variables
pack_set --module-opt "--set-ENV GULP_DOC=$(pack_get --prefix)/Docs"
pack_set --module-opt "--set-ENV GULP_LIB=$(pack_get --prefix)/Libraries"

done
