v_wxparaver=4.8.1
v_paraver=4.8.1
v_extrae=3.6.1
v_dimemas=5.4.0

# When compiling extrae it really needs the same MPI library
add_package  --version $v_paraver \
	     --package paraver fake

pack_set -s $IS_MODULE
pack_set --install-query $(pack_get --prefix)/bin

pack_set --command "mkdir -p $(pack_get --prefix)/bin/"


add_package --archive extrae-$v_extrae.tar.gz \
	    https://github.com/bsc-performance-tools/extrae/archive/$v_extrae.tar.gz

pack_set -s $MAKE_PARALLEL -rem-s $CRT_DEF_MODULE -rem-s $IS_MODULE
pack_set --prefix $(pack_get --prefix paraver)
pack_set --install-query $(pack_get --prefix)/bin/extrae-cmd

pack_set --module-requirement build-tools
pack_set --module-requirement mpi
pack_set --module-requirement boost
pack_set --module-requirement unwind

tmp_flags=
if [[ $(pack_installed papi) -eq $_I_INSTALLED ]]; then
    pack_set --module-requirement papi
    tmp_flags="$tmp_flags --with-papi=$(pack_get --prefix papi)"
else
    tmp_flags="$tmp_flags --without-papi"
fi

tmp_flags="$tmp_flags --without-dyninst"

pack_cmd "./bootstrap"
pack_cmd "./configure" \
	 "--enable-openmp" \
	 "--with-binutils=$(pack_get --prefix build-tools)" \
	 "--with-libz=$(pack_get --prefix zlib)" \
	 "--with-unwind=$(pack_get --prefix unwind)" \
	 "--with-boost=$(pack_get --prefix boost)" \
	 "--with-mpi=$(pack_get --prefix mpi)" \
	 "--with-mpi-lib-name=mpi" \
	 "--prefix=$(pack_get --prefix) $tmp_flags"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"




add_package --archive paraver-kernel-$v_paraver.tar.gz \
	    https://github.com/bsc-performance-tools/paraver-kernel/archive/v$v_paraver.tar.gz

pack_set -s $MAKE_PARALLEL -rem-s $CRT_DEF_MODULE -rem-s $IS_MODULE
pack_set --prefix $(pack_get --prefix paraver)

pack_set --module-requirement build-tools
pack_set --module-requirement boost
pack_set --module-requirement paraver

pack_set --install-query $(pack_get --prefix)/bin/paramedir

pack_cmd "./bootstrap"
pack_cmd "./configure" \
	 "--enable-openmp" \
	 "--prefix=$(pack_get --prefix)" \
	 "--with-boost=$(pack_get --prefix boost)" \
	 "--with-extrae=$(pack_get --prefix)"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"



add_package --archive dimemas-$v_dimemas.tar.gz \
	    https://github.com/bsc-performance-tools/dimemas/archive/$v_dimemas.tar.gz

pack_set -s $MAKE_PARALLEL -rem-s $CRT_DEF_MODULE -rem-s $IS_MODULE
pack_set --prefix $(pack_get --prefix paraver)

pack_set --module-requirement build-tools
pack_set --module-requirement boost
if [[ $(pack_installed flex) -eq 1 ]]; then
    pack_cmd "module load $(list -mod-names ++flex)"
fi

pack_set --install-query $(pack_get --prefix)/bin/prv2dim

pack_cmd "./bootstrap"
pack_cmd "./configure" \
	 "--enable-openmp" \
	 "--prefix=$(pack_get --prefix)" \
	 "--with-boost=$(pack_get --prefix boost)"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

if [[ $(pack_installed flex) -eq 1 ]]; then
    pack_cmd "module unload $(list -mod-names ++flex)"
fi




# wxparaver needs to be installed in the same location as paraver
add_package --archive wxparaver-$v_wxparaver.tar.gz \
	    https://github.com/bsc-performance-tools/wxparaver/archive/v$v_wxparaver.tar.gz

pack_set -s $MAKE_PARALLEL -rem-s $CRT_DEF_MODULE -rem-s $IS_MODULE
pack_set --prefix $(pack_get --prefix paraver)

pack_set --module-requirement build-tools
pack_set --module-requirement wxwidgets
pack_set --module-requirement boost
pack_set --module-requirement paraver

pack_set --install-query $(pack_get --prefix)/bin/wxparaver

pack_cmd "./bootstrap"
pack_cmd "./configure" \
	 "--with-openmp" \
	 "--with-wx-prefix=$(pack_get --prefix wxwidgets)" \
	 "--with-boost=$(pack_get --prefix boost)" \
	 "--with-paraver=$(pack_get --prefix)" \
	 "--with-extrae=$(pack_get --prefix)" \
	 "--prefix=$(pack_get --prefix)"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
