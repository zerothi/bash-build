# Install grace, which is a simple library
add_package http://www.xcrysden.org/download/xcrysden-1.5.53.tar.gz

pack_set -s $IS_MODULE

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
FFTW3_LIB    = -L$(pack_get --install-prefix fftw-3)/lib -lfftw3

# Include directories
TCL_INCDIR      = 
TK_INCDIR       = 
GL_INCDIR       = 
FFTW3_INCDIR    = -I$(pack_get --install-prefix fftw-3)/include
EOF
if [ -e /usr/include/tcl8.5 ]; then
    cat <<EOF >> $tmp_file
TCL_INCDIR      = -I/usr/include/tcl8.5
EOF
fi

# Install commands that it should run
pack_set --command "cp $(pwd)/$tmp_file Make.sys"
pack_set --command "make xcrysden"
pack_set --command "prefix=$(pack_get --install-prefix) make install"

pack_install

old_path=$(get_module_path)
set_module_path $install_path/modules-npa-apps

tmp_load=""
for cmd in $(pack_get --module-requirement) ; do
    tmp_load="$tmp_load -L \"$(pack_get --module-name $cmd)\""
done

create_module \
    -n "\"Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)\"" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version).$(get_c) \
    -P "/directory/should/not/exist" $tmp_load \
    -L $(pack_get --module-name)

set_module_path $old_path
