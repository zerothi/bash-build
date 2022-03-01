rV=4.1
IrV=$rV.2
add_package -alias R -package R \
	    https://cran.r-project.org/src/base/R-${rV:0:1}/R-$IrV.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set $(list -prefix '-mod-req ' readline curl)
pack_set -install-query $(pack_get -prefix)/bin/R

# for openssl
pack_set -mod-req openssl
# for git2r
pack_set -mod-req libgit2
# for xml dependency
pack_set -mod-req libxml2
pack_set -mod-req pcre2

tmp=
if $(is_c intel) ; then

    tmp="$tmp BLAS_LIBS='$MKL_LIB -mkl=parallel $FLAG_OMP'"
    tmp="$tmp LAPACK_LIBS='$MKL_LIB -mkl=parallel $FLAG_OMP'"

else
    
    la=$(pack_choice -i linalg)
    pack_set -module-requirement $la

    tmp="$tmp BLAS_LIBS='-L$(pack_get -LD $la) -Wl,-rpath=$(pack_get -LD $la) $(pack_get -lib[omp] $la)'"
    tmp="$tmp LAPACK_LIBS='-L$(pack_get -LD $la) -Wl,-rpath=$(pack_get -LD $la) $(pack_get -lib[omp] $la)'"

fi

pack_cmd "../configure CFLAGS='$CFLAGS $FLAG_OMP' $tmp" \
	 "--enable-R-shlib --enable-R-static-lib" \
	 "--with-blas --with-lapack" \
	 --enable-pcre2 \
	 --enable-lto \
	 --with-readline \
	 "--prefix=$(pack_get -prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check-all > R.test 2>&1 || echo forced"
pack_cmd "make install"
pack_cmd "make install-tests"
pack_store R.test

# Install directory for intrinsic packages
pack_cmd "mkdir -p $(pack_get -prefix)/library"
# Ensure the library path is added
pack_cmd "[ -d $(pack_get -prefix)/lib64 ] && echo '# Custom R profile' > $(pack_get -prefix)/lib64/R/etc/Rprofile.site || echo '# Custom R profile' > $(pack_get -prefix)/lib/R/etc/Rprofile.site"
pack_cmd "[ -d $(pack_get -prefix)/lib64 ] && echo '#' >> $(pack_get -prefix)/lib64/R/etc/Rprofile.site || echo '#' >> $(pack_get -prefix)/lib/R/etc/Rprofile.site"
pack_cmd "[ -d $(pack_get -prefix)/lib64 ] && echo '# Custom location of libraries (without using env-vars)' >> $(pack_get -prefix)/lib64/R/etc/Rprofile.site || echo '# Custom location of libraries (without using env-vars)' >> $(pack_get -prefix)/lib/R/etc/Rprofile.site"
pack_cmd "[ -d $(pack_get -prefix)/lib64 ] && echo 'invisible(.libPaths( c(\"$(pack_get -prefix)/library\", .libPaths()) ))' >> $(pack_get -prefix)/lib64/R/etc/Rprofile.site || echo 'invisible(.libPaths( c(\"$(pack_get -prefix)/library\", .libPaths()) ))' >> $(pack_get -prefix)/lib/R/etc/Rprofile.site"


# Create a new build with this module
new_build -name _internal-R$IrV \
    -module-path $(build_get -module-path)-R/$IrV \
    -source $(build_get -source) \
    $(list -prefix "-default-module " $(pack_get -mod-req-module) R[$IrV]) \
    -installation-path $(dirname $(pack_get -prefix $(get_parent)))/packages \
    -build-module-path "-package -version" \
    -build-installation-path "$IrV -package -version" \
    -build-path $(build_get -build-path)/r-$rV

mkdir -p $(build_get -module-path[_internal-R$IrV])-apps
build_set -default-setting[_internal-R$IrV] $(build_get -default-setting)


# Now add options to ensure that loading this module will enable the path for the *new build*
pack_set -module-opt "-use-path $(build_get -module-path[_internal-R$IrV])"
case $_mod_format in
    $_mod_format_ENVMOD)
	;;
    *)
	pack_set -module-opt "-use-path $(build_get -module-path[_internal-R$IrV])-apps"
	;;
esac


# Needed as it is not source_pack
pack_install


create_module \
    -module-path $(build_get -module-path)-apps \
    -n $(pack_get -alias).$(pack_get -version) \
    -W "Loading $(pack_get -package): $(get_c)" \
    -v $(pack_get -version) \
    -M $(pack_get -alias).$(pack_get -version) \
    -P "/directory/should/not/exist" \
    $(list -prefix '-L ' $(pack_get -module-requirement)) \
    -L $(pack_get -alias) 



# The lookup name in the list for version number etc...
set_parent $(pack_get -alias)[$IrV]
set_parent_exec $(pack_get -prefix)/bin/R

# Save the default build index
def_idx=$(build_get -default-build)
# Change to the new build default
build_set --default-build _internal-R$IrV


# Install all R packages
source R/R-install.bash
clear_parent

# Initialize the module read path
old_path=$(build_get -module-path)
build_set -module-path $old_path-apps
source R/R-mods.bash
build_set -module-path $old_path


# Reset default build
build_set --default-build $def_idx
