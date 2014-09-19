add_package http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-5.1.0.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --library-path)/libmetis.a

if [ $(pack_installed cmake) -eq 1 ]; then
    pack_set --command "module load $(pack_get --module-name cmake)"
fi

# Make commands
pack_set --command "sed -i -e 's/^cputype.*/cputype = unknown/' Makefile"
pack_set --command "sed -i -e 's/^systype.*/systype = linux/' Makefile"
pack_set --command "sed -i -e 's/^cc.*/cc = $CC/' Makefile"
# Defaults to 32 bits information within METIS...
pack_set --command "sed -i -e 's/\(define IDXTYPEWIDTH\).*/\1 32/' include/metis.h"
pack_set --command "sed -i -e 's/\(define REALTYPEWIDTH\).*/\1 32/' include/metis.h"
pack_set --command "make config prefix=$(pack_get --install-prefix)"
pack_set --command "cd build/linux-unknown"
pack_set --command "make"
pack_set --command "make install"


if [ $(pack_installed cmake) -eq 1 ]; then
    pack_set --command "module unload $(pack_get --module-name cmake)"
fi

