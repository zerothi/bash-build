add_package http://ftp.gnome.org/pub/GNOME/sources/pygtk/2.24/pygtk-2.24.0.tar.bz2

pack_set -s $IS_MODULE

pack_set --host-reject surt --host-reject muspel \
    --host-reject slid --host-reject ntch

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/$(lc $(pack_get --alias))

# This module requires a lot of modules:
#  GLIB >= 2.8.0
#  pygobject-2.0 >= 2.21.3

# Install commands that it should run
pack_set --command "./configure CC='$CC $CFLAGS' CXX='$CXX $CFLAGS'" \
    --command-flag "CPP='$CC -E' CXXCPP='$CXX -E'" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

pack_set --command "make"
pack_set --command "make install"
    
