[ "x${pV:0:1}" == "x3" ] && return 0

v=1.9.2
add_package \
    --build generic \
    --no-default-modules \
    --package vmd-python \
    --version $v \
    http://www.ks.uiuc.edu/Research/vmd/vmd-$v/files/final/vmd-$v.src.tar.gz

pack_set -s $IS_MODULE -s $CRT_DEF_MODULE

pack_set --module-opt "--lua-family vmd"

# Force the named alias
pack_set --directory vmd-$(pack_get --version)

pack_set --install-query $(pack_get --prefix)/bin/vmd

pack_set --mod-req numpy
pack_set --mod-req netcdf-serial

# Locate the tcl.h file (we allow 8.[4-7])
tcl_inc=
for tv in 8.7 8.6 8.5 8.4 ; do
    if [[ -e /usr/include/tcl$tv/tcl.h ]]; then
	tcl_inc=-I/usr/include/tcl$tv
	tcl_lib=-ltcl$tv
	break
    fi
done
# If we cannot easily find it, skip it...
[[ -z "$tcl_inc" ]] && pack_set --host-reject $(get_hostname)

pack_cmd "mkdir -p $(pack_get --prefix)/lib/plugins"

cdf_inc="$(list -INCDIRS ++netcdf-serial)"
cdf_lib="$(list --LD-rp ++netcdf-serial)"
cdf_libs="-lnetcdf -lhdf5_hl -lhdf5 -lz"

add_flags="NETCDFINC='$cdf_inc'"
add_flags="$add_flags NETCDFLIB='$cdf_lib'"
add_flags="$add_flags NETCDFLDFLAGS='$cdf_libs'"
add_flags="$add_flags TCLINC=$tcl_inc TCLLIB=-L/usr/lib"
add_flags="$add_flags TCLLDFLAGS='$tcl_lib'"
add_flags="$add_flags PLUGINDIR=$(pack_get --prefix)/lib/plugins"

# Fix correct placement of directory
pack_cmd "mv ../plugins ./"
# Compile plugins
pack_cmd "cd plugins"
pack_cmd "$add_flags make LINUXAMD64"
pack_cmd "$add_flags make LINUXAMD64 distrib"
pack_cmd "cd .."

# Correct python library version
pack_cmd "sed -i -e 's:lpython2.5:lpython$pV:g' configure"

# Correct add_flags
add_flags="${add_flags//TCLINC/TCL_INCLUDE_DIR}"
add_flags="${add_flags//TCLLIB/TCL_LIBRARY_DIR}"
add_flags="${add_flags//NETCDFINC/NETCDF_INCLUDE_DIR}"
add_flags="${add_flags//NETCDFLIB/NETCDF_LIBRARY_DIR}"
add_flags="${add_flags//NETCDFLDFLAGS/NETCDF_LIBS}"

# Delete references to flags for libs
add_flags="${add_flags//-I/}"
add_flags="${add_flags//-L/}"

# Correct plugin-directory
pack_cmd "sed -i -e 's:^\(\$plugin_dir\).*:\1 = \"$(pack_get --prefix)/lib/plugins\";:' configure"
pack_cmd "sed -i -e 's:^\(\$netcdf_include\).*:\1 = \"$cdf_inc\";:' configure"
pack_cmd "sed -i -e 's:^\(\$netcdf_library\).*:\1 = \"$cdf_lib\";:' configure"
pack_cmd "sed -i -e 's:^\(\$netcdf_libs\).*:\1 = \"$cdf_libs\";:' configure"
add_flags="$add_flags VMDEXTRALIBS='$cdf_lib $cdf_libs'"
unset cdf_inc
unset cdf_lib
unset cdf_libs

pack_cmd "VMDINSTALLBINDIR=$(pack_get --prefix)/bin" \
    "VMDINSTALLLIBRARYDIR=$(pack_get --LD)" \
    "PYTHON_INCLUDE_DIR=$(pack_get --prefix python)/include/python$pV" \
    "PYTHON_LIBRARY_DIR=$(pack_get --LD python)/python$pV/config" \
    "NUMPY_INCLUDE_DIR=$(pack_get --LD numpy)/python$pV/site-packages/numpy/core/include" \
    "NUMPY_LIBRARY_DIR=$(pack_get --LD numpy)/python$pV/site-packages/numpy/core/lib" \
    "$add_flags ./configure" \
    "LINUXAMD64 COLVARS TK TCL PTHREADS OPENGL OPENGLPBUFFER XINPUT CONTRIB PYTHON NUMPY NOSILENT"
# tried: FLTK

# Make commands
pack_cmd "cd src"
pack_cmd "make veryclean ; $add_flags make"
pack_cmd "make install"
