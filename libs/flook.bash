v=0.5
add_package \
    --archive flook-$v.tar.gz \
    https://github.com/ElectronicStructureLibrary/flook/archive/$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libflookall.a

if [[ $(pack_installed lua) -ne 1 ]]; then
    pack_set --host-reject $(get_hostname)
fi

# First download aotus
o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-aotus.tar.gz
av=0.2
dwn_file https://github.com/zerothi/aotus/archive/$av.tar.gz $o
pack_cmd "rm -rf aotus"
pack_cmd "tar xfz $o ; mv aotus-$av aotus"

# Compile
pack_cmd "echo '# INITIAL' > arch.make"
pack_cmd "sed -i '1 a\
CC = $CC\n\
FC = $FC\n\
LUA_DIR = $(pack_get --prefix lua)\n\
INC += -I\$(LUA_DIR)/include \n\
CFLAGS = $CFLAGS\n\
FCFLAGS = $FCFLAGS\n\
.f90.o:\n\
\t\$(FC) -c \$(FCFLAGS) \$(INC) \$<\n\
.F90.o:\n\
\t\$(FC) -c \$(FCFLAGS) \$(INC) \$<\n\
.c.o:\n\
\t\$(CC) -c \$(CFLAGS) \$(INC) \$<\n' arch.make"

pack_cmd "make liball"

pack_cmd "mkdir -p $(pack_get --prefix)/include"
pack_cmd "mkdir -p $(pack_get --prefix)/lib"

pack_cmd "cp libflookall.a $(pack_get --prefix)/lib/"
pack_cmd "cp src/*.mod $(pack_get --prefix)/include/"
