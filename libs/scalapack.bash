# Then install ScaLAPACK
add_package http://www.netlib.org/scalapack/scalapack-2.0.2.tgz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libscalapack.a

pack_set --module-requirement openmpi

# Prepare the make file
tmp="sed -i -e"

pack_set --command "cp SLmake.inc.example SLmake.inc"
pack_set --command "$tmp 's/FC[[:space:]]*=.*/FC = $MPIF90/g' SLmake.inc"
pack_set --command "$tmp 's/CC[[:space:]]*=.*/CC = $MPICC/g' SLmake.inc"
pack_set --command "$tmp 's/NOOPT[[:space:]]*=.*/NOOPT = -fPIC/g' SLmake.inc"
pack_set --command "$tmp 's/FCFLAGS[[:space:]]*=.*/FCFLAGS = $FCFLAGS/g' SLmake.inc"
pack_set --command "$tmp 's/CCFLAGS[[:space:]]*=.*/CCFLAGS = $CFLAGS/g' SLmake.inc"
pack_set --command "$tmp 's/ARCH[[:space:]]*=.*/ARCH = $AR/g' SLmake.inc"

if [ $(pack_installed atlas) -eq 1 ]; then
    pack_set --command "module load" \
	--command-flag "$(pack_get --module-requirement atlas)" \
	--command-flag "$(pack_get --module-name atlas)"
    pack_set --command "$tmp 's|BLASLIB[[:space:]]*=.*|BLASLIB = $(list --LDFLAGS --Wlrpath atlas) -lf77blas -lcblas -latlas|g' SLmake.inc"
    pack_set --command "$tmp 's|^LAPACKLIB[[:space:]]*=.*|LAPACKLIB = $(list --LDFLAGS --Wlrpath atlas) -llapack_atlas|g' SLmake.inc"

else
    pack_set --command "module load" \
	--command-flag "$(pack_get --module-requirement blas lapack)" \
	--command-flag "$(pack_get --module-name blas lapack)"
    pack_set --command "$tmp 's|BLASLIB[[:space:]]*=.*|BLASLIB = $(list --LDFLAGS --Wlrpath blas) -lblas|g' SLmake.inc"
    
    pack_set --command "$tmp 's|^LAPACKLIB[[:space:]]*=.*|LAPACKLIB = $(list --LDFLAGS --Wlrpath lapack) -llapack|g' SLmake.inc"
    
fi


# Make commands
pack_set --command "make $(get_make_parallel)"

pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/"
pack_set --command "cp libscalapack.a $(pack_get --install-prefix)/lib/"

if [ $(pack_installed atlas) -eq 1 ]; then
    pack_set --command "module unload" \
	--command-flag "$(pack_get --module-name atlas)" \
	--command-flag "$(pack_get --module-requirement atlas)"
else
    pack_set --command "module unload" \
	--command-flag "$(pack_get --module-name lapack blas)" \
	--command-flag "$(pack_get --module-requirement lapack blas)"
fi
