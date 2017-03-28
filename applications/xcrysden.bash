# Requirements:
#  apt-get install libglu1-mesa-dev mesa-common-dev lesstif2-dev tk8.5-dev libxmu-headers libxmu-dev

add_package http://www.xcrysden.org/download/xcrysden-1.5.60.tar.gz

pack_set --install-query $(pack_get --prefix)/bin/xcrysden

pack_set --module-opt "--lua-family xcrysden"

pack_set --module-requirement fftw-3

tmp=Make.sys
pack_cmd "echo '# NPA-script' > $tmp"

pack_cmd "sed -i '1 a\
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
FFTW3_LIB    = $(list --LD-rp fftw-3) -lfftw3\n\
\n\
# Include directories\n\
TCL_INCDIR      = \n\
TK_INCDIR       = \n\
GL_INCDIR       = \n\
FFTW3_INCDIR    = $(list --INCDIRS fftw-3)' $tmp"

if [[ -e /usr/include/tcl8.5 ]]; then
    pack_cmd "sed -i '$ a\
TCL_INCDIR      = -I/usr/include/tcl8.5 ' $tmp"
elif [[ -e /usr/include/tcl8.6 ]]; then
    pack_cmd "sed -i '$ a\
TCL_INCDIR      = -I/usr/include/tcl8.6 -DUSE_INTERP_RESULT' $tmp"
    pack_cmd "sed -i -e 's/8.5/8.6/g' $tmp"
elif [[ -e /usr/include/tcl8.4 ]]; then
    pack_cmd "sed -i '$ a\
TCL_INCDIR      = -I/usr/include/tcl8.4 ' $tmp"
    pack_cmd "sed -i -e 's/8.5/8.4/g' $tmp"
fi

# Install commands that it should run
pack_cmd "make xcrysden"
pack_cmd "prefix=$(pack_get --prefix) make install"

# Add the XCRYSDEN TOP DIR env
pack_set --module-opt "--set-ENV XCRYSDEN_TOPDIR=$(pack_get --prefix)"
pack_set --module-opt "--prepend-ENV PATH=$(pack_get --prefix)/scripts"
pack_set --module-opt "--prepend-ENV PATH=$(pack_get --prefix)/util"
