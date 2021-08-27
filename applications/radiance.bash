add_package -directory ray -version 5.3 -package radiance \
	    https://www.radiance-online.org/download-install/radiance-source-code/latest-release/rad5R3all.tar.gz

pack_set -s $IS_MODULE

pack_set -install-query $(pack_get -prefix)/bin/rad

pack_set -module-opt "-lua-family radiance"

pack_set -build-mod-req build-tools
pack_set -mod-req gen-libpng


_prefix=$(pack_get -prefix)
pack_cmd "mkdir -p $_prefix/bin"
pack_cmd "mkdir -p $_prefix/lib"
pack_cmd "mkdir -p $_prefix/lib/meta"
pack_cmd "mkdir -p $_prefix/lib/lib"

# Clean using the shipped makefile
pack_cmd "./makeall clean"

# Fix shipped library build
pack_cmd "mkdir -p src/px/tiff/lib"
pack_cmd "pushd src/px/tiff ; make distclean ; ./configure CC='$CC' CXX='$CXX' CFLAGS='$CFLAGS' --prefix=$(pack_get -prefix) ; popd"

pack_cmd "cp -f src/*/*.{cal,tab,hex,dat} $_prefix/lib"
pack_cmd "cp -f lib/*.{cal,tab,hex,hdr,fnt,oct,rad,rtm,dat} $_prefix/lib"
pack_cmd "cp -f lib/meta/*.* $_prefix/lib/meta/"
pack_cmd "cp -f lib/lib/*.* $_prefix/lib/lib/"

# Loop directories
for d in common rt meta cv gen ot px hd util cal
do
    # Linux == IBMPC, MacOS X == Intel
    pack_cmd "pushd src/$d"
    pack_cmd "make ARCH=IBMPC MACH='-Dlinux -D_FILE_OFFSET_BITS=64 -DNOSTEREO' COMPAT='strlcpy.o'" \
	     "OPT='$CFLAGS' CC=$CC CXX=$CXX INSTDIR=$_prefix/bin LIBDIR=$_prefix/lib -f Rmakefile install"
    pack_cmd "popd"
done

pack_set -module-opt "-prepend-ENV RAYPATH=$(pack_get -prefix)/lib"
