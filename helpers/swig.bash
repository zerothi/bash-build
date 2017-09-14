add_package --build generic http://prdownloads.sourceforge.net/swig/swig-3.0.12.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --module-requirement pcre

pack_set --install-query $(pack_get --prefix)/bin/swig

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix $(pack_get --prefix)" \
	 "--without-octave" \
	 "--without-java" \
	 "--without-android" \
	 "--without-guile" \
	 "--without-ruby" \
	 "--without-ocaml" \
	 "--without-php" \
	 "--without-pike" \
	 "--without-mzscheme" \
	 "--without-chicken" \
	 "--without-lua" \
	 "--without-r" \
	 "--without-go" \
	 "--without-d"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
