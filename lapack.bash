# Then install LAPACK
add_package http://www.netlib.org/lapack/lapack-3.4.2.tgz

pack_set -s $MAKE_PARALLEL \
    -s $IS_MODULE

pack_set --install-prefix \
    $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --install-query \
    $(pack_get --install-prefix)/lib/liblapack.a

# Prepare the make file
pack_set --command "cp make.inc.example make.inc"
pack_set --command "sed -e 's/FORTRAN[[:space:]]*=.*/FORTRAN = $FC/g' make.inc"
pack_set --command "sed -e 's/OPTS[[:space:]]*=.*/OPTS = $FCFLAGS/g' make.inc"
pack_set --command "sed -e 's/NOOPT[[:space:]]*=.*/NOOPT = -fPIC/g' make.inc"
pack_set --command "sed -e 's/LOADER[[:space:]]*=.*/LOADER = $FC/g' make.inc"
pack_set --command "sed -e 's/LOADOPTS[[:space:]]*=.*/LOADOPTS = $FCFLAGS/g' make.inc"
pack_set --command "sed -e 's/_LINUX//g' make.inc"
pack_set --command "sed -e 's/_SUN4//g' make.inc"
pack_set --command "sed -e 's?BLASLIB[[:space:]]*=.*/BLASLIB = $(pack_get --prefix blas)/lib/libblas.a/g' make.inc"

# Make commands
pack_set --command "make $(get_make_parallel) all"

pack_set --command "mkdir -p $(pack_get --prefix)/lib/"
pack_set --command "cp liblapack.a $(pack_get --prefix)/lib/"
