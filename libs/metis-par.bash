add_package http://glaros.dtc.umn.edu/gkhome/fetch/sw/parmetis/parmetis-4.0.2.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --host-reject surt --host-reject thul

pack_set --install-query $(pack_get --install-prefix)/lib/libparmetis.a

pack_set --module-requirement openmpi

# Make commands 
pack_set --command "sed -i -e 's/^\(cputype\).*/\1 = unknown/' Makefile"
pack_set --command "sed -i -e 's/^\(systype\).*/\1 = linux/' Makefile"
pack_set --command "sed -i -e 's/^\(cputype\).*/\1 = unknown/' metis/Makefile"
pack_set --command "sed -i -e 's/^\(systype\).*/\1 = linux/' metis/Makefile"
pack_set --command "sed -i -e 's/^\(cc\).*/\1 = $CC/' metis/Makefile"

# Defaults to 32 bits information within METIS...
pack_set --command "sed -i -e 's/\(define IDXTYPEWIDTH\).*/\1 32/' metis/include/metis.h"
pack_set --command "sed -i -e 's/\(define REALTYPEWIDTH\).*/\1 32/' metis/include/metis.h"
pack_set --command "cd metis"
pack_set --command "make config prefix=$(pack_get --install-prefix)"
pack_set --command "cd build/linux-unknown"
pack_set --command "make"
pack_set --command "make install"
pack_set --command "cd ../../../"
pack_set --command "make config prefix=$(pack_get --install-prefix)"
pack_set --command "cd build/linux-unknown"
pack_set --command "make"
pack_set --command "make install"



