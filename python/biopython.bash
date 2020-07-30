v=1.77
add_package -version $v \
        -package biopython \
        -directory biopython-biopython-${v//./} \
	    https://github.com/biopython/biopython/archive/biopython-${v//./}.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -module-requirement numpy

pack_set -install-query $(pack_get -prefix)/lib/python$pV/site-packages/Bio

pack_cmd "mkdir -p $(pack_get -prefix)/lib/python$pV/site-packages/"

pack_cmd "pip install $pip_install_opts $(list -p '--global-option ' build ${pNumpyInstallC}) --prefix=$(pack_get -prefix) ."
