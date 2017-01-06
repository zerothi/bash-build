add_package --build generic \
	    --package conda --version 3 \
	    https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh

pack_set --install-query $(pack_get --prefix)/bin/conda

pack_set -s $IS_MODULE -s $CRT_DEF_MODULE

pack_cmd "bash $(pack_get --archive) -b -p $(pack_get --prefix)"
