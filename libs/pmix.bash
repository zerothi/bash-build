v=3.1.2
add_package -package pmix \
	    https://github.com/pmix/pmix/releases/download/v$v/pmix-$v.tar.bz2

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# What to check for when checking for installation...
pack_set -install-query $(pack_get -prefix)/bin/mpif90

pack_set -build-mod-req build-tools
pack_set -module-requirement zlib
pack_set -module-requirement hwloc

# Generate the configure command
pack_cmd "pushd ../ ; ./autogen.pl ; popd"

# Install commands that it should run
pack_cmd "../configure" \
	 "--prefix=$(pack_get -prefix)" \
	 "--enable-pmix-binaries" \
	 "--enable-embedded-libevent" \
	 "--with-zlib=$(pack_get -prefix zlib)" \
	 "--with-hwloc=$(pack_get -prefix hwloc)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > pmix.test 2>&1 || echo forced"
pack_store pmix.test
pack_cmd "make install"
