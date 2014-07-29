# Then install ScaLAPACK
add_package http://www.netlib.org/scalapack/scalapack-2.0.2.tgz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libscalapack.a

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

if [ $(pack_installed atlas) -eq 1 ]; then
    pack_set --command "module load $(pack_get --module-load atlas)"
    pack_set --command "$tmp 's|BLASLIB[[:space:]]*=.*|BLASLIB = $tmp_lib $(list --LDFLAGS --Wlrpath atlas) -lf77blas -lcblas -latlas|g' $file"
    # No matter the source we need gfortran as ATLAS is compiled with GCC (we should really look into this)
    pack_set --command "$tmp 's|^LAPACKLIB[[:space:]]*=.*|LAPACKLIB = $(list --LDFLAGS --Wlrpath atlas) -llapack_atlas|g' $file"

else
    pack_set --command "module load $(pack_get --module-load lapack)"
    pack_set --command "$tmp 's|BLASLIB[[:space:]]*=.*|BLASLIB = $(list --LDFLAGS --Wlrpath blas) -lblas|g' $file"
    
    pack_set --command "$tmp 's|^LAPACKLIB[[:space:]]*=.*|LAPACKLIB = $(list --LDFLAGS --Wlrpath lapack) -llapack|g' $file"
    
fi

# Make commands
pack_set --command "make $(get_make_parallel)"

pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/"
pack_set --command "cp libscalapack.a $(pack_get --install-prefix)/lib/"

if [ $(pack_installed atlas) -eq 1 ]; then
    pack_set --command "module unload $(pack_get --module-load atlas)"
else
    pack_set --command "module unload $(pack_get --module-load lapack)"
fi

