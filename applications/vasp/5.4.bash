vv=5.4.1.24Jun15
vv=5.4.1.05Feb16
v=${vv%.*}
add_package \
    -package vasp \
    -directory vasp.$v \
    -version $v \
    http://www.student.dtu.dk/~nicpa/packages/vasp.$vv.tar.gz

pack_set -host-reject zeroth

pack_set -module-requirement mpi
pack_set -module-requirement fftw
pack_set -module-requirement wannier90

pack_set -module-opt "-lua-family vasp"

pack_set -install-query "$(pack_get -prefix)/bin/vasp_tst_ncl_is2"

file=makefile.include
pack_cmd "echo '# NPA' > $file"

# Start by downloading patches...
#### THESE APPLY TO 5.4.1.24Jun15
#p=5.4.1.08072015
#o=$(pwd_archives)/$(pack_get -package)-$(pack_get -version)-patch.$p.gz
#dwn_file http://cms.mpi.univie.ac.at/patches/patch.$p.gz $o
#pack_cmd "gunzip -c $o | patch -p0"
#p=5.4.1.27082015
#o=$(pwd_archives)/$(pack_get -package)-$(pack_get -version)-patch.$p.gz
#dwn_file http://cms.mpi.univie.ac.at/patches/patch.$p.gz $o
#pack_cmd "gunzip -c $o | patch -p1"
#p=5.4.1.06112015
#o=$(pwd_archives)/$(pack_get -package)-$(pack_get -version)-patch.$p.gz
#dwn_file http://cms.mpi.univie.ac.at/patches/patch.$p.gz $o
#pack_cmd "gunzip -c $o | patch -p0"
#### THESE APPLY TO 5.4.1.05Feb16
p=5.4.1.14032016
o=$(pwd_archives)/$(pack_get -package)-$(pack_get -version)-patch.$p.gz
dwn_file http://cms.mpi.univie.ac.at/patches/patch.$p.gz $o
pack_cmd "gunzip -c $o | patch -p0"
p=5.4.1.03082016
o=$(pwd_archives)/$(pack_get -package)-$(pack_get -version)-patch.$p.gz
dwn_file http://cms.mpi.univie.ac.at/patches/patch.$p.gz $o
pack_cmd "gunzip -c $o | patch -p0"

# Start with creating a template makefile.
# The cache size is determined from the L1 cache (E5-2650 have ~64KB
# However, it has been investigated that a CACHE_SIZE of ~ 5000 is good for this
# L1 size.
pack_cmd "sed -i '1 a\
CPP = cpp -E -P -C -nostdinc -traditional \$*\$(FUFFIX) >\$*\$(SUFFIX) \$(CPP_OPTIONS) \n\
CPP_OPTIONS  += -DVASP2WANNIER90\n\
CPP_OPTIONS  += -DMPI -DHOST=\\\\\"$(get_c)-$(pack_get -package mpi)\\\\\"\n\
CPP_OPTIONS  += -DIFC\n\
CPP_OPTIONS  += -DCACHE_SIZE=6000 -DMPI_BLOCK=60000\n\
CPP_OPTIONS  += -DDGEGV=DGGEV\n\
CPP_OPTIONS  += -DscaLAPACK -Duse_collective\n\
CPP_OPTIONS  += -DnoAugXCmeta -Duse_bse_te\n\
CPP_OPTIONS  += -Duse_shmem -Dtbdyn\n\
FC   = $MPIFC $FLAG_OMP\n\
FCL  = \$(FC) \n\
#PLACEHOLDER#\n\
FFLAGS = $FCFLAGS \n\
OFLAG  = \$(FFLAGS) \n\
OFLAG_IN  = \$(OFLAG) \n\
DEBUG  = -O0 \n\
OBJECTS = fftmpiw.o fftmpi_map.o fftw3d.o fft3dlib.o \n\
WANNIER_PATH = $(pack_get -LD wannier90)\n\
WANNIER      = -L\$(WANNIER_PATH) -Wl,-rpath=\$(WANNIER_PATH)\n\
INCS += -I$(pack_get -prefix fftw)/include\n\
FFTW_PATH = $(pack_get -LD fftw)\n\
FFTW      = -L\$(FFTW_PATH) -Wl,-rpath=\$(FFTW_PATH)\n\
LLIBS = \$(WANNIER) -lwannier \$(FFTW) -lfftw3 \n\
' $file"
    
