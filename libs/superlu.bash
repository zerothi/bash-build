add_package --package superlu \
    --directory SuperLU_4.3 \
    http://crd-legacy.lbl.gov/~xiaoye/SuperLU/superlu_4.3.tar.gz

pack_set -s $IS_MODULE

pack_set $(list --prefix "--host-reject " surt muspel slid)

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
    if [ $(pack_installed atlas) -eq 1 ]; then
	pack_set --module-requirement atlas
	pack_set --command "sed -i '1 a\
BLASLIB = $(list --LDFLAGS --Wlrpath atlas) -lf77blas -lcblas -latlas\n\
' $file"

    elif [ $(pack_installed openblas) -eq 1 ]; then
	pack_set --module-requirement openblas
	pack_set --command "sed -i '1 a\
BLASLIB = $(list --LDFLAGS --Wlrpath openblas) -lopenblas\n\
' $file"
	
    else
	pack_set --module-requirement blas
	pack_set --command "sed -i '1 a\
	BLASLIB = $(list --LDFLAGS --Wlrpath blas) -lblas\n\
' $file"
	
    fi

fi

# Make commands
pack_set --command "make superlulib"

pack_set --command "mkdir -p $(pack_get --LD)/"
pack_set --command "cp lib/libsuperlu.a $(pack_get --LD)/"

