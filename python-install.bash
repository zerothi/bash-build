# This script will install all python packages
pV=$($(get_parent_exec) -c 'import sys ;print "{0}.{1}".format(sys.version_info[0],sys.version_info[1])')
source p-distribute.bash
source p-bazar.bash
source p-nose.bash
source p-cython.bash
source p-mpi4py.bash
source p-numpy.bash
source p-scipy.bash
source p-matplotlib.bash
source p-scientificpython.bash
source p-ase.bash
source p-gpaw.bash
source p-inelastica.bash
source p-inelastica-dev.bash


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
