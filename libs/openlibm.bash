v=0.6.0
add_package --archive openlibm-$v.tar.gz \
	    https://github.com/JuliaMath/openlibm/archive/v$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libopenlibm.so

# Add requirments when creating the module
pack_set --module-requirement zlib

# Install commands that it should run
pack_cmd "make prefix=$(pack_get --prefix)" \
	 "USEGCC=1" \
	 "AR='$AR'" \
	 "CC='$CC'" \
	 "CFLAGS='$CFLAGS' all"

pack_cmd "make prefix=$(pack_get --prefix) install"
