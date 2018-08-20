add_package --package hotbit-dev --version 0 \
	    https://github.com/pekkosk/hotbit.git

pack_set -s $IS_MODULE

pack_set --module-opt "--lua-family hotbit"

pack_set --install-query $(pack_get --prefix)/bin/hotbit

pack_set --module-requirement ase

# Check for Intel MKL or not
file=customize.py
pack_cmd "echo '#' > $file"

if $(is_c intel) ; then
    pack_cmd "sed -i '1 a\
libraries = \"mkl_lapack95_lp64 mkl_blas95_lp64\".split()\n\
extra_link = [\"$MKL_LIB\",\"-mkl=sequential\"]\n' $file"

elif $(is_c gnu) ; then
    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la

    tmp="$(pack_get -lib[omp] $la)"
    # Remove -l in front of libraries
    tmp=${tmp//-l/}
    tmp_ld="$(list -c 'pack_get -LD' +$la)"
    pack_cmd "sed -i '1 a\
libs = []\n\
libraries = \"lapack $tmp gfortran\".split()\n\
lib_dirs = \"$tmp_ld\".split()\n' $file"

    unset tmp
    unset tmp_ld
fi

pack_cmd "$(get_parent_exec) setup.py build --customize"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"

pack_cmd "mkdir -p $(pack_get --prefix)/bin"
pack_cmd "cd $(pack_get --prefix)/bin"
pack_cmd "ln -fs ../hotbit"

pack_set --module-opt "--set-ENV HOTBIT_DIR=$(pack_get --prefix)"
pack_set --module-opt "--set-ENV HOTBIT_PARAMETERS=$(pack_get --prefix)/param"
