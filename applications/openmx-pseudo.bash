unset tmp 
function tmp {
    add_package \
	--build generic \
       	--no-default-modules \
	--package openmx/pseudo \
	--version $1 \
	http://www.openmx-square.org/openmx3.7.tar.gz

    pack_set --host-reject ntch-l --host-reject zerothi
    pack_set --module-opt "--lua-family openmx-pseudos"
    pack_cmd "mkdir -p $(dirname $(pack_get --prefix))"
    pack_cmd "rm -rf $(pack_get --prefix)"
    # The file permissions are not expected to be correct (we correct them
    # here)
    pack_cmd "mv DFT_DATA13/$1 $(pack_get --prefix)"
    pack_cmd "chmod 0644 $(pack_get --prefix)/*.$2"
    pack_set --module-opt "--set-ENV OPENMX_PSEUDO=$(pack_get --prefix)"
}

tmp PAO pao
pack_set --install-query $(pack_get --prefix)/H5.0.pao
pack_install

tmp VPS vps
pack_set --install-query $(pack_get --prefix)/H_CA13.vps
pack_install

unset tmp
