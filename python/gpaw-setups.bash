# Add the installation of the gpaw setups
for v in 0.5.3574 0.6.6300 0.8.7929 0.9.9672 ; do
    
    tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
    add_package http://wiki.fysik.dtu.dk/gpaw-files/gpaw-setups-$v.tar.gz
    
    pack_set --host-reject "ntch-2857"
    if [ "$v" != "0.9.9672" ]; then
	pack_set --host-reject "zeroth"
    fi
    pack_set -s $IS_MODULE
    
    pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)

    pack_set --module-opt "--set-ENV GPAW_SETUP_PATH=$(pack_get --install-prefix)"
        
    pack_set --install-query $(pack_get --install-prefix)/
    pack_set --command "mkdir -p $(pack_get --install-prefix)"
    pack_set --command "cp -r ./* $(pack_get --install-prefix)/"
    
done
