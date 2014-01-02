add_package http://www.openmx-square.org/openmx3.7.tar.gz

pack_set -s $IS_MODULE

pack_set --module-opt "--lua-family openmx"

pack_set --install-query $(pack_get --install-prefix)/bin/openmx

pack_set --module-requirement openmpi --module-requirement fftw-3

# Move to the source directory
pack_set --command "cd source"

# Patch it...
pack_set --command "wget http://www.openmx-square.org/bugfixed/13Sep01/patch3.7.6.tar.gz"
pack_set --command "tar xfz patch3.7.6.tar.gz"


# Clean up the makefile
file=makefile
pack_set --command "sed -i -e 's/^LIB[^E].*//g;s/^[FC]C[[:space:]]*=.*//g' $file"
pack_set --command "sed -i -e 's/^CFLAGS.*//g;s:^-I/usr/local/include.*::g' $file"
pack_set --command "sed -i -e '/-o openmx/{s/CC/FC/}' $file"

if $(is_c intel) ; then
    
    pack_set --command "sed -i '1 a\
    LIB += -mkl=parallel\nCC += -openmp\nFC += -openmp -nofor_main' $file"
    
elif $(is_c gnu) ; then
    if [ $(pack_installed atlas) -eq 1 ] ; then
	pack_set --module-requirement atlas
	pack_set --command "sed -i '1 a\
    LIB += $(list --LDFLAGS --Wlrpath atlas) -llapack_atlas -lf77blas -lcblas -latlas' $file"
    else
	pack_set --module-requirement blas --module-requirement lapack
	pack_set --command "sed -i '1 a\
    LIB += $(list --LDFLAGS --Wlrpath blas lapack) -llapack -lblas' $file"
    fi

    pack_set --command "sed -i '1 a\
CC += -fopenmp\nFC += -fopenmp' $file"

else
    doerr $(pack_get --package) "Could not determine compiler: $(get_c)"
    
fi
pack_set --command "sed -i '1 a\
CC = $MPICC $CFLAGS \$(INCS)\n\
FC = $MPIF90 $FFLAGS \$(INCS)' $file"

pack_set --command "sed -i '1 a\
LIB = $(list --LDFLAGS --Wlrpath $(pack_get --module-requirement)) -lfftw3\n\
INCS = $(list --INCDIRS $(pack_get --module-requirement))' $file"

# Make commands
pack_set --command "make"

# Install the package
pack_set --command "mkdir -p $(pack_get --install-prefix)/bin"
pack_set --command "cp openmx $(pack_get --install-prefix)/bin/"
pack_set --command "cd .."

# Add an ENV-flag for the pseudos to be accesible
pack_set --command "cd DFT_DATA13"
pack_set --command "cp -r PAO VPS $(pack_get --install-prefix)/"
pack_set --module-opt "--set-ENV OPENMX_PAO=$(pack_get --install-prefix)/PAO"
pack_set --module-opt "--set-ENV OPENMX_VPS=$(pack_get --install-prefix)/VPS"

pack_install


create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement)) \
    -L $(pack_get --alias)
