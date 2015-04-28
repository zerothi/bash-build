v=0.19
add_package \
    --archive fvar-$v.tar.gz \
    https://github.com/zerothi/fvar/archive/$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/lib/libvardict.a

# Create the arch-make file
file=arch.make
pack_set --command "echo '# Hello' > $file"
pack_set --command "sed -i '1 a\
FC = $FC\n\
FC_SERIAL = $FC\n\
FFLAGS = $FCFLAGS\n\
PP = cpp -E -P -C \n\
AR = $AR\n\
.F90.o:\n\
\t\$(FC) -c \$(INC) \$(FFLAGS) \$(FPPFLAGS) \$< \n\
.f90.o:\n\
\t\$(FC) -c \$(INC) \$(FFLAGS) \$< \n\
' $file"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make test > tmp.test 2>&1"
pack_set_mv_test tmp.test
pack_set --command "mkdir -p $(pack_get --LD)"
pack_set --command "mkdir -p $(pack_get --prefix)/include"
pack_set --command "cp libvardict.a $(pack_get --LD)/"
pack_set --command "cp *.mod $(pack_get --prefix)/include/"
# We also copy the settings file
# Mainly because it is needed for building ncdf library.
pack_set --command "cp settings.sh $(pack_get --prefix)/include/"



