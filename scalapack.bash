# Then install ScaLAPACK
module purge
module load $(pack_get --module-name openmpi) $(pack_get --module-name blas) $(pack_get --module-name lapack)
add_package http://www.netlib.org/scalapack/scalapack-2.0.2.tgz

pack_set -s $IS_MODULE

pack_set --install-prefix \
    $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --install-query \
    $(pack_get --install-prefix)/lib/libscalapack.a

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
pack_set --command "$tmp 's|BLASLIB[[:space:]]*=.*|BLASLIB = $(pack_get --install-prefix blas)/lib/libblas.a|g' SLmake.inc"
pack_set --command "$tmp 's|^LAPACKLIB[[:space:]]*=.*|LAPACKLIB = $(pack_get --install-prefix lapack)/lib/liblapack.a|g' SLmake.inc"


# Make commands
pack_set --command "make $(get_make_parallel)"

pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/"
pack_set --command "cp libscalapack.a $(pack_get --install-prefix)/lib/"


pack_install