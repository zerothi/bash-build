# Then install BLAS
add_package \
    --package blas \
    --directory BLAS* \
    http://www.netlib.org/blas/blas.tgz

pack_set_file_version

pack_set -s $MAKE_PARALLEL -s $IS_MODULE
pack_set --lib[omp] -lblas
pack_set --lib[pt] -lblas

pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$(get_c)

# Required as the version has just been set
pack_set --install-query $(pack_get --LD)/libblas.a

# Prepare the make file
tmp="sed -i -e"
pack_cmd "$tmp 's;FORTRAN[[:space:]]*=.*;FORTRAN = $FC;g' make.inc"
pack_cmd "$tmp 's;ARCH[[:space:]]*=.*;ARCH = $AR;g' make.inc"
pack_cmd "$tmp 's;OPTS[[:space:]]*=.*;OPTS = $FCFLAGS;g' make.inc"
pack_cmd "$tmp 's;LOADOPTS[[:space:]]*=.*;LOADOPTS = $FCFLAGS;g' make.inc"
pack_cmd "$tmp 's;_LINUX;;g' make.inc"

# Make commands
pack_cmd "make $(get_make_parallel) all"

pack_cmd "mkdir -p $(pack_get --LD)/"
pack_cmd "cp blas.a $(pack_get --LD)/libblas.a"

#pack_set --module-opt "-echo \"Netlib BLAS is used, expect poor performance.\""
#pack_set --module-opt "-echo 'Consider using another module with othel BLAS implementation.'"
