add_package http://ftp.gnome.org/pub/GNOME/sources/pygtk/2.24/pygtk-2.24.0.tar.bz2

pack_set -s $IS_MODULE

pack_set --host-reject ntch

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/$(lc $(pack_get --alias))

# This module requires a lot of modules:
#  GLIB >= 2.8.0
#  pygobject-2.0 >= 2.21.3

# Install commands that it should run
pack_cmd "./configure CC='$CC $pCFLAGS' CXX='$CXX $pCFLAGS'" \
    "CPP='$CC -E' CXXCPP='$CXX -E'" \
    "--prefix=$(pack_get --prefix)"

pack_cmd "make"
pack_cmd "make install"

