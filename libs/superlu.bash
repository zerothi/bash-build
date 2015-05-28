add_package --package superlu \
    --directory SuperLU_4.3 \
    http://crd-legacy.lbl.gov/~xiaoye/SuperLU/superlu_4.3.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libsuperlu.a

# Prepare the make file
file=make.inc
pack_set --command "echo '# Make file' > make.inc"

pack_set --command "sed -i '1 a\
PLAT =\n\
SuperLUroot = ..\n\
SUPERLULIB = \$(SuperLUroot)/lib/libsuperlu.a\n\
BLASDEF = -DUSE_VENDOR_BLAS\n\
LIBS = \$(SUPERLULIB) \$(BLASLIB) \n\
ARCH = $AR\n\
ARCHFLAGS = cr\n\
RANLIB = ranlib\n\
CC = $CC\n\
CFLAGS = $CFLAGS\n\
NOOPTS = ${CFLAGS//-O./}\n\
FORTRAN = $FC\n\
F90FLAGS = $FCFLAGS\n\
LOADER   = $CC\n\
LOADOPTS = \$(CFLAGS)\n\
CDEFS    = -DAdd_\n\
' $file"

if $(is_c intel) ; then
    pack_set --command "sed -i '1 a\
BLASLIB = -mkl=sequential\n\
' $file"
    
else

    for la in $(choice linalg) ; do
	if [ $(pack_installed $la) -eq 1 ]; then
	    pack_set --module-requirement $la
	    tmp=
	    [ "x$la" == "xatlas" ] && \
		tmp="-lf77blas -lcblas"
	    tmp="$tmp -l$la"
	    pack_set --command "sed -i '1 a\
BLASLIB = $(list --LD-rp $la) $tmp\n\
' $file"
	    break
	fi
    done

fi

# Make commands
pack_set --command "make superlulib"

pack_set --command "mkdir -p $(pack_get --LD)/"
pack_set --command "cp lib/libsuperlu.a $(pack_get --LD)/"

