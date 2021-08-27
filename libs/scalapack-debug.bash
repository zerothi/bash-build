# The good thing about scalapack is that it is a static
# library
# Hence any linking to scalapack will require an mpi compliant
# linking.
v=2.1.0
add_package --build debug --package scalapack-debug \
	    --archive scalapack-$v.tar.gz \
	    https://github.com/Reference-ScaLAPACK/scalapack/archive/v$v.tar.gz

pack_set -s $IS_MODULE
pack_set --install-query $(pack_get --LD)/libscalapack.a
pack_set -lib -lscalapack

pack_set --module-requirement mpi

_fcflags=${FCFLAGS//-fbounds-check/}
_fcflags=${_fcflags//-fcheck=all/}
_cflags=${CFLAGS//-fbounds-check/}
_cflags=${_cflags//-fcheck=all/}

# Prepare the make file
tmp="sed -i -e"
file=SLmake.inc
pack_cmd "cp $file.example $file"
pack_cmd "$tmp 's;FC[[:space:]]*=.*;FC = $MPIF90;g' $file"
pack_cmd "$tmp 's;CC[[:space:]]*=.*;CC = $MPICC;g' $file"
pack_cmd "$tmp 's;NOOPT[[:space:]]*=.*;NOOPT = -fPIC;g' $file"
pack_cmd "$tmp 's;FCFLAGS[[:space:]]*=.*;FCFLAGS = $_fcflags;g' $file"
pack_cmd "$tmp 's;CCFLAGS[[:space:]]*=.*;CCFLAGS = $_cflags;g' $file"
pack_cmd "$tmp 's;ARCH[[:space:]]*=.*;ARCH = $AR;g' $file"

tmp_lib=
if $(is_c intel) ; then
    tmp_lib="-lgfortran"
fi

pack_cmd "$tmp 's?BLASLIB[[:space:]]*=.*?BLASLIB = $tmp_lib $(list --LD-rp blas) -lblas?g' $file"
pack_cmd "$tmp 's|^LAPACKLIB[[:space:]]*=.*|LAPACKLIB = $(list --LD-rp lapack) -llapack|g' $file"

pack_cmd "make $(get_make_parallel)"

pack_cmd "cd TESTING"
pack_cmd 'for x in x* ; do echo "RUNNING: $x" >> scalapack.test ; mpiexec -np $NPROCS ./$x >> scalapack.test ; echo "" >> scalapack.test ; done'
pack_store scalapack.test
pack_cmd "cd .."

pack_cmd "mkdir -p $(pack_get --LD)/"
pack_cmd "cp libscalapack.a $(pack_get --LD)/"
# simply to force it to exist
pack_cmd "mkdir -p $(pack_get --prefix)/include"
