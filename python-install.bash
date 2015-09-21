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
tmp=$(pack_get --prefix $(get_parent))/../packages
new_build --name python$IpV \
    --source $(build_get --source) \
    $(list --prefix "--default-module " $pMod) \
    --installation-path $tmp \
    --build-module-path "--package --version $IppV $(get_c)" \
    --build-installation-path "--package --version $(get_c)"
unset tmp

# Change to the new build default
build_set --default-build python$IpV

build_set --default-choice[python$IpV] linalg openblas atlas blas

# Python building utility
source_pack python/scons.bash

# Install the helper (mongodb)
source_pack helpers/mongo.bash

source_pack python/setuptools.bash

# Used for many packages
source_pack python/nose.bash

# Packages installed in "python-home"
source_pack python/pep8.bash
source_pack python/pkgconfig.bash
source_pack python/pyparsing.bash
source_pack python/backports.bash
source_pack python/certifi.bash
source_pack python/tornado.bash # backports, certifi
source_pack python/six.bash
source_pack python/docutils.bash
source_pack python/dateutil.bash
source_pack python/pygments.bash
source_pack python/fastimport.bash
source_pack python/pexpect.bash
source_pack python/pycparser.bash
source_pack python/pyzmq.bash
source_pack python/mistune.bash

source_pack python/jsonschema.bash
source_pack python/markupsafe.bash
source_pack python/jinja2.bash
source_pack python/sphinx.bash # jinja2
source_pack python/pytz.bash
source_pack python/pysqlite.bash
source_pack python/ipython.bash
source_pack python/monty.bash
source_pack python/pyyaml.bash
source_pack python/mock.bash # only for python 2

source_pack python/pandoc.bash

# Done with packages only installed in python-home! ^

source_pack python/pymongo.bash
source_pack python/fireworks.bash

source_pack python/cython.bash
source_pack python/cffi.bash

source_pack python/bzr.bash
source_pack python/bzr-fastimport.bash

# Units in python
#source_pack python/pint.bash

# Generic scientific libraries
source_pack python/mpi4py.bash
source_pack python/numpy.bash
source_pack python/netcdf4.bash
source_pack python/scipy.bash
source_pack python/numexpr.bash
source_pack python/scientificpython.bash
source_pack python/matplotlib.bash
source_pack python/bottleneck.bash
source_pack python/sympy.bash
source_pack python/h5py.bash # [numpy,hdf5-serial]
source_pack python/pytables.bash # [numpy,cython,hdf5-serial,numexpr]
source_pack python/pandas.bash
source_pack python/theanos.bash
source_pack python/pyamg.bash
source_pack python/petsc4py.bash
source_pack python/slepc4py.bash

source_pack python/krypy.bash
source_pack python/pygsl.bash

source_pack python/sids.bash

# Other scikit-programs
source_pack python/scikit-learn.bash
source_pack python/scikit-optimization.bash
#source_pack python/scikit-nano.bash

# Must be installed after numpy
source_pack python/llvmpy.bash
source_pack python/llvmmath.bash
source_pack python/numba-0.15.bash

# Later versions of numba
source_pack python/llvmlite.bash
source_pack python/numba.bash

# Physics related python modules
source_pack python/inelastica.bash
source_pack python/inelastica-dev.bash
source_pack python/inelastica-matt.bash

source_pack python/qutip.bash # [numpy,scipy,cython,matplotlib]
source_pack python/ase.bash
source_pack python/gpaw.bash
source_pack python/gpaw-setups.bash

source_pack python/pythtb.bash
source_pack python/phonopy.bash

# made for kwant
source_pack python/tinyarray.bash
source_pack python/kwant.bash

build_set --default-build $def_idx
