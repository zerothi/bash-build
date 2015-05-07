msg_install \
    --message \
    "Installing the python-packages for $(pack_get --module-name $(get_parent))"
# This script will install all python packages
#exit 0

pMod="$(pack_get --mod-req $(get_parent)) $(get_parent)"
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

# Save the default build index
def_idx=$(build_get --default-build)

# Ensure get_c is defined
source $(build_get --source)
new_build --name python$IpV \
    --source $(build_get --source) \
    $(list --prefix "--default-module " $pMod) \
    --installation-path $(build_get --installation-path)/$(pack_get --package $(get_parent))/$IpV/packages \
    --build-module-path "--package --version $IppV $(get_c)" \
    --build-installation-path "--package --version $(get_c)"

# Change to the new build default
build_set --default-build python$IpV

build_set --default-choice[python$IpV] linalg openblas atlas blas

# Python building utility
source python/scons.bash

# Install the helper (mongodb)
source helpers/mongo.bash

source python/setuptools.bash

# Used for many packages
source python/nose.bash

# Packages installed in "python-home"
source python/pkgconfig.bash
source python/pyparsing.bash
source python/backports.bash
source python/certifi.bash
source python/tornado.bash # backports, certifi
source python/six.bash
source python/docutils.bash
source python/dateutil.bash
source python/pygments.bash
source python/fastimport.bash
source python/pexpect.bash
source python/pycparser.bash
source python/pyzmq.bash
source python/mistune.bash

source python/jsonschema.bash
source python/markupsafe.bash
source python/jinja2.bash
source python/sphinx.bash # jinja2
source python/pytz.bash
source python/pysqlite.bash
source python/ipython.bash
source python/monty.bash
source python/pyyaml.bash
source python/mock.bash # only for python 2

source python/pandoc.bash

# Done with packages only installed in python-home! ^

source python/pymongo.bash
source python/fireworks.bash

source python/cython.bash
source python/cffi.bash

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
source python/petsc4py.bash
source python/slepc4py.bash

source python/krypy.bash
source python/pygsl.bash

# Other scikit-programs
source python/scikit-learn.bash
source python/scikit-optimization.bash
#source python/scikit-nano.bash

# Must be installed after numpy
source python/llvmpy.bash
source python/llvmmath.bash
source python/numba-0.15.bash

# Later versions of numba
source python/llvmlite.bash
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

pack_install

build_set --default-build $def_idx
