msg_install \
    --message \
    "Installing the python-packages for $(pack_get --module-name $(get_parent))"
# This script will install all python packages

module load $(build_get --default-module) $(pack_get --module-name $(get_parent))
pV=$($(get_parent_exec) -c 'import sys ;print("{0}.{1}".format(sys.version_info[0],sys.version_info[1]))')
IpV=$(lc $(pack_get --alias $(get_parent)))-$(pack_get --version $(get_parent))
module unload $(pack_get --module-name $(get_parent)) $(build_get --default-module) 

build_set --build-module-path "--package --version $IpV $(get_c)"
build_set --build-installation-path \
    "$(build_get --installation-path) --package --version $IpV $(get_c)"

# Packages installed in "python-home"
source python/distribute.bash
source python/pyparsing.bash
source python/tornado.bash
source python/dateutil.bash

source python/cython.bash
source python/bazar.bash
source python/nose.bash

# Generic scientific libraries
source python/mpi4py.bash
source python/numpy.bash
source python/scipy.bash
source python/numexpr.bash
source python/scientificpython.bash
source python/matplotlib.bash
source python/bottleneck.bash
source python/sympy.bash
source python/pandas.bash

install_all --from python

source python/h5py.bash # [numpy,hdf5-serial]
source python/pytables.bash # [numpy,cython,hdf5-serial,numexpr]

source python/inelastica.bash
source python/inelastica-dev.bash

source python/qutip.bash # [numpy,scipy,cython,matplotlib]
source python/ase.bash
source python/gpaw.bash
source python/gpaw-setups.bash

source python/pythtb.bash

source python/phonopy.bash

install_all --from $(get_parent)

build_set --build-module-path "--package --version $(get_c)"
build_set --build-installation-path \
    "$(build_get --installation-path) --package --version $(get_c)"
