add_package --package superlu \
	    --directory SuperLU_4.3 \
	    http://crd-legacy.lbl.gov/~xiaoye/SuperLU/superlu_4.3.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libsuperlu.a

# Prepare the make file
file=make.inc
pack_cmd "echo '# Make file' > make.inc"

pack_cmd "sed -i '1 a\
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
    pack_cmd "sed -i '1 a\
BLASLIB = -mkl=sequential\n\
' $file"
    
else

    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    pack_cmd "sed -i '1 a\
BLASLIB = $(list --LD-rp +$la) $(pack_get -lib $la)\n\
' $file"
	    break
	fi
    done

fi

# Make commands
pack_cmd "make superlulib"

pack_cmd "mkdir -p $(pack_get --LD)/"
pack_cmd "cp lib/libsuperlu.a $(pack_get --LD)/"
pack_cmd "mkdir -p $(pack_get --prefix)/include"
pack_cmd "cp SRC/*.h $(pack_get --prefix)/include"

