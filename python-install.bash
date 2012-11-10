# This script will install all python packages
module load $(pack_get --module-name $(get_parent))
pV=$($(get_parent_exec) -c 'import sys ;print "{0}.{1}".format(sys.version_info[0],sys.version_info[1])')
module unload $(pack_get --module-name $(get_parent))
source python/distribute.bash
source python/bazar.bash
source python/nose.bash
source python/cython.bash
source python/mpi4py.bash
source python/numpy.bash
source python/scipy.bash
source python/numexpr.bash
source python/h5py.bash
source python/pytables.bash
source python/qutip.bash
source python/matplotlib.bash
source python/scientificpython.bash
source python/ase.bash
source python/gpaw.bash
source python/inelastica.bash
source python/inelastica-dev.bash


# Initialize the module read path
set_module_path $install_path/modules-npa


create_module \
    -n "\"Nick Papior Andersen's basic python script for: $(get_c)\"" \
    -v $(date +'%g-%j') \
    -M python$pV.numpy.scipy.scientific.matplotlib/$(get_c) \
    -P "/directory/should/not/exist" \
    -L "$(pack_get --module-name python-$pV)" \
    -L "$(pack_get --module-name numpy)" \
    -L "$(pack_get --module-name scipy)" \
    -L "$(pack_get --module-name scientificpython)" \
    -L "$(pack_get --module-name matplotlib)"


create_module \
    -n "\"Nick Papior Andersen's parallel python script for: $(get_c)\"" \
    -v $(date +'%g-%j') \
    -M python$pV.cython.mpi4py.numpy.scipy.scientific.matplotlib/$(get_c) \
    -P "/directory/should/not/exist" \
    -L "$(pack_get --module-name python-$pV)" \
    -L "$(pack_get --module-name cython)" \
    -L "$(pack_get --module-name mpi4py)" \
    -L "$(pack_get --module-name numpy)" \
    -L "$(pack_get --module-name scipy)" \
    -L "$(pack_get --module-name scientificpython)" \
    -L "$(pack_get --module-name matplotlib)"


create_module \
    -n "\"Nick Papior Andersen's DFT python script for: $(get_c)\"" \
    -v $(date +'%g-%j') \
    -M python$pV.numpy.scipy.scientific.ase.gpaw.inelastica/$(get_c) \
    -P "/directory/should/not/exist" \
    -L "$(pack_get --module-name python-$pV)" \
    -L "$(pack_get --module-name numpy)" \
    -L "$(pack_get --module-name scipy)" \
    -L "$(pack_get --module-name scientificpython)" \
    -L "$(pack_get --module-name ase)" \
    -L "$(pack_get --module-name gpaw)" \
    -L "$(pack_get --module-name inelastica)"
