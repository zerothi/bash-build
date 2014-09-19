# Then install BLAS
add_package \
    --package blas \
    --directory BLAS \
    http://www.netlib.org/blas/blas.tgz

pack_set_file_version

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$(get_c)

# Required as the version has just been set
pack_set --install-query $(pack_get --library-path)/libblas.a

# Prepare the make file
tmp="sed -i -e"
pack_set --command "$tmp 's/FORTRAN[[:space:]]*=.*/FORTRAN = $FC/g' make.inc"
pack_set --command "$tmp 's/ARCH[[:space:]]*=.*/ARCH = $AR/g' make.inc"
pack_set --command "$tmp 's/OPTS[[:space:]]*=.*/OPTS = $FCFLAGS/g' make.inc"
pack_set --command "$tmp 's/LOADOPTS[[:space:]]*=.*/LOADOPTS = $FCFLAGS/g' make.inc"
pack_set --command "$tmp 's/_LINUX//g' make.inc"

# Make commands
pack_set --command "make $(get_make_parallel) all"

pack_set --command "mkdir -p $(pack_get --library-path)/"
pack_set --command "cp blas.a $(pack_get --library-path)/libblas.a"

