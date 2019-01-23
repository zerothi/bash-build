add_package http://downloads.sourceforge.net/project/elk/elk-5.2.14.tgz

pack_set --host-reject ntch --host-reject zeroth

pack_set --install-query $(pack_get --prefix)/bin/elk

pack_set --module-requirement mpi \
    --module-requirement libxc \
    --module-requirement fftw

# Add the lua family
pack_set --module-opt "--lua-family elk"

if [[ -z "$FLAG_OMP" ]]; then
    doerr elk "Can not find the OpenMP flag (set FLAG_OMP in source)"
fi

tmp=
if $(is_c intel) ; then
    tmp=" $MKL_LIB -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -mkl=parallel"
fi

file=make.inc
# Prepare the compilation arch.make
pack_cmd "echo '# Compilation $(pack_get --version) on $(get_c)' > $file"
pack_cmd "sed -i '1 a\
MAKE = make\n\
F90 = $MPIF90\n\
F90_OPTS = $FCFLAGS $FLAG_OMP $tmp \n\
F77 = $MPIF77\n\
F77_OPTS = $FCFLAGS $FLAG_OMP $tmp \n\
AR = $AR \n\
LIB_libxc = $(list --LD-rp mpi libxc) -lxcf03 -lxc\n\
SRC_libxc = libxc_funcs.f90 libxc.f90 libxcifc.f90\n\
LIB_FFT = $(list --LD-rp fftw) -lfftw3\n\
SRC_FFT = zfftifc_fftw.f90\n\
' $file"

tmp=
# Check for Intel MKL or not
if $(is_c intel) ; then
    pack_cmd "sed -i '1 a\
LIB_LPK = $tmp\n\
' $file"

elif $(is_c gnu) ; then
    pack_set --module-requirement scalapack

    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    tmp="$(pack_get -lib[omp] $la)"

    pack_cmd "sed -i '1 a\
LIB_LPK = $(list --LD-rp $(pack_get --mod-req)) $tmp\n\
' $file"

else
    doerr "$(pack_get --package)" "Could not recognize the compiler: $(get_c)"

fi

pack_cmd "make $(get_make_parallel)"

pack_cmd "mkdir -p $(pack_get --prefix)/bin"
pack_cmd "cp src/protex src/elk $(pack_get --prefix)/bin/"
pack_cmd "cp src/spacegroup/spacegroup $(pack_get --prefix)/bin/"
pack_cmd "cp src/eos/eos $(pack_get --prefix)/bin/"
pack_cmd "cp utilities/blocks2columns/blocks2columns.py $(pack_get --prefix)/bin/"
pack_cmd "cp utilities/elk-bands/elk-bands $(pack_get --prefix)/bin/"
pack_cmd "cp utilities/elk-optics/elk-optics.py $(pack_get --prefix)/bin/"
pack_cmd "cp utilities/wien2k-elk/se.pl $(pack_get --prefix)/bin/"
pack_cmd "chmod a+x $(pack_get --prefix)/bin/*"

# Create the species input
pack_cmd "cp -rf species $(pack_get --prefix)/species"
pack_set --module-opt "--set-ENV ELK_SPECIES=$(pack_get --prefix)/species"
