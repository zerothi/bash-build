msg_install --message "Installing the python-packages..."
# This script will install all python packages
module load $(get_default_modules)
module load $(pack_get --module-name $(get_parent))
pV=$($(get_parent_exec) -c 'import sys ;print "{0}.{1}".format(sys.version_info[0],sys.version_info[1])')
module unload $(pack_get --module-name $(get_parent))
module unload $(get_default_modules)
#source python/distribute.bash
source python/bazar.bash
source python/nose.bash

timings For python default packages

source python/cython.bash
source python/mpi4py.bash
source python/numpy.bash
source python/scipy.bash # [numpy]
source python/numexpr.bash # [numpy]
source python/scientificpython.bash
source python/matplotlib.bash

timings For python default scientific packages

source python/h5py.bash # [numpy,hdf5-serial]
source python/pytables.bash # [numpy,cython,hdf5-serial,numexpr]
source python/inelastica.bash
source python/inelastica-dev.bash

source python/qutip.bash # [numpy,scipy,cython,matplotlib]
source python/ase.bash
source python/gpaw.bash
source python/gpaw-setups.bash

timings For python special packages


# Initialize the module read path
old_path=$(get_module_path)
set_module_path $(get_installation_path)/modules-npa

create_module \
    -n "\"Nick Papior Andersen's basic python script for: $(get_c)\"" \
    -v $(date +'%g-%j') \
    -M python$pV.cython.numpy.scipy.numexpr.scientific.matplotlib/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement scientificpython) scientificpython scipy cython numexpr-2 matplotlib)

create_module \
    -n "\"Nick Papior Andersen's parallel python script for: $(get_c)\"" \
    -v $(date +'%g-%j') \
    -M python$pV.cython.mpi4py.numpy.scipy.scientific/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement scientificpython) scientificpython scipy cython mpi4py)

create_module \
    -n "\"Nick Papior Andersen's DFT python script for: $(get_c)\"" \
    -v $(date +'%g-%j') \
    -M python$pV.numpy.scipy.scientific.ase.gpaw.inelastica/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement scientificpython) scientificpython scipy ase gpaw inelastica)

if [ $(pack_get --installed qutip) -eq 1 ]; then
    create_module \
        -n "\"Nick Papior Andersen's Photonics python script for QuTip: $(get_c)\"" \
        -v $(date +'%g-%j') \
        -M python$pV.scientific.cython.numexpr.qutip/$(get_c) \
        -P "/directory/should/not/exist" \
        $(list --prefix '-L ' $(pack_get --module-requirement scientificpython) scientificpython cython numexpr-2 qutip)
fi

set_module_path $old_path
