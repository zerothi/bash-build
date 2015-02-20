add_package --directory dftd3.3.0.2 \
    http://www.student.dtu.dk/~nicpa/packages/dftd3_3.0.2.tar.gz

pack_set --host-reject ntch
pack_set --host-reject zerothi
pack_set --module-opt "--lua-family dftd3"

pack_set --install-query $(pack_get --prefix)/bin/dftd3

pack_set --command "rm pars.f"
o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-pars.f
mywget http://www.thch.uni-bonn.de/tc/downloads/DFT-D3/data/pars.f $o
pack_set --command "cp $o pars.f"

pack_set --command "sed -i '1 a\
FC      = $FC\n\
CC      = $CC\n\
LINKER  = $FC\n\
PREFLAG = -E -P \n\
CCFLAGS = $FCFLAGS -DLINUX \n\
FFLAGS  = $FCFLAGS \n\
LFLAGS  = \n' Makefile"

pack_set --command "sed -i -e 's/^[[:space:]]*OSTYPE/#OSTYPE/gi' Makefile"

# Make commands
pack_set --command "make"

# Install the package
pack_set --command "mkdir -p $(pack_get --prefix)/bin"
pack_set --command "cp dftd3 $(pack_get --prefix)/bin/"

pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --mod-req)) \
    -L $(pack_get --alias)
