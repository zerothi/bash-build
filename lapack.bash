# Then install LAPACK
add_package http://www.netlib.org/lapack/lapack-3.4.2.tgz

pack_set -s $MAKE_PARALLEL \
    -s $IS_MODULE

pack_set --install-prefix \
    $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --install-query \
    $(pack_get --install-prefix)/lib/libblas.a

# Prepare the make file
pack_set --command "sed -e 's/OPTS[[:space:]]*=/OPTS = $FCFLAGS/g' make.inc"
pack_set --command "sed -e 's/LOADOPTS[[:space:]]*=/LOADOPTS = $FCFLAGS/g' make.inc"
pack_set --command "sed -e 's/_LINUX//g' make.inc"

# Make commands
pack_set --command "make $(get_make_parallel) all"

pack_set --command "mkdir -p $(pack_get --prefix)/lib/"
pack_set --command "cp blas.a $(pack_get --prefix)/lib/"
