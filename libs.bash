msg_install --message "Installing all libraries..."
#source libs/gmp.bash
#source libs/guile.bash

# Library used by MANY packages
source libs/openmpi-niflheim.bash

# Default fftw libs
source libs/fftw2.bash
source libs/fftw3.bash

# Default packages for many libs
source libs/blas.bash
source libs/lapack.bash
source libs/atlas.bash
source libs/scalapack.bash

timings For basic math libraries and OpenMPI

# Some specific libraries
source libs/gsl.bash
#source libs/boost.bash
source libs/ctl.bash
source libs/harminv.bash

# Install bison
source libs/bison.bash
source libs/pcre.bash
source libs/swig.bash

timings For specific/requested libraries 

source libs/zlib.bash
source libs/hdf5.bash
source libs/hdf5-serial.bash
source libs/parallel-netcdf.bash
source libs/netcdf.bash
source libs/netcdf-serial.bash

timings For netcdf and related libraries

# A sparse library
source libs/suitesparse.bash

timings For sparse libraries

# We install the module scripts here:
create_module \
    --module-path $(get_installation_path)/modules-npa \
    -n "\"Nick Papior Andersen's module script for: $(get_c)\"" \
    -v $(date +'%g-%j') \
    -M mpi.zlib.hdf5.netcdf/$(get_c) \
    -P "/directory/should/not/exist" $(list --prefix '-L ' $(get_default_modules)) \
    $(list --prefix '-L ' --loop-cmd 'pack_get --module-name' $(pack_get --module-requirement netcdf))

create_module \
    --module-path $(get_installation_path)/modules-npa \
    -n "\"Nick Papior Andersen's basic math script for: $(get_c)\"" \
    -v $(date +'%g-%j') \
    -M blas.lapack/$(get_c) \
    -P "/directory/should/not/exist" $(list --prefix '-L ' $(get_default_modules)) \
    $(list --prefix '-L ' --loop-cmd 'pack_get --module-name' blas lapack)

create_module \
    --module-path $(get_installation_path)/modules-npa \
    -n "\"Nick Papior Andersen's parallel math script for: $(get_c)\"" \
    -v $(date +'%g-%j') \
    -M mpi.blas.lapack.scalapack/$(get_c) \
    -P "/directory/should/not/exist" $(list --prefix '-L ' $(get_default_modules)) \
    -L "$(pack_get --module-name openmpi)" \
    -L "$(pack_get --module-name blas)" \
    -L "$(pack_get --module-name lapack)" \
    -L "$(pack_get --module-name scalapack)"

create_module \
    --module-path $(get_installation_path)/modules-npa \
    -n "\"Nick Papior Andersen's parallel fast math script for: $(get_c)\"" \
    -v $(date +'%g-%j') \
    -M mpi.atlas.scalapack/$(get_c) \
    -P "/directory/should/not/exist" $(list --prefix '-L ' $(get_default_modules)) \
    -L "$(pack_get --module-name openmpi)" \
    -L "$(pack_get --module-name atlas)" \
    -L "$(pack_get --module-name scalapack)"
