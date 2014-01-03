unset tmp 
function tmp {
    add_package \
	--build generic \
       	--no-default-modules \
	--package openmx/pseudo \
	--version $1 \
	http://www.openmx-square.org/openmx$(pack_get --version openmx).tar.gz

    pack_set -s $IS_MODULE
    pack_set --host-reject ntch-l
    pack_set --module-opt "--lua-family openmx-pseudos"
    pack_set --command "mkdir -p $(dirname $(pack_get --install-prefix))"
    pack_set --command "rm -rf $(pack_get --install-prefix)"
    # The file permissions are not expected to be correct (we correct them
    # here)
    pack_set --command "mv DFT_DATA13/$1 $(pack_get --install-prefix)"
    pack_set --command "chmod 0644 $(pack_get --install-prefix)/*.$2"
    pack_set --module-opt "--set-ENV OPENMX_PSEUDO=$(pack_get --install-prefix)"
}

tmp PAO pao
pack_set --install-query $(pack_get --install-prefix)/H5.0.pao
pack_install

tmp VPS vps
pack_set --install-query $(pack_get --install-prefix)/H_CA13.vps
pack_install

unset tmp