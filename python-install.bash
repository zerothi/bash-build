msg_install \
    --message \
    "Installing the python-packages for $(pack_get --module-name $(get_parent))"
# This script will install all python packages
#exit 0

pMod="$(pack_get --module-requirement $(get_parent)) $(get_parent)"
pModNames="$(list --loop-cmd "pack_get --module-name" $pMod)"
module load $pModNames
pV=$($(get_parent_exec) -c 'import sys ;print("{0}.{1}".format(sys.version_info[0],sys.version_info[1]))')
IppV=$(lc $(pack_get --alias $(get_parent)))-$(pack_get --version $(get_parent))
IpV=$(pack_get --version $(get_parent))
module unload $pModNames

# Create the numpy installation sequence
if $(is_c intel) ; then
    pNumpyInstall="--compiler=intelem --fcompiler=intelem"
elif $(is_c gnu) ; then
    pNumpyInstall="--compiler=unix --fcompiler=gnu95"
else
    doerr "Compiler python" "Could not recognize compiler"
fi

# Ensure get_c is defined
source $(build_get --source)
new_build --name python$IpV \
    --source $(build_get --source) \
    $(list --prefix "--default-module " $pMod) \
    --installation-path $(build_get --installation-path)/python/$IpV/packages \
    --build-module-path "--package --version $IppV $(get_c)" \
    --build-installation-path "--package --version $(get_c)" \
    $(list --prefix ' --default-module ' $pMod)

def_idx=$(build_get --default-build)
build_set --default-build python$IpV

# Packages installed in "python-home"
source python/distribute.bash
source python/pyparsing.bash
source python/tornado.bash
source python/six.bash
source python/dateutil.bash
source python/fastimport.bash
source python/pytz.bash
source python/pexpect.bash
source python/pygments.bash
source python/ipython.bash
source python/pycparser.bash

# Done with packages only installed in python-home! ^

source python/cython.bash
source python/cffi.bash
source python/nose.bash

source python/bzr.bash
source python/bzr-fastimport.bash

# Units in python
#source python/pint.bash

# Generic scientific libraries
source python/mpi4py.bash
source python/numpy.bash
source python/netcdf4.bash
source python/scipy.bash
source python/numexpr.bash
source python/scientificpython.bash
source python/matplotlib.bash
source python/bottleneck.bash
source python/sympy.bash
source python/h5py.bash # [numpy,hdf5-serial]
source python/pytables.bash # [numpy,cython,hdf5-serial,numexpr]
source python/pandas.bash
source python/pyamg.bash
#source python/petsc4py.bash
#source python/slepc4py.bash

source python/krypy.bash
source python/pygsl.bash

# Other scikit-programs
source python/scikit-learn.bash
source python/scikit-optimization.bash
#source python/scikit-nano.bash

# Must be installed after numpy
source python/llvmpy.bash
source python/llvmmath.bash

# Numba needs to release a new version (and numpy needs 1.9)
source python/numba.bash

# Physics related python modules
source python/inelastica.bash
source python/inelastica-dev.bash
source python/inelastica-matt.bash

source python/qutip.bash # [numpy,scipy,cython,matplotlib]
source python/ase.bash
source python/gpaw.bash
source python/gpaw-setups.bash

source python/pythtb.bash
source python/phonopy.bash

# made for kwant
source python/tinyarray.bash
source python/kwant.bash

install_all --from $(get_parent)

build_set --default-build $def_idx
