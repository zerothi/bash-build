# apt-get libpng libjpeg-dev libtiff5-dev libpng12-dev
add_package --archive povray-3.7.0.0.tar.gz \
    https://github.com/POV-Ray/povray/archive/v3.7.0.0.tar.gz
#    http://www.povray.org/ftp/pub/povray/Old-Versions/Official-3.62/Unix/povray-3.6.1.tar.bz2

pack_set -s $IS_MODULE -s $CRT_DEF_MODULE

pack_set --install-query $(pack_get --prefix)/bin/povray

pack_set --module-opt "--lua-family povray"

pack_set --mod-req zlib
pack_set --mod-req boost

pack_set --command "cd unix"

# create configure
pack_set --command "module load build-tools"
pack_set --command "./prebuild.sh"
# This fixes build on debian >=7
pack_set --command "cd .. ; automake --add-missing ; cd unix"
pack_set --command "./prebuild.sh"
pack_set --command "cd .."

pack_set --command "./configure --with-boost-libdir=$(pack_get -LD boost)" \
	--command-flag "COMPILED_BY='Nick Papior Andersen <nickpapior@gmail.com>'" \
	--command-flag "--prefix=$(pack_get --prefix) LIBS=-lboost_system"

pack_set --command "make"
pack_set --command "make install"

## install commands... (this will install the non-GUI version)
#pack_set --command "printf '%s%s\n' 'U' '$(pack_get --prefix)' | ./install -no-arch-check"
