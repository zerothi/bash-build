add_package --package openmx \
    --version 3.7.8 \
    http://www.openmx-square.org/openmx3.7.tar.gz

pack_set -s $IS_MODULE

pack_set --module-opt "--lua-family openmx"

pack_set --host-reject ntch-l

pack_set --install-query $(pack_get --install-prefix)/bin/openmx

pack_set --module-requirement openmpi --module-requirement fftw-3

# Move to the source directory
pack_set --command "cd source"

pack_set --command "wget http://www.openmx-square.org/bugfixed/14Feb17/patch3.7.8.tar.gz"
pack_set --command "tar xfz patch3.7.8.tar.gz"

if test -z "$FLAG_OMP" ; then
    doerr OpenMX "Can not find the OpenMP flag (set FLAG_OMP in source)"
fi

# Clean up the makefile
file=makefile
pack_set --command "sed -i -e 's/^LIB[^E].*//g;s/^[FC]C[[:space:]]*=.*//g' $file"
pack_set --command "sed -i -e 's/^CFLAGS.*//g;s:^-I/usr/local/include.*::g' $file"
# Ensures that linking gets the FORTRAN files, we could also add -lgfortran
#tools="openmx TranMain esp check_lead polB analysis_example jx DosMain"
#for tool in $tools ; do
#    pack_set --command "sed -i -e '/-o $tool/{s/CC/FC/}' $file"
#done
pack_set --command "sed -i -e '/^DESTDIR*/d' $file"

if $(is_c intel) ; then    
    # Added ifcore library to complie
    pack_set --command "sed -i '1 a\
    LIB += -mkl=parallel -lifcore \nCC += $FLAG_OMP\nFC += $FLAG_OMP -nofor_main' $file"
    
else
    pack_set --module-requirement scalapack
    if [ $(pack_installed atlas) -eq 1 ] ; then
	pack_set --module-requirement atlas
	pack_set --command "sed -i '1 a\
    LIB += $(list --LDFLAGS --Wlrpath atlas scalapack) -lscalapack -llapack_atlas -lf77blas -lcblas -latlas' $file"
    else
	pack_set --module-requirement blas --module-requirement lapack
	pack_set --command "sed -i '1 a\
    LIB += $(list --LDFLAGS --Wlrpath blas lapack scalapack) -lscalapack -llapack -lblas' $file"
    fi

    # Add the gfortran library
    pack_set --command "sed -i '1 a\
LIB += -lgfortran' $file"

    pack_set --command "sed -i '1 a\
CC += $FLAG_OMP\nFC += $FLAG_OMP' $file"
    
fi
pack_set --command "sed -i '1 a\
DESTDIR = $(pack_get --install-prefix)/bin\n\
CC = $MPICC $CFLAGS \$(INCS)\n\
FC = $MPIF90 $FFLAGS \$(INCS)' $file"

# Ensure linking to the fortran libraries
pack_set --command "sed -i '1 a\
LIB = $(list --LDFLAGS --Wlrpath $(pack_get --module-requirement)) -lfftw3_mpi -lfftw3 -lmpi_mpifh -lmpi \n\
INCS = $(list --INCDIRS $(pack_get --module-requirement))' $file"

# prepare the directory of installation
pack_set --command "mkdir -p $(pack_get --install-prefix)/bin"

# Make commands
pack_set --command "make"
pack_set --command "make install"
for tool in TranMain esp polB analysis_example jx DosMain ; do
    pack_set --command "make $tool"
done
# Apparently this is the only tool that is not automatically installed
pack_set --command "cp TranMain $(pack_get --install-prefix)/bin/"

# Add an ENV-flag for the pseudos to be accesible
pack_set --command "cd ../DFT_DATA13"
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
