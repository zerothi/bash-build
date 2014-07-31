# The good thing about scalapack is that it is a static
# library
# Hence any linking to scalapack will require an openmpi compliant
# linking.

for bl in blas atlas openblas ; do

add_package --package scalapack-$bl http://www.netlib.org/scalapack/scalapack-2.0.2.tgz

pack_set --install-query $(pack_get --install-prefix $bl)/lib/libscalapack.a

pack_set --module-requirement openmpi

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
if $(is_c intel) ; then
    tmp_lib="-lgfortran"
fi

if [ $bl == "blas" ]; then
pack_set --command "$tmp 's?BLASLIB[[:space:]]*=.*?BLASLIB = $tmp_lib $(list --Wlrpath --LDFLAGS $bl) -lblas?g' $file"
elif [ $bl == "atlas" ]; then
pack_set --command "$tmp 's?BLASLIB[[:space:]]*=.*?BLASLIB = $tmp_lib $(list --Wlrpath --LDFLAGS $bl) -lf77blas -lcblas -latlas?g' $file"
elif [ $bl == "openblas" ]; then
pack_set --command "$tmp 's?BLASLIB[[:space:]]*=.*?BLASLIB = $tmp_lib $(list --Wlrpath --LDFLAGS $bl) -lopenblas?g' $file"
fi
pack_set --command "$tmp 's|^LAPACKLIB[[:space:]]*=.*|LAPACKLIB = $(list --LDFLAGS --Wlrpath $bl) -llapack|g' $file"

pack_set --command "make $(get_make_parallel)"

pack_set --command "mkdir -p $(pack_get --install-prefix $bl)/lib/"
pack_set --command "cp libscalapack.a $(pack_get --install-prefix $bl)/lib/"

done
