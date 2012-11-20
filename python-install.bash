# This script will install all python packages
module load $(pack_get --module-name $(get_parent))
pV=$($(get_parent_exec) -c 'import sys ;print "{0}.{1}".format(sys.version_info[0],sys.version_info[1])')
module unload $(pack_get --module-name $(get_parent))
#source python/distribute.bash
source python/bazar.bash
source python/nose.bash
source python/cython.bash
source python/mpi4py.bash
source python/numpy.bash
source python/scipy.bash # [numpy]
source python/numexpr.bash # [numpy]
source python/h5py.bash # [numpy,hdf5-serial]
source python/pytables.bash # [numpy,cython,hdf5-serial,numexpr]
source python/scientificpython.bash
source python/inelastica.bash
source python/inelastica-dev.bash

source python/matplotlib.bash
source python/qutip.bash # [numpy,scipy,cython,matplotlib]
source python/ase.bash
source python/gpaw.bash

# Initialize the module read path
old_path=$(get_module_path)
set_module_path $install_path/modules-npa

create_module \
    -n "\"Nick Papior Andersen's basic python script for: $(get_c)\"" \
    -v $(date +'%g-%j') \
    -M python$pV.cython.numpy.scipy.numexpr.scientific/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' --loop-cmd 'pack_get --module-name' $(pack_get --module-requirement scientificpython) numexpr-2 cython)


create_module \
    -n "\"Nick Papior Andersen's parallel python script for: $(get_c)\"" \
    -v $(date +'%g-%j') \
    -M python$pV.cython.mpi4py.numpy.scipy.scientific.matplotlib/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' --loop-cmd 'pack_get --module-name' $(pack_get --module-requirement scientificpython) cython matplotlib mpi4py)

create_module \
    -n "\"Nick Papior Andersen's DFT python script for: $(get_c)\"" \
    -v $(date +'%g-%j') \
    -M python$pV.basic.ase.gpaw.inelastica/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' --loop-cmd 'pack_get --module-name' $(pack_get --module-requirement scientificpython) ase gpaw inelastica)

create_module \
    -n "\"Nick Papior Andersen's Photonics python script for: $(get_c)\"" \
    -v $(date +'%g-%j') \
    -M python$pV.basic.qutip/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' --loop-cmd 'pack_get --module-name' $(pack_get --module-requirement scientificpython) cython numexpr-2 qutip)

set_module_path $old_path