# Check for Intel MKL or not
if $(is_c intel) ; then

    pack_cmd "sed -i '$ a\
FREE = -free -names lowercase\n\
FFLAGS += -assume byterecl \n\
CPP_OPTIONS += -Davoidalloc -DPGF90 \n\
# Setup MKL and libs\n\
MKL_PATH = $MKL_PATH\n\
MKL_LD =  -L\$(MKL_PATH)/lib/intel64 -Wl,-rpath=\$(MKL_PATH)/lib/intel64 \n\
BLAS = \$(MKL_LD) -lmkl_blas95_lp64 \n\
LAPACK = \$(MKL_LD) -lmkl_lapack95_lp64 \n\
SCA = \$(MKL_LD) -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 \n\
LLIBS += -mkl=parallel $(list -LD-rp mpi) \$(SCA) \$(LAPACK) \$(BLAS)\n' $file"

elif $(is_c gnu) ; then

    pack_set -module-requirement scalapack

    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    pack_cmd "sed -i '$ a\
FREE = -ffree-form -ffree-line-length-none\n\
SCA = $(list -LD-rp scalapack) -lscalapack\n\
LAPACK = $(list -LD-rp +$la) $(pack_get -lib[omp] $la)\n\
BLAS = \$(LAPACK)\n\
LLIBS += \$(SCA) \$(LAPACK) \$(BLAS)\n' $file"

else
    do_err "VASP" "Unknown compiler: $(get_c)"
fi


pack_cmd "sed -i '$ a\
OBJECTS_O1 += fftmpiw.o fftmpi_map.o fftw3d.o fft3dlib.o \n\
CPP_LIB = \$(CPP)\n\
FC_LIB = \$(FC)\n\
CC_LIB = $CC \n\
CFLAGS_LIB = $CFLAGS \n\
FFLAGS_LIB = \$(FFLAGS)\n\
FREE_LIB = \$(FREE)\n\
OBJECTS_LIB = linpack_double.o getshmem.o\n\
SRCDIR = ../../src\n\
BINDIR = ../../bin\n' $file"


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

# Make commands
for i in 0 1 2 ; do
    compile_ispin $i vasp
done


###################### Prepare the TST code ##########################

# old link: http://theory.cm.utexas.edu/vtsttools/code/vtstcode.tar.gz"
pack_cmd "wget http://theory.cm.utexas.edu/code/vtstcode-180.tgz"
pack_cmd "tar xfz vtstcode-180.tgz"
pack_cmd "cp -r vtstcode-*/* ./src/"

pack_cmd "pushd src"

# Bugfix for code
pack_cmd "sed -i -e 's:<NBAS>:10000:gi' bbm.F"

# Install module compilations...
pack_cmd "sed -i -e 's:\(CHAIN_FORCE[^\&]*\):\1TSIF, :i' main.F"
pack_cmd "sed -s -i -e 's:[[:space:]]*\(\#[end]*if\):\1:i' chain.F dimer.F"
pack_cmd "sed -i -e 's:\(chain.o\):bfgs.o dynmat.o instanton.o lbfgs.o sd.o cg.o dimer.o bbm.o fire.o lanczos.o neb.o qm.o opt.o \1 :' .objects"

pack_cmd "popd"

# Install vtst scripts
# old link: http://theory.cm.utexas.edu/vtsttools/code/vtstscripts.tar.gz"
pack_cmd "wget http://theory.cm.utexas.edu/code/vtstscripts.tgz"
pack_cmd "tar xfz vtstscripts.tgz"
pack_cmd "cp -r vtstscripts-*/* $(pack_get -prefix)/bin/"

######################   end the TST code   ##########################

# Make commands
for i in 0 1 2 ; do
    compile_ispin $i vasp_tst
done

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


