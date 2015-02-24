for v in 2.0.0 1.2 ; do
add_package http://www.wannier.org/code/wannier90-$v.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix)/bin/wannier90

#pack_set --host-reject ntch-l
pack_set --module-opt "--lua-family wannier90"
if [ $(vrs_cmp $v 2.0) -ge 0 ]; then
    pack_set --module-requirement openmpi
fi

# Check for Intel MKL or not
if $(is_c intel) ; then
    tmp="$MKL_LIB -mkl=sequential -lmkl_lapack95_lp64 -lmkl_blas95_lp64"

elif $(is_c gnu) ; then

    for la in $(choice linalg) ; do
	if [ $(pack_installed $la) -eq 1 ]; then
	    pack_set --module-requirement $la
	    tmp="$(list --LDFLAGS --Wlrpath $la) -llapack"
	    if [ "x$la" == "xatlas" ]; then
		tmp="$tmp -lf77blas -lcblas -latlas"
	    else
		tmp="$tmp -l$la"
	    fi
	fi
    done

else
    doerr "$(pack_get --package)" "Could not recognize the compiler: $(get_c)"

fi

file=make.sys
pack_set --command "echo '# NPA' > $file"

pack_set --command "sed -i '1 a\
F90 = $FC \n\
COMMS = mpi\n\
MPIF90 = $MPIF90 # this will only be used for v >= 2.0\n\
FCOPTS = $FCFLAGS $tmp\n\
LDOPTS = $FCFLAGS $tmp\n\
LIBS = $tmp -lpthread ' $file"

pack_set --command "mkdir -p $(pack_get --prefix)/bin/"
pack_set --command "mkdir -p $(pack_get --LD)/"
pack_set --command "mkdir -p $(pack_get --prefix)/include/"

# Make commands
pack_set --command "make $(get_make_parallel) wannier"
if [ $(vrs_cmp $v 2.0) -ge 0 ]; then
    for d in post w90chk2chk w90vdw w90pov ; do
	pack_set --command "make $d"
    done
    pack_set --command "cp postw90.x $(pack_get --prefix)/bin/"
    pack_set --command "cp w90chk2chk.x $(pack_get --prefix)/bin/"
    pack_set --command "cp utility/w90vdw/w90vdw.x $(pack_get --prefix)/bin/"
    pack_set --command "cp utility/w90pov/w90pov $(pack_get --prefix)/bin/"
    pack_set --command "cp utility/kmesh.pl $(pack_get --prefix)/bin/"
fi
pack_set --command "make lib"
pack_set --command "make test"
pack_set --command "cp wannier90.x $(pack_get --prefix)/bin/"
pack_set --command "cp libwannier.a $(pack_get --LD)/"
if [ $(vrs_cmp $v 2.0) -ge 0 ]; then
    pack_set --command "cp src/obj/*.mod $(pack_get --prefix)/include/"
else
    pack_set --command "cp src/*.mod $(pack_get --prefix)/include/"
fi

# Make easy links
pack_set --command "cd $(pack_get --prefix)/bin/"
pack_set --command 'for f in *.x ; do ln -s $f ${f//.x/} ; done'

pack_install


create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --mod-req)) \
    -L $(pack_get --alias) 

done
