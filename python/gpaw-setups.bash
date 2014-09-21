[ "x${pV:0:1}" == "x3" ] && return 0

# Add the installation of the gpaw setups
for v in 0.8.7929 0.9.9672 0.9.11271 ; do
    add_package --build generic \
	http://wiki.fysik.dtu.dk/gpaw-files/gpaw-setups-$v.tar.gz
    
    pack_set --host-reject ntch
    if [ "$v" != "0.9.11271" ]; then
	pack_set --host-reject zeroth
    fi
    pack_set -s $IS_MODULE

    pack_set --module-opt "--lua-family gpaw-setups"
    
    pack_set --module-opt "--set-ENV GPAW_SETUP_PATH=$(pack_get --prefix)"
        
    pack_set --install-query $(pack_get --prefix)/
    pack_set --command "mkdir -p $(pack_get --prefix)"
    pack_set --command "cp -r ./* $(pack_get --prefix)/"
    
done
