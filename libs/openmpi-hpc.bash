if $(is_host surt muspel slid a0 b0 c0 d0 g0 m0 n0 p0 q0) ; then
    echo "Will make link to local installation on Niflheim."
else
    source libs/openmpi.bash
    return 0
fi

# Figure out the module we require to use...

# Determine the name of the local module:
if $(is_host surt muspel slid a0 b0 c0 d0 g0 m0 n0 p0 q0) ; then
    if $(is_c intel) ; then
        mod=1.6.5-${NPA_NODETYPE}-tm-intel-2013.5.192-1
        mod=1.6.5-${NPA_NODETYPE}-tm-intel-2013_sp1.4.211-1
    elif $(is_c gnu) ; then
        mod=1.6.3-${NPA_NODETYPE}-tm-gfortran-1
    else
        doerr 1 "Could not determine compiler for OpenMPI on niflheim"
    fi
elif $(is_host surt muspel slid a0 b0 c0 d0 g0 m0 n0 p0 q0) ; then
    if $(is_c intel) ; then
        mod=1.3.3-1.el5.fys.ifort.11.1
    elif $(is_c gnu) ; then
        mod=1.3.3-1.el5.fys.gfortran.4.1.2
    else
        doerr 1 "Could not determine compiler for OpenMPI on niflheim"
    fi
fi

# Enable the reading of the "hidden" package...
add_hidden_package openmpi/$mod

# Install the easiest first... OpenMPI
add_package --package openmpi \
    --version hpc \
    here/openmpi-hpc.tar.gz

pack_set --installed $_I_INSTALLED

module load $(build_get --default-module)
module load openmpi/$mod
tmp=$(which mpif90)
pack_set --prefix ${tmp//\/bin*/}
module unload openmpi/$mod
module unload $(build_get --default-module)

create_module \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --module-name) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(build_get --default-module)) \
    -L openmpi[$mod]

