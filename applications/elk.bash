add_package https://sourceforge.net/projects/elk/files/elk-6.8.4.tgz

pack_set -install-query $(pack_get -prefix)/bin/elk

xc_v=5
pack_set -module-requirement mpi \
    -module-requirement libxc[$xc_v] \
    -module-requirement fftw
pack_set -module-requirement wannier90

# Add the lua family
pack_set -module-opt "-lua-family elk"

if [[ -z "$FLAG_OMP" ]]; then
    doerr elk "Can not find the OpenMP flag (set FLAG_OMP in source)"
fi

tmp=
if $(is_c intel) ; then
    tmp=" $MKL_LIB -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -mkl=parallel"
fi


file=make.inc
# Prepare the compilation arch.make
pack_cmd "echo '# Compilation $(pack_get -version) on $(get_c)' > $file"
pack_cmd "sed -i '1 a\
SRC_MKL = mkl_stub.f90\n\
SRC_BLIS = blis_stub.f90\n\
SRC_OBLAS = oblas_stub.f90\n\
MAKE = make\n\
F90 = $MPIF90\n\
F90_OPTS = $FCFLAGS $FLAG_OMP $tmp \n\
F77 = $MPIF77\n\
F77_OPTS = $FCFLAGS $FLAG_OMP $tmp \n\
AR = $AR \n\
LIB_libxc = $(list -LD-rp mpi libxc[$xc_v]) $(pack_get -lib[f90] libxc[$xc_v])\n\
SRC_libxc = libxcf90.f90 libxcifc.f90\n\
LIB_FFT = $(list -LD-rp fftw) -lfftw3\n\
SRC_FFT = zfftifc_fftw.f90\n\
LIB_W90 = $(list -LD-rp wannier90) -lwannier\n\
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
	openblas)
	    pack_cmd "sed -i '$ aSRC_OBLAS = \n' $file"
	    ;;
	blis)
	    pack_cmd "sed -i '$ aSRC_BLIS = \n' $file"
	    ;;
	mkl)
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
