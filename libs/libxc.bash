# abinit has specific link to 2.2.3
for v in 2.2.3 3.0.1 4.2.3
do
if [[ $(vrs_cmp $v 3.0) -ge 0 ]]; then
   add_package http://www.tddft.org/programs/octopus/download/libxc/$v/libxc-$v.tar.gz
else
   add_package http://www.tddft.org/programs/octopus/download/libxc/libxc-$v.tar.gz
fi
pack_set -lib -lxcf90 -lxc
pack_set -lib[c] -lxc
pack_set -lib[f03] -lxcf03 -lxc

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --LD)/libxc.a

pack_cmd "../configure" \
	 "--enable-shared" \
	 "--prefix=$(pack_get --prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > libxc.test 2>&1 ; echo 'forced'"
pack_cmd "make install"
pack_store libxc.test
pack_store testsuite/test-suite.log libxc.test-suite.log

done

