add_package --directory dftd3.3.2.0 \
    http://www.student.dtu.dk/~nicpa/packages/dftd3_3.2.0.tar.gz

pack_set --host-reject ntch
pack_set --module-opt "--lua-family dftd3"

pack_set --install-query $(pack_get --prefix)/bin/dftd3

#pack_cmd "rm pars.f"
#o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-pars.f
#dwn_file http://www.thch.uni-bonn.de/tc/downloads/DFT-D3/data/pars.f $o
#pack_cmd "cp $o pars.f"

pack_cmd "sed -i '1 a\
FC      = $FC\n\
CC      = $CC\n\
LINKER  = $FC\n\
PREFLAG = -E -P \n\
CCFLAGS = $FCFLAGS -DLINUX \n\
FFLAGS  = $FCFLAGS \n\
LFLAGS  = \n' Makefile"

pack_cmd "sed -i -e 's/^[[:space:]]*OSTYPE/#OSTYPE/gi' Makefile"

# Make commands
pack_cmd "make"

# Install the package
pack_cmd "mkdir -p $(pack_get --prefix)/bin"
pack_cmd "cp dftd3 $(pack_get --prefix)/bin/"
