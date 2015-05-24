# The good thing about scalapack is that it is a static
# library
# Hence any linking to scalapack will require an mpi compliant
# linking.
add_package --package scalapack http://www.student.dtu.dk/~nicpa/packages/scalapack-200.tar.gz

pack_set -s $IS_MODULE
pack_set --install-query $(pack_get --LD)/libscalapack.a

pack_set --module-requirement mpi

# Prepare the make file
tmp="sed -i -e"
file=SLmake.inc
pack_set --command "cp $file.example $file"
pack_set --command "$tmp 's/FC[[:space:]]*=.*/FC = $MPIF90/g' $file"
pack_set --command "$tmp 's/CC[[:space:]]*=.*/CC = $MPICC/g' $file"
pack_set --command "$tmp 's/NOOPT[[:space:]]*=.*/NOOPT = -fPIC/g' $file"
pack_set --command "$tmp 's/FCFLAGS[[:space:]]*=.*/FCFLAGS = $FCFLAGS/g' $file"
pack_set --command "$tmp 's/CCFLAGS[[:space:]]*=.*/CCFLAGS = $CFLAGS/g' $file"
pack_set --command "$tmp 's/ARCH[[:space:]]*=.*/ARCH = $AR/g' $file"

tmp_lib=
if $(is_c intel) && ! $(is_host eris) ; then
    tmp_lib="-lgfortran"
fi

pack_set --command "$tmp 's?BLASLIB[[:space:]]*=.*?BLASLIB = $tmp_lib $(list --LD-rp blas) -lblas?g' $file"
fi
pack_set --command "$tmp 's|^LAPACKLIB[[:space:]]*=.*|LAPACKLIB = $(list --LD-rp blas) -llapack|g' $file"

pack_set --command "make $(get_make_parallel)"

pack_set --command "mkdir -p $(pack_get --LD)/"
pack_set --command "cp libscalapack.a $(pack_get --LD)/"

