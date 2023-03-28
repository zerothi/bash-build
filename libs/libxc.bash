# abinit has specific link to 2.2.3
# 5.0.0 is broken, do not use
# ALWAYS keep the default libxc version in the end
for v in 3.0.1 4.3.4 5.2.3 6.1.0
do
add_package http://www.tddft.org/programs/libxc/down/$v/libxc-$v.tar.gz
pack_set -lib -lxcf03 -lxc
pack_set -lib[c] -lxc
pack_set -lib[f90] -lxcf90 -lxc
pack_set -lib[f03] -lxcf03 -lxc

pack_set -s $IS_MODULE -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --LD)/libxc.a

pack_cmd "../configure" \
	 "--enable-shared" \
	 "--prefix=$(pack_get --prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > libxc.test 2>&1 || echo forced"
pack_cmd "make install"
pack_store libxc.test
pack_store testsuite/test-suite.log libxc.test-suite.log
pack_store testsuite/xc-run_testsuite.log libxc-run.testsuite.log

done

