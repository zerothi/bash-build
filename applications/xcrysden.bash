# Requirements:
#  libglu1-mesa-dev
#  mesa-common-dev
#  lesstif2-dev
#  tk8.5-dev
#  libxmu-headers

add_package http://www.xcrysden.org/download/xcrysden-1.5.53.tar.gz

pack_set -s $IS_MODULE

pack_set $(list --prefix "--host-reject " surt muspel slid a0 b0 c0 d0 g0 m0 n0 q0 p0)

pack_set --install-query $(pack_get --install-prefix)/bin/xcrysden

pack_set --module-opt "--lua-family xcrysden"

pack_set --module-requirement fftw-3

tmp=Make.sys
pack_set --command "echo '# NPA-script' > $tmp"

pack_set --command "sed -i '1 a\
MAKE = make \n\
CFLAGS = $CFLAGS\n\
CC     = $CC \n\
#LDLIB  = -ldl\n\
MATH   = -lm\n\
\n\
FFLAGS = $FCFLAGS\n\
FC     = $FC \n\
\n\
# X-libraries & include files\n\
X_LIB     = -lXmu -lX11 \n\
X_INCDIR  = \n\
\n\
TCL_LIB      = -ltcl8.5\n\
TK_LIB       = -ltk8.5\n\
GLU_LIB      = -lGLU\n\
GL_LIB       = -lGL\n\
FFTW3_LIB    = $(list --LDFLAGS --Wlrpath fftw-3) -lfftw3\n\
\n\
# Include directories\n\
TCL_INCDIR      = \n\
TK_INCDIR       = \n\
GL_INCDIR       = \n\
FFTW3_INCDIR    = $(list --INCDIRS fftw-3)' $tmp"

if [ -e /usr/include/tcl8.5 ]; then
    pack_set --command "sed -i '$ a\
TCL_INCDIR      = -I/usr/include/tcl8.5 ' $tmp"
fi
if $(is_host thul) ; then
    pack_set --command "sed -i -e 's/8.5/8.4/g' $tmp"
fi

# Install commands that it should run
pack_set --command "make xcrysden"
pack_set --command "prefix=$(pack_get --install-prefix) make install"

# Add the XCRYSDEN TOP DIR env
#pack_set --module-opt "--set-ENV XCRYSDEN_TOPDIR=$(pack_get --install-prefix)"
#pack_set --module-opt "--prepend-ENV PATH=$(pack_get --install-prefix)/scripts"
#pack_set --module-opt "--prepend-ENV PATH=$(pack_get --install-prefix)/util"

pack_install

if [ $(pack_get --installed) -eq 1 ]; then
    create_module \
	--module-path $(build_get --module-path)-npa-apps \
	-n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
	-v $(pack_get --version) \
	-M $(pack_get --alias).$(pack_get --version)/$(get_c) \
	-P "/directory/should/not/exist" \
	$(list --prefix '-L ' $(pack_get --module-requirement)) \
	-L $(pack_get --alias) 
fi
