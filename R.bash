v=3.5.2
add_package --alias R --package R \
	    https://cran.r-project.org/src/base/R-3/R-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set $(list --prefix '--mod-req ' readline)
pack_set --install-query $(pack_get --prefix)/bin/R

tmp=
if $(is_c intel) ; then

    tmp="$tmp BLAS_LIBS='$MKL_LIB -mkl=parallel -fp-model precise $FLAG_OMP'"
    tmp="$tmp LAPACK_LIBS='$MKL_LIB -mkl=parallel -fp-model precise $FLAG_OMP'"
elif $(is_c gnu) ; then
    
    la=$(pack_choice -i linalg)
    pack_set --module-requirement $la

    tmp="$tmp BLAS_LIBS='-L$(pack_get --LD $la) -Wl,-rpath=$(pack_get --LD $la) $(pack_get -lib[omp] $la)'"
    tmp="$tmp LAPACK_LIBS='-L$(pack_get --LD $la) -Wl,-rpath=$(pack_get --LD $la) $(pack_get -lib[omp] $la)'"

fi

pack_cmd "../configure CFLAGS='$CFLAGS $FLAG_OMP' $tmp" \
	 "--enable-R-shlib" \
	 "--with-blas --with-lapack" \
	 "--enable-lto" \
	 "--with-readline" \
	 "--prefix=$(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check-all > R.test 2>&1"
pack_cmd "make install"
pack_cmd "make install-tests"
pack_store R.test

# Install directory for intrinsic packages
pack_cmd "mkdir -p $(pack_get -prefix)/library"

# Needed as it is not source_pack
pack_install

create_module \
    --module-path $(build_get --module-path)-apps \
    -n $(pack_get --alias).$(pack_get --version) \
    -W "Loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement)) \
    -L $(pack_get --alias) 


# Install all relevant python packages

# The lookup name in the list for version number etc...
set_parent $(pack_get --alias)[$(pack_get --version)]
set_parent_exec $(pack_get --prefix)/bin/R

# Install all R packages
source R-install.bash
clear_parent

# Initialize the module read path
old_path=$(build_get --module-path)
build_set --module-path $old_path-apps

# Create common modules
source R/R-mods.bash

build_set --module-path $old_path
