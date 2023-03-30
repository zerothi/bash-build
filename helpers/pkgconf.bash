v=1.9.4
add_package -build generic -directory pkgconf-pkgconf-$v \
	https://github.com/pkgconf/pkgconf/archive/refs/tags/pkgconf-$v.tar.gz
pack_set -s $MAKE_PARALLEL -s $BUILD_DIR

pack_set -module-requirement build-tools

pack_set -prefix $(pack_get -prefix build-tools)

pack_set -install-query $(pack_get -prefix)/bin/pkgconf

# Install commands that it should run
pack_cmd "pushd .. ; ./autogen.sh ; popd"
pack_cmd "../configure --prefix $(pack_get -prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

pack_cmd "cd $(pack_get -prefix)/bin ; [ ! -e pkg-config ] && ln -s pkgconf pkg-config"

