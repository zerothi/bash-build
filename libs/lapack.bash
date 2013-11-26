# Then install LAPACK
add_package http://www.netlib.org/lapack/lapack-3.5.0.tgz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/liblapack.a

# Prepare the make file
tmp="sed -i -e"
pack_set --command "cp make.inc.example make.inc"
pack_set --command "$tmp 's/FORTRAN[[:space:]]*=.*/FORTRAN = $FC/g' make.inc"
pack_set --command "$tmp 's/CC[[:space:]]*=.*/CC = $CC/g' make.inc"
pack_set --command "$tmp 's/ARCH[[:space:]]*=.*/ARCH = $AR/g' make.inc"
pack_set --command "$tmp 's/OPTS[[:space:]]*=.*/OPTS = $FCFLAGS/g' make.inc"
pack_set --command "$tmp 's/CFLAGS[[:space:]]*=.*/CFLAGS = $CFLAGS/g' make.inc"
pack_set --command "$tmp 's/NOOPT[[:space:]]*=.*/NOOPT = -fPIC/g' make.inc"
pack_set --command "$tmp 's/LOADER[[:space:]]*=.*/LOADER = $FC/g' make.inc"
pack_set --command "$tmp 's/LOADOPTS[[:space:]]*=.*/LOADOPTS = $FCFLAGS/g' make.inc"
pack_set --command "$tmp 's/TIMER[[:space:]]*=.*/TIMER = INT_CPU_TIME/g' make.inc"
pack_set --command "$tmp 's/_LINUX//g' make.inc"
pack_set --command "$tmp 's/_SUN4//g' make.inc"
pack_set --command "$tmp 's?BLASLIB[[:space:]]*=.*?BLASLIB = $(pack_get --install-prefix blas)/lib/libblas.a?g' make.inc"

# Make commands
pack_set --command "make $(get_make_parallel) lapacklib lapackelib"

pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/"
pack_set --command "cp liblapack.a liblapacke.a $(pack_get --install-prefix)/lib/"
pack_set --command "mkdir -p $(pack_get --install-prefix)/include/"
pack_set --command "cp lapacke/include/*.h $(pack_get --install-prefix)/include/"

