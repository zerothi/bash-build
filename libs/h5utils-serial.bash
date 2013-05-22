# Then install H5 utils
for p in 1.12.1 ; do

add_package http://ab-initio.mit.edu/h5utils/h5utils-$p.tar.gz

pack_set --alias h5utils-serial

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/bin/h5totxt

# Add requirments when creating the module
pack_set --module-requirement hdf5-serial

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--without-octave" \
    --command-flag "LDFLAGS='$(list --LDFLAGS --Wlrpath zlib hdf5-serial)'"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

done
