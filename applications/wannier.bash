for v in 1.2 ; do
add_package http://www.wannier.org/code/wannier90-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --host-reject "ntch"
pack_set --install-query $(pack_get --install-prefix)/bin/wannier90

# Check for Intel MKL or not
if $(is_c intel) ; then
    tmp="$MKL_LIB -mkl=sequential -lmkl_lapack95_lp64 -lmkl_blas95_lp64"

elif $(is_c gnu) ; then
    if [ $(pack_installed atlas) -eq 1 ] ; then
	pack_set --module-requirement atlas
	tmp="$(list --LDFLAGS --Wlrpath atlas) -llapack_atlas -lf77blas -lcblas -latlas"
    else
	pack_set --module-requirement blas --module-requirement lapack
	tmp="$(list --LDFLAGS --Wlrpath blas lapack) -llapack -lblas"
    fi
else
    doerr "$(pack_get --package)" "Could not recognize the compiler: $(get_c)"

fi

cat << EOF > $(pack_get --alias)-$(pack_get --version).sys
F90 = $FC
FCOPTS = $FCFLAGS $tmp
LDOPTS = $FCFLAGS $tmp
LIBS = $tmp -lpthread
EOF
pack_set --command "cp $(pwd)/$(pack_get --alias)-$(pack_get --version).sys make.sys"
pack_set --command "rm $(pwd)/$(pack_get --alias)-$(pack_get --version).sys"


# Make commands
pack_set --command "make $(get_make_parallel) wannier"
pack_set --command "make lib"
pack_set --command "make test"
pack_set --command "mkdir -p $(pack_get --install-prefix)/bin/"
pack_set --command "cp wannier90.x $(pack_get --install-prefix)/bin/wannier90"
pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/"
pack_set --command "cp libwannier.a $(pack_get --install-prefix)/lib/"
pack_set --command "mkdir -p $(pack_get --install-prefix)/include/"
pack_set --command "cp src/*.mod $(pack_get --install-prefix)/include/"

pack_install


create_module \
    --module-path $(get_installation_path)/modules-npa-apps \
    -n "\"Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)\"" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(get_default_modules) $(pack_get --module-requirement)) \
    -L $(pack_get --alias) 

done
