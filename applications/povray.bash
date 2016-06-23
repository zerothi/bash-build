# apt-get libpng libjpeg-dev libtiff5-dev libpng12-dev
build=$(build_get --default-build)
if $(is_c gnu) ; then
    # There is a build error when using gcc-6 >
    # We thus re-use the generic build and skip the dependencies
    # with the gcc-6 package.
    if [[ $(vrs_cmp $(pack_get --version gcc) 6) -ge 0 ]]; then
        build=generic
    fi
fi

add_package --build $build --archive povray-3.7.0.0.tar.gz \
    https://github.com/POV-Ray/povray/archive/v3.7.0.0.tar.gz
#    http://www.povray.org/ftp/pub/povray/Old-Versions/Official-3.62/Unix/povray-3.6.1.tar.bz2

pack_set -s $IS_MODULE -s $CRT_DEF_MODULE

pack_set --install-query $(pack_get --prefix)/bin/povray

pack_set --module-opt "--lua-family povray"

if [[ "$build" == "generic" ]]; then
    pack_set --mod-req gen-zlib
    pack_set --mod-req gen-boost
else
    pack_set --mod-req zlib
    pack_set --mod-req boost
fi

pack_cmd "cd unix"

# create configure
pack_cmd "module load build-tools"
pack_cmd "./prebuild.sh"
# This fixes build on debian >=7
pack_cmd "cd .. ; automake --add-missing ; cd unix"
pack_cmd "./prebuild.sh"
pack_cmd "cd .."

if [[ "$build" == "generic" ]]; then
    pack_cmd "./configure --with-boost-libdir=$(pack_get -LD gen-boost)" \
	     "COMPILED_BY='Nick R. Papior <nickpapior@gmail.com>'" \
	     "--prefix=$(pack_get --prefix) LIBS=-lboost_system"
else
    pack_cmd "./configure --with-boost-libdir=$(pack_get -LD boost)" \
	     "COMPILED_BY='Nick R. Papior <nickpapior@gmail.com>'" \
	     "--prefix=$(pack_get --prefix) LIBS=-lboost_system"
fi

pack_cmd "make"
pack_cmd "make install"

## install commands... (this will install the non-GUI version)
#pack_cmd "printf '%s%s\n' 'U' '$(pack_get --prefix)' | ./install -no-arch-check"
