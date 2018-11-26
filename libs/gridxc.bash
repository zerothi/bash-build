add_package https://launchpad.net/libgridxc/trunk/0.8/+download/libgridxc-0.8.3.tgz

pack_set -s $IS_MODULE -s $BUILD_DIR

_xc_v=4.2.3
pack_set --module-requirement libxc[$_xc_v]

pack_set --install-query $(pack_get --LD)/libGridXC.a
pack_set --lib -lGridXC

# Install commands that it should run
pack_cmd "sh ../src/config.sh"

pack_cmd "echo '# fortran.mko' > fortran.mk"

pack_cmd "sed -i -e '$ a\
FC_SERIAL = $FC\n\
FC = $FC\n\
FFLAGS = $FFLAGS\n\
AR = $AR\n\
RANLIB = $RANLIB\n\
LDFLAGS = \n\
INC_PREFIX = -I\n\
MOD_PREFIX = -I\n\
MOD_EXT =.mod\n\
LIBXC_ROOT = $(pack_get --prefix libxc[$_xc_v])\n\
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
\n' fortran.mk"

pack_cmd "echo '# Cleaned libxc.mk' > libxc.mk"
pack_cmd "sed -i -e '$ a\
LIBXC_INCFLAGS = -I$(pack_get --prefix libxc[$_xc_v])/include\n\
LIBXC_LIBS = $(list --LD-rp libxc[$_xc_v]) -lxcf90 -lxc\n\
' libxc.mk"

pack_cmd "make WITH_LIBXC=1 $(get_make_parallel) PREFIX=$(pack_get --prefix)"
