v=6.4.3
add_package \
    -package vasp \
    -directory vasp.$v \
    -version $v \
    http://www.student.dtu.dk/~nicpa/packages/vasp.$v.tgz

pack_set -host-reject zeroth

pack_set -module-requirement mpi
pack_set -module-requirement fftw
v_w90=3
pack_set -module-requirement wannier90[$v_w90]
pack_set -module-requirement hdf5[1.14.5]
#pack_set -module-requirement elpa

pack_set -module-opt "-lua-family vasp"

pack_set -install-query "$(pack_get -prefix)/bin/vasp_ncl_is2x"

file=makefile.include

# Start by downloading patches...


# Check for Intel MKL or not
if $(is_c intel) ; then

    pack_cmd "cp arch/makefile.include.intel_omp $file"

    pack_cmd "sed -i -e 's/blacs_intelmpi_/blacs_openmpi_/;\
s:^MKLROOT.*:MKLROOT = $MKLROOT:' $file"

elif $(is_c gnu) ; then

    pack_set -module-requirement scalapack
    
    pack_cmd "cp arch/makefile.include.gnu_omp $file"

    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    pack_cmd "sed -i -e 's:^SCALAPACK_ROOT.*:SCALAPACK_ROOT=$(pack_get -prefix scalapack):' $file"
    pack_cmd "sed -i '$ a\
LLIBS += ${RPATH_LINE}$(pack_get -L scalapack)' $file"
    pack_cmd "sed -i -e 's:^\(BLASPACK\).*:\1= $(list -LD-rp +$la) $(pack_get -lib[omp] $la):' $file"
    pack_cmd "sed -i -e '/^OPENBLAS_ROOT/d' $file"

else
    do_err "VASP" "Unknown compiler: $(get_c)"
fi

# The cache size is determined from the L1 cache (E5-2650 have ~64KB
# Replace stuff that we want to change
# However, it has been investigated that a CACHE_SIZE of ~ 5000 is good for this
# L1 size.
pack_cmd "sed -i -e 's/CACHE_SIZE=4000/CACHE_SIZE=6000/;\
s/MPI_BLOCK=8000/MPI_BLOCK=60000/;\
s:^FFTW_ROOT.*:FFTW_ROOT = $(pack_get -prefix fftw)\nLLIBS+= $(list -LD-rp fftw):;\
s:^OFLAG .*:OFLAG = \$(FFLAGS):;\
s:^FFLAGS .*:FFLAGS = $FFLAGS $FFLAGS_OMP:;\
' $file"

# For all compilations we want to add Wannier90 + HDF5 support
pack_cmd "sed -i '$ a\
ELPA_ROOT = $(pack_get -prefix elpa)\n\
INCS += $(list -INCDIRS wannier90[$v_w90] hdf5[1.14.5]) \n\
LLIBS := -lwannier -lfftw3 -lfftw3_omp -lhdf5_fortran -lhdf5 \$(LLIBS)\n\
LLIBS := $(list -LD-rp wannier90[$v_w90] hdf5[1.14.5]) \$(LLIBS)\n\
CPP_OPTIONS += -DVASP_HDF5 -DVASP2WANNIER90\n' $file"


###################### Prepare the TST code ##########################

# old link: http://theory.cm.utexas.edu/vtsttools/code/vtstcode.tar.gz"
o_code=$(pwd_archives)/$(pack_get -package)-$(pack_get -version)-tst-code-199.tgz
dwn_file https://theory.cm.utexas.edu/code/vtstcode-199.tgz $o_code
# Install vtst scripts
# old link: http://theory.cm.utexas.edu/vtsttools/code/vtstscripts.tar.gz"
o_scripts=$(pwd_archives)/$(pack_get -package)-$(pack_get -version)-tst-scripts.tgz
dwn_file https://theory.cm.utexas.edu/code/vtstscripts.tgz $o_scripts


# Create the make command
function compile_ispin {
    # ISPIN_SELECT
    local i=$1 ; shift
    # Name of executable
    local exe=$1 ; shift
    pack_cmd "sed -i -e 's/ISPIN_SELECT[ ]*=[ ]*[0-2]/ISPIN_SELECT=$i/' src/pardens.F"
    pack_cmd "make all"
    # std has to be the final one
    for e in gam ncl std
    do
	pack_cmd "cp bin/vasp_$e $(pack_get -prefix)/bin/${exe}_${e}_is$i"
	if [[ $i -eq 0 ]]; then
	    pack_cmd "pushd $(pack_get -prefix)/bin"
	    pack_cmd "ln -fs ${exe}_${e}_is0 ${exe}_${e}"
	    pack_cmd "popd"
	fi
    done
    if [[ $i -eq 0 ]]; then
	pack_cmd "pushd $(pack_get -prefix)/bin"
	pack_cmd "ln -fs ${exe}_std_is0 ${exe}"
	pack_cmd "popd"
    fi
    pack_cmd "make veryclean"
}

# Prepare the installation directory
pack_cmd "mkdir -p $(pack_get -prefix)/bin"
pack_store $file

# Make commands
for i in 0 1 2 ; do
    compile_ispin $i vasp
done



###################### Prepare the TST code ##########################
if [ 0 -eq 1 ]; then
pack_cmd "tar xfz $o_code"
pack_cmd "cp -r vtstcode-*/vtstcode6.4/* ./src/"

pack_cmd "pushd src"

# Install module compilations...
pack_cmd "sed -i -e 's:\(CHAIN_FORCE[^\&]*\):\1TSIF, :i' main.F"
pack_cmd "sed -i -e 's:IF[[:space:]]*(LCHAIN) CALL chain_init:CALL chain_init:' main.F"
pack_cmd "sed -s -i -e 's:[[:space:]]*\(\#[end]*if\):\1:i' chain.F"
pack_cmd "sed -i -e 's:\(chain.o\):bfgs.o dimer.o dynmat.o instanton.o lbfgs.o sd.o cg.o bbm.o fire.o lanczos.o neb.o qm.o pyamff_fortran/*.o ml_pyamff.o opt.o \1 :' .objects"
pack_cmd "sed -i -e 's:^LIB=\(.*\):LIB=\1 pyamff_fortran:' makefile"

pack_cmd "popd"

pack_cmd "tar xfz $o_scripts"
pack_cmd "cp -r vtstscripts-*/* $(pack_get -prefix)/bin/"

######################   end the TST code   ##########################

# Make commands
for i in 0 1 2 ; do
    compile_ispin $i vasp_tst
done
fi

unset compile_ispin

# Ensure that the group is correctly set
tmp="$(pack_get -prefix)/bin"
if $(is_host n-) ; then
    pack_cmd "chmod o-rwx $tmp/vasp*"
    pack_cmd "chgrp nanotech $tmp/vasp*"
elif $(is_host surt muspel slid a0 b0 c0 d0 g0 m0 n0 q0 p0 a1 b1 c1 d1 g1 m1 n1 q1 p1) ; then
    pack_cmd "chmod o-rwx $tmp/vasp*"
    pack_cmd "chgrp vasp $tmp/vasp*"
elif $(is_host nano pico femto atto) ; then
    pack_cmd "chmod o-rwx $tmp/vasp*"
    pack_cmd "chgrp Theory-VASP $tmp/vasp*"
fi


