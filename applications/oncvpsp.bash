for v in 3.3.1 ; do
add_package -archive oncvpsp-$v.tar http://www.mat-simresearch.com/oncvpsp-$v.tar.gz

pack_set -install-query $(pack_get -prefix)/bin/oncvpsp.x

# Currently oncvpsp only works for 3.X
_xc_v=3
pack_set -module-requirement libxc[$_xc_v]

pack_set -module-opt "-lua-family oncvpsp"

file=make.inc
pack_cmd "echo '# Placeholder' > $file"
pack_cmd "sed -i '$ a\
F77 = $FC\n\
F90 = $FC\n\
CC = $CC\n\
FCCPP = $CC -E -P\n\
FLINKER = \$(F90)\n\
FCCPPFLAGS = -ansi -DLIBXC_VERSION=${_xc_v//./}\n\
FFLAGS = $FFLAGS $(list -INCDIRS libxc[$_xc_v])\n\
CFLAGS = $CFLAGS $(list -INCDIRS libxc[$_xc_v])\n\
OBJS_LIBXC = functionals.o exc_libxc.o\n\
LIBS = $(list -LD-rp libxc[$_xc_v]) $(pack_get -lib[f90] libxc[$_xc_v])\n' $file"

if $(is_c intel) ; then    
    # Added ifcore library to complie
    pack_cmd "sed -i '$ a\
    LIBS += -mkl' $file"
    
else
    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    pack_cmd "sed -i '$ a\
LIBS += $(list -LD-rp ++$la) $(pack_get -lib $la)' $file"

fi

# Make commands
pack_cmd "make"
pack_cmd "mkdir -p $(pack_get -prefix)/bin"
pack_cmd "cp -p src/*.x $(pack_get -prefix)/bin"
pack_cmd "cp tests/data/TEST.report $(pack_get --prefix)/"

done
