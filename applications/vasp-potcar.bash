unset tmp
function tmp {
    add_package \
	--package vasp \
	--version $2 \
	http://www.student.dtu.dk/~nicpa/packages/VASP-$1.zip
    pack_set -s $IS_MODULE
    pack_set --host-reject ntch
    pack_set --directory VASP
    pack_set --prefix-and-module \
	$(pack_get --alias)/POTCARS/$(pack_get --version)
    pack_set --module-opt "--lua-family vasp-potcar"
    pack_set --command "mkdir -p $(dirname $(pack_get --install-prefix))"
    pack_set --command "rm -rf $(pack_get --install-prefix)"
    pack_set --command "mkdir tmp"
    pack_set --command "cd tmp"
    pack_set --command "tar xfz ../potpaw_$(pack_get --version).t*"
    pack_set --command "cd ../"
    # The file permissions are not expected to be correct (we correct them
    # here)
    pack_set --command "chmod 0644 tmp/*/POTCAR"
    pack_set --command "mv tmp $(pack_get --install-prefix)"
    pack_set --module-opt "--set-ENV POTCARS=$(pack_get --install-prefix)"
    # We only check for one
    pack_set --install-query $(pack_get --install-prefix)/H/POTCAR
    pack_install
}    

for v in 5.3.3 ; do
tmp $v LDA
tmp $v LDA.52
tmp $v PBE
tmp $v PBE.52
done
unset tmp
