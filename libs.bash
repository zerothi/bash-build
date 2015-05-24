msg_install --message "Installing all libraries..."

# Basic libraries
source libs/zlib.bash
source libs/expat.bash
source libs/libffi.bash
source libs/libxml2.bash

#source libs/llvm.bash
#source libs/gmp.bash
#source libs/guile.bash

source libs/hwloc.bash

# Basic parallel libraries
source libs/openmpi-hpc.bash
source libs/mpich.bash
# Set the default MPI version
if $(is_c intel) ; then
    # The current implementation does not abstract the
    # mpi differences
    pack_set --alias mpi openmpi
else
    pack_set --alias mpi $_mpi_version
fi

# Optimization of openmpi parameters
source libs/otpo.bash

# Default fftw libs
source libs/fftw2.bash
source libs/fftw3.bash
source libs/fftw2-intel.bash
source libs/fftw3-intel.bash

# Install my fortran dictionary library
source libs/fvar.bash

# Default packages for many libs
source libs/blas.bash
source libs/cblas.bash
source libs/lapack.bash blas
source libs/scalapack.bash

source libs/atlas.bash
source libs/lapack.bash atlas
source libs/openblas.bash
source libs/lapack.bash openblas

source libs/plasma.bash
#source libs/flame.bash
source libs/arpack.bash
source libs/arpack-ng.bash
source libs/parpack.bash

# Some specific libraries
source libs/gsl.bash
source libs/boost.bash
source libs/ctl.bash
source libs/harminv.bash

# Install generic libraries
source libs/hdf5.bash
source libs/hdf5-serial.bash
source libs/h5utils-serial.bash
source libs/parallel-netcdf.bash
source libs/netcdf.bash
source libs/netcdf-logging.bash
source libs/netcdf-serial.bash

# Install my ncdf library
source libs/ncdf.bash

source libs/udunits.bash
source libs/nco.bash

# sorting algorithms for matrices
source libs/metis.bash
source libs/metis-par-3.bash
source libs/metis-par.bash
source libs/scotch.bash

# A sparse library
source libs/suitesparse.bash
source libs/suitesparse_all.bash

source libs/mumps-serial.bash
source libs/mumps.bash
source libs/superlu.bash
source libs/superlu-dist.bash
source libs/petsc.bash
source libs/slepc.bash

# Libraries for DFT
source libs/libxc.bash
source libs/etsf_io.bash
source libs/atompaw.bash

# We need to end lib-installation
# before proceeding
pack_install

# We install the module scripts here:
create_module \
    --module-path $(build_get --module-path)-npa \
    -n "Nick Papior Andersen's module script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M mpi.zlib.hdf5.netcdf/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement netcdf) netcdf)

tmp=$(get_index nco)
retval=$?
if [ $retval -eq 0 ]; then
    create_module \
	--module-path $(build_get --module-path)-npa \
	-n "Nick Papior Andersen's module script for: $(get_c)" \
	-v $(date +'%g-%j') \
	-M hdf5.netcdf.utils/$(get_c) \
	-P "/directory/should/not/exist" \
	$(list --prefix '-L ' $(pack_get --module-requirement nco) $(pack_get --module-requirement h5utils-serial) nco h5utils-serial)
fi

for bl in blas atlas openblas ; do
    create_module \
	--module-path $(build_get --module-path)-npa \
	-n "Nick Papior Andersen's parallel math script for: $(get_c)" \
	-v $(date +'%g-%j') \
	-M mpi.$bl.scalapack/$(get_c) \
	-P "/directory/should/not/exist" \
	$(list --prefix '-L ' $(pack_get --module-requirement mpi) mpi $bl)
done

