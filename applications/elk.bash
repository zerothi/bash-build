add_package https://sourceforge.net/projects/elk/files/elk-8.7.10.tgz

pack_set -install-query $(pack_get -prefix)/bin/elk

pack_set -module-requirement mpi \
    -module-requirement libxc[5] \
    -module-requirement fftw
pack_set -module-requirement wannier90

# Add the lua family
pack_set -module-opt "-lua-family elk"

if [[ -z "$FLAG_OMP" ]]; then
    doerr elk "Can not find the OpenMP flag (set FLAG_OMP in source)"
fi

tmp=
if $(is_c intel) ; then
    tmp=" $MKL_LIB -lmkl_scalapack_lp64 -lmkl_blacs_intelmpi_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -qmkl=parallel"
fi


file=make.inc
# Prepare the compilation arch.make
pack_cmd "echo '# Compilation $(pack_get -version) on $(get_c)' > $file"
pack_cmd "sed -i '1 a\
SRC_MKL = mkl_stub.f90\n\
SRC_BLIS = blis_stub.f90\n\
SRC_OBLAS = oblas_stub.f90\n\
MAKE = make\n\
AR = $AR \n\
LIB_LIBXC = $(list -LD-rp mpi libxc[5]) $(pack_get -lib[f90] libxc[5])\n\
SRC_LIBXC = libxcf90.f90 libxcifc.f90\n\
LIB_FFT = $(list -LD-rp fftw) -lfftw3 -lfftw3f\n\
SRC_FFT = cfftifc_fftw.f90 zfftifc_fftw.f90\n\
LIB_W90 = $(list -LD-rp wannier90) -lwannier\n\
F90 = $MPIF90\n\
F90_OPTS = $FCFLAGS $FLAG_OMP $tmp $(list -INCDIRS libxc[5])\n\
' $file"

unset xc_v

tmp=
# Check for Intel MKL or not
if $(is_c intel) ; then
    pack_cmd "sed -i '$ a\
LIB_LPK = $tmp\n\
SRC_MKL = \n\
' $file"

elif $(is_c gnu) ; then
    pack_set -module-requirement scalapack

    la=lapack-$(pack_choice -i linalg)
    case $la in
	lapack-openblas)
	    pack_cmd "sed -i '$ aSRC_OBLAS = \n' $file"
	    ;;
	lapack-blis)
	    pack_cmd "sed -i '$ aSRC_BLIS = \n' $file"
	    ;;
	lapack-mkl)
	    pack_cmd "sed -i '$ aSRC_MKL = \n' $file"
	    ;;
    esac
    pack_set -module-requirement $la
    tmp="$(pack_get -lib[omp] $la)"

    pack_cmd "sed -i '$ a\
LIB_LPK = $(list -LD-rp $(pack_get -mod-req)) $tmp\n\
' $file"

else
    doerr "$(pack_get -package)" "Could not recognize the compiler: $(get_c)"

fi

pack_cmd "sed -i '$ a\
LIB_W90 += \$(LIB_LPK)\n\
F90_LIB = \$(LIB_FFT)\n\
' $file"

pack_cmd "cd src ; make libxcifc.o ; cd ../"
pack_cmd "make $(get_make_parallel)"

pack_cmd "mkdir -p $(pack_get -prefix)/bin"
pack_cmd "cp src/protex src/elk $(pack_get -prefix)/bin/"
pack_cmd "cp src/spacegroup/spacegroup $(pack_get -prefix)/bin/"
pack_cmd "cp src/eos/eos $(pack_get -prefix)/bin/"
pack_cmd "cp utilities/blocks2columns/blocks2columns.py $(pack_get -prefix)/bin/"
pack_cmd "cp utilities/elk-bands/elk-bands $(pack_get -prefix)/bin/"
pack_cmd "cp utilities/elk-optics/elk-optics.py $(pack_get -prefix)/bin/"
pack_cmd "cp utilities/wien2k-elk/se.pl $(pack_get -prefix)/bin/"
pack_cmd "chmod a+x $(pack_get -prefix)/bin/*"

# Create the species input
pack_cmd "cp -rf species $(pack_get -prefix)/species"
pack_set -module-opt "-set-ENV ELK_SPECIES=$(pack_get -prefix)/species"
