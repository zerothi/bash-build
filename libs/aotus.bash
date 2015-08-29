v=0.1
add_package \
    --archive aotus-$v.tar.gz \
    https://github.com/zerothi/aotus/archive/$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libaotus.a

pack_cmd "echo '# INITIAL' > arch.make"
pack_cmd "sed -i '1 a\
CC = $CC\n\
FC = $FC\n\
LUA_DIR = $(pack_get --prefix lua)\n\
CFLAGS = $CFLAGS\n\
FCFLAGS = $FCFLAGS\n\
.f90.o:\n\
\t\$(FC) -c \$(FCFLAGS) \$(INC) \$<\n\
.F90.o:\n\
\t\$(FC) -c \$(FCFLAGS) \$(INC) \$<\n\
.c.o:\n\
\t\$(CC) -c \$(CFLAGS) \$(INC) \$<\n' arch.make"

pack_cmd "make liball"
