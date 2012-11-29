# Install grace, which is a simple library
add_package ftp://ftp.cmbi.ru.nl/pub/molgraph/molden/molden5.0.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/molden

pack_set --command "sed -i -e 's/CC[[:space:]]*=.*/CC = $CC/g' makefile"
pack_set --command "sed -i -e 's/FC[[:space:]]*=.*/FC = $FC/g' makefile"

pack_set --command "mkdir -p $(pack_get --install-prefix)/bin/"

# Make commands
pack_set --command "make $(get_make_parallel) molden"
pack_set --command "cp molden $(pack_get --install-prefix)/bin/"
if [ "$(get_hostname)" != "surt" ] && [ "$(get_hostname)" != "thul" ]; then
    pack_set --command "make $(get_make_parallel) gmolden"
    pack_set --command "cp gmolden $(pack_get --install-prefix)/bin/"
fi

pack_install


create_module \
    --module-path $(get_installation_path)/modules-npa-apps \
    -n "\"Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)\"" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version).$(get_c) \
    -P "/directory/should/not/exist" $(list --prefix '-L ' $(get_default_modules)) \
    $(list --prefix '-L ' --loop-cmd 'pack_get --module-name' $(pack_get --module-requirement)) \
    -L $(pack_get --module-name) 
