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

if $(is_c intel) ; then
    pack_set --command "$tmp 's|BLASLIB[[:space:]]*=.*|BLASLIB = $MKL_LIB -mkl=sequential -lmkl_blas95_lp64|g' $file"
    pack_set --command "$tmp 's|^LAPACKLIB[[:space:]]*=.*|LAPACKLIB = -mkl=sequential -lmkl_lapack95_lp64|g' $file"

else
if [ $(pack_installed atlas) -eq 1 ]; then
    pack_set --command "module load" \
	--command-flag "$(pack_get --module-requirement atlas)" \
	--command-flag "$(pack_get --module-name atlas)"
    pack_set --command "$tmp 's|BLASLIB[[:space:]]*=.*|BLASLIB = $(list --LDFLAGS --Wlrpath atlas) -lf77blas -lcblas -latlas|g' $file"
    # No matter the source we need gfortran as ATLAS is compiled with GCC (we should really look into this)
    pack_set --command "$tmp 's|^LAPACKLIB[[:space:]]*=.*|LAPACKLIB = $(list --LDFLAGS --Wlrpath atlas) -llapack_atlas|g' $file"

else
    pack_set --command "module load" \
	--command-flag "$(pack_get --module-requirement blas lapack)" \
	--command-flag "$(pack_get --module-name blas lapack)"
    pack_set --command "$tmp 's|BLASLIB[[:space:]]*=.*|BLASLIB = $(list --LDFLAGS --Wlrpath blas) -lblas|g' $file"
    
    pack_set --command "$tmp 's|^LAPACKLIB[[:space:]]*=.*|LAPACKLIB = $(list --LDFLAGS --Wlrpath lapack) -llapack|g' $file"
    
fi
fi


# Make commands
pack_set --command "make $(get_make_parallel)"

pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/"
pack_set --command "cp libscalapack.a $(pack_get --install-prefix)/lib/"

if $(is_c intel) ; then
    echo "empty" > /dev/null
else
if [ $(pack_installed atlas) -eq 1 ]; then
    pack_set --command "module unload" \
	--command-flag "$(pack_get --module-name atlas)" \
	--command-flag "$(pack_get --module-requirement atlas)"
else
    pack_set --command "module unload" \
	--command-flag "$(pack_get --module-name lapack blas)" \
	--command-flag "$(pack_get --module-requirement lapack blas)"
fi
fi

