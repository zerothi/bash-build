v=0.3
add_package \
    --archive fdict-$v.tar.gz \
    https://github.com/zerothi/fdict/archive/$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/lib/libvardict.a

# Create the arch-make file
file=arch.make
pack_cmd "echo '# Hello' > $file"
pack_cmd "sed -i '1 a\
FC = $FC\n\
FC_SERIAL = $FC\n\
FFLAGS = $FCFLAGS\n\
AR = $AR\n\
.F90.o:\n\
\t\$(FC) -c \$(INC) \$(FFLAGS) \$(FPPFLAGS) \$< \n\
.f90.o:\n\
\t\$(FC) -c \$(INC) \$(FFLAGS) \$< \n\
' $file"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make test > tmp.test 2>&1"
pack_set_mv_test tmp.test
pack_cmd "mkdir -p $(pack_get --LD)"
pack_cmd "mkdir -p $(pack_get --prefix)/include"
pack_cmd "cp libvardict.a $(pack_get --LD)/"
pack_cmd "cp *.mod $(pack_get --prefix)/include/"
# We also copy the settings file
# Mainly because it is needed for building ncdf library.
pack_cmd "cp settings.sh $(pack_get --prefix)/include/"



