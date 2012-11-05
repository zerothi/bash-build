# Then install Atlas
add_package http://downloads.sourceforge.net/project/math-atlas/Stable/3.10.0/atlas3.10.0.tar.bz2
pack_set --directory ATLAS

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
