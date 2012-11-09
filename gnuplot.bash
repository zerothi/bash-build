# Install gnuplot, which is a simple library
add_package http://downloads.sourceforge.net/project/gnuplot/gnuplot/4.6.1/gnuplot-4.6.1.tar.gz

pack_set -s $IS_MODULE

# The installation directory
pack_set --install-prefix $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/bin/gnuplot

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"


pack_install