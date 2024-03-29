msg_install \
    --message \
    "Installing the python-packages for $(pack_get --module-name $(get_parent))"
# This script will install all python packages
#exit 0

# Create the numpy installation sequence
if $(is_c intel) ; then
    pNumpyInstallC="--compiler=intelem"
    pNumpyInstallF="--fcompiler=intelem"
elif $(is_c gnu) ; then
    pNumpyInstallC="--compiler=unix"
    pNumpyInstallF="--fcompiler=gnu95"
else
    doerr "Compiler python" "Could not recognize compiler"
fi
pNumpyInstall="$pNumpyInstallC $pNumpyInstallF"

# Also add this python Boost version
source_pack python/boost_amend.bash


# First install all pip installs
source_pack python/pip_installs.bash

# Python building utility
source_pack python/scons.bash
source_pack python/meson.bash

# Install the helper (mongodb)
source_pack helpers/mongo.bash

source_pack python/pysqlite.bash

# Jupyter framework
#source_pack python/jupyter.bash
#source_pack python/ipython.bash

# Done with packages only installed in python-home! ^

source_pack python/pymongo.bash
source_pack python/fireworks.bash

source_pack python/cython.bash
# In fact pybind11 is more like a normal library
#   libs/pybind11.bash would maybe be more appropiate.
source_pack python/pybind11.bash

# GUI based stuff
source_pack python/sip.bash
source_pack python/pyqt5.bash
source_pack python/pyqt3d.bash
source_pack python/wxpython.bash

# Generic scientific libraries
source_pack python/numpy.bash
source_pack python/scipy.bash
source_pack python/mpi4py.bash
source_pack python/imageio.bash
source_pack python/cftime.bash
source_pack python/netcdf4.bash
source_pack python/numexpr.bash
source_pack python/matplotlib.bash
source_pack python/bottleneck.bash
source_pack python/sympy.bash
source_pack python/h5py.bash # [numpy,hdf5-serial]
source_pack python/pytables.bash # [numpy,cython,hdf5-serial,numexpr]
source_pack python/pandas.bash
source_pack python/statsmodels.bash
source_pack python/theano.bash
source_pack python/pymc3.bash
source_pack python/dask.bash
source_pack python/dask-distributed.bash
source_pack python/pyamg.bash
source_pack python/pywt.bash
source_pack python/petsc4py.bash
source_pack python/slepc4py.bash
source_pack python/networkx.bash

#source_pack python/pyccel-dev.bash
source_pack python/pyfftw.bash

source_pack python/lmfit.bash

# Tensorflow (CPU-only)
source_pack python/tensorflow.bash
source_pack python/pytorch.bash

# Additional plotting stuff
source_pack python/seaborn.bash

source_pack python/xarray.bash

source_pack python/plotly.bash

source_pack python/yt.bash
source_pack python/krypy.bash
source_pack python/pygsl.bash

source_pack python/sisl.bash
source_pack python/sisl-dev.bash
source_pack python/ipi-dev.bash

source_pack python/orthopy.bash
source_pack python/quadpy.bash

source_pack python/symengine.bash

# Other scikit-programs
source_pack python/scikit-learn.bash
source_pack python/scikit-optimize.bash
#source_pack python/scikit-nano.bash
source_pack python/scikit-image.bash

# Later versions of numba
source_pack python/llvmlite.bash
source_pack python/numba.bash

# Physics related python modules
source_pack python/inelastica.bash
source_pack python/inelastica-dev.bash

source_pack python/qutip.bash # [numpy,scipy,cython,matplotlib]
source_pack python/gpaw-setups.bash
source_pack python/ase.bash
source_pack python/gpaw.bash
source_pack python/hotbit.bash
source_pack python/sgdml.bash

source_pack python/pybinding.bash
source_pack python/pythtb.bash
source_pack python/phonopy.bash
source_pack python/phono3py.bash

# Some QC codes
source_pack python/biopython.bash
source_pack python/pyquante.bash
source_pack python/pyquante2.bash
source_pack python/cclib.bash

source_pack python/vtk.bash
source_pack python/mfix.bash
source_pack python/rdkit.bash


source_pack python/openmm.bash

# made for kwant
source_pack python/tinyarray.bash
source_pack python/kwant.bash
