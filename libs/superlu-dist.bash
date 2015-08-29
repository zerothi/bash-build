for v in 4.0 ; do

add_package --package superlu-dist \
	    --directory SuperLU_DIST_$v \
	    http://crd-legacy.lbl.gov/~xiaoye/SuperLU/superlu_dist_$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libsuperlu.a

pack_set --module-requirement mpi \
	 --module-requirement parmetis

# Prepare the make file
file=make.inc
pack_cmd "echo '# Make file' > make.inc"

pack_cmd "sed -i '1 a\
PLAT =\n\
DSuperLUroot = ..\n\
DSUPERLULIB = \$(DSuperLUroot)/lib/libsuperlu.a\n\
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
' $file"

if $(is_c intel) ; then
    pack_cmd "sed -i '$ a\
BLASLIB = -mkl=sequential\n\
CFLAGS += -std=c99\n\
' $file"
    
else

    for la in $(choice linalg) ; do
	if [[ $(pack_installed $la) -eq 1 ]]; then
	    pack_set --module-requirement $la
	    tmp=
	    [[ "x$la" == "xatlas" ]] && \
		tmp="-lf77blas -lcblas"
	    tmp="$tmp -l$la"
	    pack_cmd "sed -i '1 a\
BLASLIB = $(list --LD-rp $la) $tmp\n\
' $file"
	    break
	fi
    done

fi

# Make commands
pack_cmd "make"

pack_cmd "mkdir -p $(pack_get --LD)/"
pack_cmd "cp lib/libsuperlu.a $(pack_get --LD)/"

done
