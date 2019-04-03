msg_install --message "Installing all libraries..."

# Basic libraries
source_pack libs/zlib.bash
source_pack libs/szip.bash
source_pack libs/expat.bash
source_pack libs/libffi.bash
source_pack libs/libxml2.bash

source_pack libs/hwloc.bash

# Basic parallel libraries
source_pack libs/pmix.bash

source_pack libs/openmpi.bash
source_pack libs/mpich.bash
source_pack libs/mvapich.bash

# Set the default MPI version
if $(is_c intel) ; then
    # The current implementation does not abstract the
    # mpi differences
    pack_set --alias mpi openmpi
else
    pack_set --alias mpi $_mpi_version
fi

# Optimization of openmpi parameters
source_pack libs/adcl.bash
source_pack libs/otpo.bash
#source_pack libs/netpipe.bash

source_pack libs/opencoarray.bash

# Default fftw libs
source_pack libs/fftw2.bash
source_pack libs/fftw.bash
source_pack libs/fftw2-intel.bash
source_pack libs/fftw-intel.bash
source_pack libs/nfft.bash

# ONETEPs multigrid Poisson solver
source_pack libs/dl_mg.bash

# Currently aotus is compiled together with flook
source_pack libs/flook.bash

# Install my fortran dictionary library
source_pack libs/fdict.bash

# Default packages for many libs
source_pack libs/lapack.bash
source_pack libs/scalapack.bash
source_pack libs/scalapack-debug.bash
source_pack libs/spike.bash

source_pack libs/blis.bash

source_pack libs/atlas.bash
source_pack libs/openblas.bash

source_pack libs/flame.bash

source_pack libs/plasma.bash
source_pack libs/arpack.bash
source_pack libs/arpack-ng.bash
source_pack libs/parpack.bash

source_pack libs/elpa.bash
source_pack libs/elpa-debug.bash
source_pack libs/eigenexa.bash

source_pack libs/globalarrays.bash

source_pack libs/eigen.bash

# Some specific libraries
source_pack libs/glpk.bash
source_pack libs/gsl.bash
source_pack libs/boost.bash
source_pack libs/ctl.bash
source_pack libs/harminv.bash

# Requires BOOST for additional libraries.
source_pack libs/blaze.bash

# Install generic libraries
source_pack libs/hdf5.bash
source_pack libs/hdf5-serial.bash
source_pack libs/hdf5-serial-noszip.bash
source_pack libs/h5utils-serial.bash
source_pack libs/pnetcdf.bash
source_pack libs/netcdf.bash
source_pack libs/netcdf-logging.bash
source_pack libs/netcdf-serial.bash
source_pack libs/netcdf-serial-noszip.bash

# Install my ncdf library
source_pack libs/ncdf.bash

source_pack libs/udunits.bash
source_pack libs/nco.bash

# sorting algorithms for matrices
source_pack libs/metis.bash
source_pack libs/metis-par-3.bash
source_pack libs/parmetis.bash
source_pack libs/scotch.bash

# A sparse library
source libs/suitesparse.bash
source_pack libs/suitesparse_all.bash

source_pack libs/mumps-serial.bash
source_pack libs/mumps.bash
source_pack libs/superlu.bash
source_pack libs/superlu-dist.bash

source_pack libs/petsc.bash
source_pack libs/slepc.bash


# PEXSI
source_pack libs/sympack.bash
source_pack libs/pexsi.bash

# Libraries for DFT
source_pack libs/xmlf90.bash
source_pack libs/libxc.bash
source_pack libs/psml.bash
source_pack libs/pspio.bash
source_pack libs/gridxc.bash
source_pack libs/etsf_io.bash
source_pack libs/atompaw.bash

# We install the module scripts here:
create_module \
    --module-path $(build_get --module-path)-apps \
    -n mpi.zlib.hdf5.netcdf \
    -W "Script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M mpi.zlib.hdf5.netcdf \
    -P "/directory/should/not/exist" \
    -RL netcdf


# Create a module with default all plotting tools
tmp=
for i in nco h5utils-serial
do
    if [[ $(pack_installed $i) -eq $_I_INSTALLED ]]; then
        tmp="$tmp $i"
    fi
done
if [ ! -z "$tmp" ]; then
    create_module \
	--module-path $(build_get --module-path)-apps \
	-n file-utils \
	-W "Script for: $(get_c)" \
	-v $(date +'%g-%j') \
	-M hdf5.netcdf.utils \
	-P "/directory/should/not/exist" \
	$(list --prefix '-RL ' $tmp)
fi

for bl in blas atlas openblas ; do
    create_module \
	--module-path $(build_get --module-path)-apps \
        -n mpi.$bl.scalapack \
	-W "Parallel math script for: $(get_c)" \
	-v $(date +'%g-%j') \
	-M mpi.$bl.scalapack \
	-P "/directory/should/not/exist" \
	$(list --prefix '-RL ' $(pack_get --module-requirement mpi) mpi $bl)
done

