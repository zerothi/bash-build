add_package -package atom -version 4.2.7.100 \
	    https://departments.icmab.es/leem/siesta/Pseudopotentials/Code/atom-4.2.7-100.tgz

pack_set -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -prefix)/bin/atom

pack_set -module-requirement libgridxc
# Although a utility requires netcdf we don't compile it.
# We prefer the ASCII files and binary files.

pack_cmd "echo '# arch.make' > arch.make"
pack_cmd "sed -i -e '$ a\
XMLF90_ROOT = $(pack_get -prefix xmlf90)\n\
GRIDXC_ROOT = $(pack_get -prefix libgridxc)\n\
include \$(XMLF90_ROOT)/share/org.siesta-project/xmlf90.mk\n\
include \$(GRIDXC_ROOT)/share/org.siesta-project/gridxc_dp.mk\n\
FC = $FC \n\
FFLAGS = $FFLAGS \n\
LDFLAGS = \n\
AR = $AR\n\
RANLIB = $RANLIB \n\
.F.o:\n\
\t\$(FC) -c \$(FFLAGS) \$(INCFLAGS) \$(FPPFLAGS) \$< \n\
.F90.o:\n\
\t\$(FC) -c \$(FFLAGS) \$(INCFLAGS) \$(FPPFLAGS) \$< \n\
.f.o:\n\
\t\$(FC) -c \$(FFLAGS) \$(INCFLAGS) \$<\n\
.c.o:\n\
\t\$(CC) -c \$(CFLAGS) \$(INCFLAGS) \$(FPPFLAGS) \$<\n\
.f90.o:\n\
\t\$(FC) -c \$(FFLAGS) \$(INCFLAGS) \$<\n\
\n' arch.make"

pack_cmd "make"

pack_cmd "mkdir -p $(pack_get -prefix)/bin/"
pack_cmd "cp atm $(pack_get -prefix)/bin/"

pack_cmd "cd Util ; ln -s ../arch.make"
pack_cmd "$FC -o $(pack_get -prefix)/bin/vpsa2bin vpsa2bin.f $FFLAGS"
pack_cmd "$FC -o $(pack_get -prefix)/bin/vpsb2asc vpsb2asc.f $FFLAGS"
pack_cmd "cd $(pack_get -prefix)/bin/ ; ln -s atm atom"


