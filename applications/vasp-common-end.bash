# Now tmp will hold the makefile name
tmp=makefile.linux_ifc_P4

# Do library installation
# Install the makefile...
pack_set --command "sed -i -e 's:# general.*:\n\
FC=$FC\n\
CC=$CC\n\
CFLAGS=$CFLAGS\n\
FCFLAGS=$FCFLAGS -FI -O0:' $tmp"
pack_set --command "make -f $tmp"
pack_set --command "cd ../vasp.5.3"

# Prepare the installation directory
pack_set --command "mkdir -p $(pack_get --install-prefix)/bin"

# Make commands
# Install the makefile
pack_set --command "sed -i -e 's:# general.*:include ../mymakefile:' $tmp"
pack_set --command "make -f $tmp"
pack_set --command "cp vasp $(pack_get --install-prefix)/bin/vasp"
pack_set --command "make -f $tmp clean"

# Prepare the next installation
pack_set --command "sed -i -e 's:#PLACEHOLDER#.*:CPP += -DNGZHALF :' ../mymakefile"
pack_set --command "make -f $tmp"
pack_set --command "cp vasp $(pack_get --install-prefix)/bin/vaspNGZHALF"
pack_set --command "make -f $tmp clean"

# Prepare the next installation
pack_set --command "sed -i -e 's:NGZHALF:NGZHALF -DwNGZHALF:' ../mymakefile"
pack_set --command "make -f $tmp"
pack_set --command "cp vasp $(pack_get --install-prefix)/bin/vaspGNGZHALF"
pack_set --command "make -f $tmp clean"

pack_install

create_module \
    --module-path $(get_installation_path)/modules-npa-apps \
    -n "\"Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)\"" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(get_default_modules) $(pack_get --module-requirement)) \
    -L $(pack_get --alias)