# Requirements:
#  libglu1-mesa-dev
#  mesa-common-dev
#  lesstif2-dev
#  tk8.5-dev
#  libxmu-headers

add_package http://www.xcrysden.org/download/xcrysden-1.5.53.tar.gz

pack_set -s $IS_MODULE

pack_set $(list --prefix "--host-reject " thul surt a0 b0 c0 d0 g0 m0 n0 q0 p0)

pack_set --install-query $(pack_get --install-prefix)/bin/xcrysden

pack_set --module-requirement fftw-3
tmp_file=$(pack_get --package)-$(pack_get --version).make

cat <<EOF > $tmp_file
MAKE = make
CFLAGS = $CFLAGS
CC     = $CC 
#LDLIB  = -ldl
MATH   = -lm

FFLAGS = $FCFLAGS
FC     = $FC 

# X-libraries & include files
X_LIB     = -lXmu -lX11 
X_INCDIR  = 

TCL_LIB      = -ltcl8.5
TK_LIB       = -ltk8.5
GLU_LIB      = -lGLU
GL_LIB       = -lGL
FFTW3_LIB    = $(list --LDFLAGS --Wlrpath fftw-3) -lfftw3

# Include directories
TCL_INCDIR      = 
TK_INCDIR       = 
GL_INCDIR       = 
FFTW3_INCDIR    = $(list --INCDIRS fftw-3)
EOF
if [ -e /usr/include/tcl8.5 ]; then
    cat <<EOF >> $tmp_file
TCL_INCDIR      = -I/usr/include/tcl8.5
EOF
fi
if $(is_host thul) ; then
    sed -i -e 's/8.5/8.4/g' $tmp_file
fi

# Install commands that it should run
pack_set --command "cp $(pwd)/$tmp_file Make.sys"
pack_set --command "make xcrysden"
pack_set --command "prefix=$(pack_get --install-prefix) make install"

# Add the XCRYSDEN TOP DIR env
#pack_set --module-opt "--set-ENV XCRYSDEN_TOPDIR=$(pack_get --install-prefix)"
#pack_set --module-opt "--prepend-ENV PATH=$(pack_get --install-prefix)/scripts"
#pack_set --module-opt "--prepend-ENV PATH=$(pack_get --install-prefix)/util"

pack_install

if [ $(pack_get --installed) -eq 1 ]; then
    create_module \
	--module-path $(get_installation_path)/modules-npa-apps \
	-n "\"Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)\"" \
	-v $(pack_get --version) \
	-M $(pack_get --alias).$(pack_get --version)/$(get_c) \
	-P "/directory/should/not/exist" \
	$(list --prefix '-L ' $(build_get --default-module) $(pack_get --module-requirement)) \
	-L $(pack_get --alias) 
fi
