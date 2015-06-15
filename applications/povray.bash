# apt-get libpng
add_package \
    --build generic \
    http://www.povray.org/ftp/pub/povray/Old-Versions/Official-3.62/Unix/povray-3.6.1.tar.bz2

pack_set -s $IS_MODULE -s $CRT_DEF_MODULE

pack_set --install-query $(pack_get --prefix)/bin/povray

pack_set --module-opt "--lua-family povray"

pack_set --command "./configure" \
	--command-flag "COMPILED_BY='Nick Papior Andersen <nickpapior@gmail.com>'" \
	--command-flag "--prefix=$(pack_get --prefix)"

pack_set --command "make"
pack_set --command "make install"

## install commands... (this will install the non-GUI version)
#pack_set --command "printf '%s%s\n' 'U' '$(pack_get --prefix)' | ./install -no-arch-check"
