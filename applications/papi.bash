# There are bugs in 5.6.0 with 8.2.0 compiler
add_package http://icl.utk.edu/projects/papi/downloads/papi-5.6.0.tar.gz

pack_set --host-reject $(get_hostname)
pack_set --module-requirement build-tools

pack_set --install-query $(pack_get --prefix)/lib/libpapi.so

pack_cmd "cd src"
pack_cmd "./configure --prefix=$(pack_get --prefix)"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
