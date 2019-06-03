# Install gnuplot, which is a simple library
for v in 4.6.7 5.2.5 ; do
add_package http://downloads.sourceforge.net/project/gnuplot/gnuplot/$v/gnuplot-$v.tar.gz

pack_set --module-opt "--lua-family gnuplot"

pack_set --mod-req libgd

pack_set --install-query $(pack_get --prefix)/bin/gnuplot

# Install commands that it should run
pack_cmd "./configure --with-gd=$(pack_get --prefix libgd)" \
	 "--prefix $(pack_get --prefix)" \
	 "--with-texdir=$(pack_get --prefix)/"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

done
