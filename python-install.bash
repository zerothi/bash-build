msg_install \
    --message \
    "Installing the python-packages for $(pack_get --module-name $(get_parent))"
# This script will install all python packages
#exit 0
module load $(build_get --default-module) $(pack_get --module-name $(get_parent))
pV=$($(get_parent_exec) -c 'import sys ;print("{0}.{1}".format(sys.version_info[0],sys.version_info[1]))')
IppV=$(lc $(pack_get --alias $(get_parent)))-$(pack_get --version $(get_parent))
IpV=$(pack_get --version $(get_parent))
module unload $(pack_get --module-name $(get_parent)) $(build_get --default-module) 

# Ensure get_c is defined
source $(build_get --source)
new_build --name python$IpV \
    --source $(build_get --source) \
    --installation-path $(build_get --installation-path)/python/$IpV/packages \
    --build-module-path "--package --version $IppV $(get_c)" \
    --build-installation-path "--package --version $(get_c)" \
    $(list --prefix ' --default-module ' $(build_get --default-module) $(get_parent))

def_idx=$(build_get --default-build)
build_set --default-build python$IpV

#build_set --build-module-path "--package --version $IpV $(get_c)"
#build_set --build-installation-path \
#    "$(build_get --installation-path) --package --version $IpV $(get_c)"

# Packages installed in "python-home"
source python/distribute.bash
source python/pyparsing.bash
source python/tornado.bash
source python/dateutil.bash
source python/fastimport.bash

source python/cython.bash
source python/bzr.bash
source python/bzr-fastimport.bash
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
#source python/pandas.bash

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

build_set --default-build $def_idx

#build_set --build-module-path "--package --version $(get_c)"
#build_set --build-installation-path \
#    "$(build_get --installation-path) --package --version $(get_c)"
