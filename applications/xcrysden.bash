# Install grace, which is a simple library
add_package http://www.xcrysden.org/download/xcrysden-1.5.53.tar.gz

pack_set -s $IS_MODULE

pack_set --host-reject surt

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
tmp=$(get_hostname)
if [ "$tmp" == "thul" ]; then
    sed -i -e 's/8.5/8.4/g' $tmp_file
fi

# Install commands that it should run
pack_set --command "cp $(pwd)/$tmp_file Make.sys"
pack_set --command "make xcrysden"
pack_set --command "prefix=$(pack_get --install-prefix) make install"

pack_install

if [ $(pack_get --installed) -eq 1 ]; then
    create_module \
	--module-path $(get_installation_path)/modules-npa-apps \
	-n "\"Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)\"" \
	-v $(pack_get --version) \
	-M $(pack_get --alias).$(pack_get --version)/$(get_c) \
	-P "/directory/should/not/exist" \
	$(list --prefix '-L ' $(pack_get --module-requirement)) \
	-L $(pack_get --alias) 
fi
