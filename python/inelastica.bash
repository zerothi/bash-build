v=1.3.7
add_package -package Inelastica \
	    -archive inelastica-$v.tar.gz \
	    https://github.com/tfrederiksen/inelastica/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -module-opt "-lua-family inelastica"

pack_set -install-query $(pack_get -prefix)/bin/Phonons

pack_set -module-requirement scipy \
	 -module-requirement netcdf4py


pack_cmd "unset LDFLAGS && $_pip_cmd . --prefix=$(pack_get -prefix)"


