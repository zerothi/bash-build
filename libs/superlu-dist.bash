for v in 3.3 4.3 5.1.3 ; do

add_package --package superlu-dist \
	    --directory SuperLU_DIST_$v \
	    http://crd-legacy.lbl.gov/~xiaoye/SuperLU/superlu_dist_$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libsuperlu.a
pack_set --lib -lsuperlu

pack_set --module-requirement mpi \
	 --module-requirement parmetis

# Prepare the make file
file=make.inc
pack_cmd "echo '# Make file' > make.inc"
if [[ $(vrs_cmp $(pack_get --version) 5) -ge 0 ]]; then

pack_cmd "sed -i '1 a\
PLAT =\n\
VERSION = $(pack_get --version)\n\
SuperLUroot = ..\n\
DSUPERLULIB = \$(SuperLUroot)/SRC/libsuperlu_dist.a\n\
BLASDEF = -DUSE_VENDOR_BLAS\n\
METISLIB = $(list --LD-rp parmetis) -lmetis\n\
PARMETISLIB = $(list --LD-rp parmetis) -lparmetis\n\
I_PARMETIS = $(list --INCDIRS parmetis)\n\
LIBS = \$(DSUPERLULIB) \$(BLASLIB) \$(PARMETISLIB) \$(METISLIB) \$(FLIBS)\n\
ARCH = $AR\n\
ARCHFLAGS = cr\n\
RANLIB = ranlib\n\
CC = $MPICC\n\
CFLAGS = $CFLAGS $FLAG_OMP \$(I_PARMETIS)\n\
NOOPTS = ${CFLAGS//-O./}\n\
FORTRAN = $MPIF90\n\
F90FLAGS = $FCFLAGS $FLAG_OMP\n\
LOADER   = $MPICC\n\
LOADOPTS = \$(CFLAGS)\n\
CDEFS    = -DAdd_ -D_OPENMP\n\
' $file"

else
    # this is versions prior to 5

pack_cmd "sed -i '1 a\
PLAT =\n\
DSuperLUroot = ..\n\
DSUPERLULIB = \$(DSuperLUroot)/SRC/libsuperlu_dist.a\n\
BLASDEF = -DUSE_VENDOR_BLAS\n\
METISLIB = $(list --LD-rp parmetis) -lmetis\n\
PARMETISLIB = $(list --LD-rp parmetis) -lparmetis\n\
I_PARMETIS = $(list --INCDIRS parmetis)\n\
LIBS = \$(DSUPERLULIB) \$(BLASLIB) \$(PARMETISLIB) \$(METISLIB) \$(FLIBS)\n\
ARCH = $AR\n\
ARCHFLAGS = cr\n\
RANLIB = ranlib\n\
CC = $MPICC\n\
CFLAGS = $CFLAGS \$(I_PARMETIS)\n\
NOOPTS = ${CFLAGS//-O./}\n\
FORTRAN = $MPIF90\n\
F90FLAGS = $FCFLAGS\n\
LOADER   = $MPICC\n\
LOADOPTS = \$(CFLAGS)\n\
CDEFS    = -DAdd_\n\
CFLAGS += -std=c99\n\
' $file"

fi

# These are standard options
if $(is_c intel) ; then
    pack_cmd "sed -i '$ a\
BLASLIB = $MKL_LIB -mkl=sequential\n\
' $file"
    
else

    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    pack_cmd "sed -i '1 a\
BLASLIB = $(list --LD-rp +$la) $(pack_get -lib $la)\n\
' $file"

fi

# Make commands
pack_cmd "make"

pack_cmd "mkdir -p $(pack_get --LD)/"
pack_cmd "cp SRC/libsuperlu_dist.a $(pack_get --LD)/"
pack_cmd "mkdir -p $(pack_get --prefix)/include"
pack_cmd "cp SRC/*.h $(pack_get --prefix)/include"

done
