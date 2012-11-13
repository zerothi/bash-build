# Then install BLAS
add_package http://www.netlib.org/blas/blas.tgz

pack_set_file_version

pack_set --directory BLAS
pack_set --alias blas

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

# Required as the version has just been set
pack_set --prefix-module $(pack_get --alias)/$(pack_get --version)/$(get_c)
pack_set --install-query $(pack_get --install-prefix)/lib/libblas.a

# Prepare the make file
tmp="sed -i -e"
pack_set --command "$tmp 's/FORTRAN[[:space:]]*=.*/FORTRAN = $FC/g' make.inc"
pack_set --command "$tmp 's/ARCH[[:space:]]*=.*/ARCH = $AR/g' make.inc"
pack_set --command "$tmp 's/OPTS[[:space:]]*=.*/OPTS = $FCFLAGS/g' make.inc"
pack_set --command "$tmp 's/LOADOPTS[[:space:]]*=.*/LOADOPTS = $FCFLAGS/g' make.inc"
pack_set --command "$tmp 's/_LINUX//g' make.inc"

# Make commands
pack_set --command "make $(get_make_parallel) all"

pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/"
pack_set --command "cp blas.a $(pack_get --install-prefix)/lib/libblas.a"

pack_install