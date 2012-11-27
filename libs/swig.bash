add_package http://prdownloads.sourceforge.net/swig/swig-2.0.8.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --host-reject "n-"
pack_set --host-reject "ntch-2857"

pack_set --install-query $(pack_get --install-prefix)/bin/swig
pack_set --module-requirement pcre

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --install-prefix)" \
    --command-flag "--without-octave" \
    --command-flag "--without-java" \
    --command-flag "--without-android" \
    --command-flag "--without-guile" \
    --command-flag "--without-ruby" \
    --command-flag "--without-ocaml" \
    --command-flag "--without-php" \
    --command-flag "--without-pike" \
    --command-flag "--without-mzscheme" \
    --command-flag "--without-chicken" \
    --command-flag "--without-lua" \
    --command-flag "--without-r" \
    --command-flag "--without-go" \
    --command-flag "--without-d"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

pack_install
