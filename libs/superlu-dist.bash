for v in 5.4.0 6.4.1 7.2.0 7.1.1 ; do

if [[ $(vrs_cmp $v 5.0) -gt 0 ]]; then
    add_package -package superlu-dist \
		-archive superlu_dist-$v.tar.gz \
		https://github.com/xiaoyeli/superlu_dist/archive/v$v.tar.gz
else
    add_package -package superlu-dist \
		-directory SuperLU_DIST_$v \
		http://crd-legacy.lbl.gov/~xiaoye/SuperLU/superlu_dist_$v.tar.gz
fi

pack_set -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/libsuperlu_dist.a
pack_set -lib -lsuperlu_dist

pack_set -module-requirement mpi \
	 -module-requirement parmetis

# Prepare the make file
file=make.inc
pack_cmd "echo '# Make file' > make.inc"
if [[ $(vrs_cmp $(pack_get -version) 5) -ge 0 ]]; then

    pack_set -build-mod-req build-tools
    opt=

    opt="$opt -DTPL_ENABLE_INTERNAL_BLASLIB=off"
    opt="$opt -DTPL_ENABLE_LAPACKLIB=on"
    # These are standard options
    if $(is_c intel) ; then
	opt="$opt -DTPL_BLAS_LIBRARIES='-mkl=sequential'"
	opt="$opt -DTPL_LAPACK_LIBRARIES='-mkl=sequential'"
    else
	la=lapack-$(pack_choice -i linalg)
	pack_set -module-requirement $la
	opt="$opt -DTPL_BLAS_LIBRARIES='$(pack_get -lib $la) -lgfortran'"
	opt="$opt -DTPL_LAPACK_LIBRARIES='$(pack_get -lib $la) -lgfortran'"
    fi

    opt="$opt -DTPL_PARMETIS_LIBRARIES='$(list -LD-rp parmetis) -lparmetis -lmetis'"
    opt="$opt -DTPL_PARMETIS_INCLUDE_DIRS='$(pack_get -prefix parmetis)/include'"

    pack_cmd "cmake -Bbuild-tmp -S. $opt -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"
    pack_cmd "cmake --build build-tmp"
    pack_cmd "cmake --build build-tmp --target install"

else
    # this is versions prior to 5

pack_cmd "sed -i '1 a\
PLAT =\n\
DSuperLUroot = ..\n\
DSUPERLULIB = \$(DSuperLUroot)/SRC/libsuperlu_dist.a\n\
BLASDEF = -DUSE_VENDOR_BLAS\n\
METISLIB = $(list -LD-rp parmetis) -lmetis\n\
PARMETISLIB = $(list -LD-rp parmetis) -lparmetis\n\
I_PARMETIS = $(list -INCDIRS parmetis)\n\
LIBS = \$(DSUPERLULIB) \$(BLASLIB) \$(PARMETISLIB) \$(METISLIB) \$(FLIBS)\n\
ARCH = $AR\n\
ARCHFLAGS = cr\n\
RANLIB = $RANLIB\n\
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

# These are standard options
if $(is_c intel) ; then
    pack_cmd "sed -i '$ a\
BLASLIB = $MKL_LIB -mkl=sequential\n\
SLU_HAVE_LAPACK = TRUE\n\
LAPACKLIB = $MKL_LIB -mkl=sequential\n\
' $file"
    
else

    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    pack_cmd "sed -i '1 a\
BLASLIB = $(list -LD-rp +$la) $(pack_get -lib $la)\n\
SLU_HAVE_LAPACK = TRUE\n\
LAPACKLIB = $(pack_get -lib $la) \n\
FLIBS = -lgfortran\n\
' $file"

fi

# Make commands
pack_cmd "make"

pack_cmd "mkdir -p $(pack_get -LD)/"
pack_cmd "cp SRC/libsuperlu_dist.a $(pack_get -LD)/"
pack_cmd "mkdir -p $(pack_get -prefix)/include"
pack_cmd "cp SRC/*.h $(pack_get -prefix)/include"

fi

done
