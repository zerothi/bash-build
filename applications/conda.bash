add_package --build generic-no-version \
	    --package conda \
	    https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh

pack_set --install-query $(pack_get --prefix)/bin/conda

pack_set -s $IS_MODULE -s $CRT_DEF_MODULE

pack_cmd "bash $(pack_get --archive) -b -p $(pack_get --prefix)"


# Simply to use conda and create the envs
add_package conda-env-create.local
pack_set -rem-s $IS_MODULE
pack_set --module-requirement conda
pack_set --directory .

# Do root-only installations
pack_cmd "conda install -y conda anaconda-client conda-build"
pack_cmd "conda upgrade -y conda anaconda-client conda-build"

# Create a python3 environment
pack_cmd "conda create -y --name python3 python=3.5 || echo already there"

