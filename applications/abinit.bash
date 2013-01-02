add_package http://ftp.abinit.org/abinit-7.0.4.tar.gz

pack_set -s $IS_MODULE

pack_set --host-reject ntch

pack_set --install-query $(pack_get --install-prefix)/bin/abinit

pack_set --module-requirement openmpi

pack_set --command "../configure" \
    --command-flag "--enable-mpi --enable-mpi-io"

# Make commands
pack_set --command "make $(get_make_parallel)"

# Install the package
pack_set --command "mkdir -p $(pack_get --install-prefix)/bin/"
pack_set --command "cp abinit $(pack_get --install-prefix)/bin/"


create_module \
    --module-path $(get_installation_path)/modules-npa-apps \
    -n "\"Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)\"" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(get_default_modules) $(pack_get --module-requirement)) \
    -L $(pack_get --alias)
