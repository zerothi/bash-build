v=1.8.9.1
add_package --build generic \
    --version $v --package doxygen \
    --archive doxygen-Release_${v//./_}.tar.gz \
    https://github.com/doxygen/doxygen/archive/Release_${v//./_}.tar.gz

if $(is_host ntch zero) ; then
    echo "Compiling" > /dev/null
else
    pack_set --host-reject $(get_hostname)
fi

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/doxygen

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
