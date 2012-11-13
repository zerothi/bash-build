tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
add_package http://downloads.sourceforge.net/project/scipy/scipy/0.11.0/scipy-0.11.0.tar.gz

pack_set -s $IS_MODULE

pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$tmp/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/$(pack_get --alias)

pack_set --module-requirement $(get_parent) \
    --module-requirement numpy

# Check for Intel MKL or not
tmp=$(get_c)
if [ "${tmp:0:5}" == "intel" ]; then
    tmp=$(pack_get --alias)-$(pack_get --version).site.cfg
    cat << EOF > $tmp
[DEFAULT]
library_dirs = $(pack_get --install-prefix $(get_parent))/lib:$(pack_get --install-prefix numpy)/lib/python$pV/site-packages/numpy/core/:/usr/local/lib:/usr/lib64:
include_dirs = $(pack_get --install-prefix numpy)/lib/python$pV/site-packages/numpy/core/include/numpy:$(pack_get --install-prefix $(get_parent))/include
[mkl]
library_dirs = $MKL_PATH/lib/intel64/
mkl_libs = mkl_def, mkl_intel_lp64, mkl_intel_thread, mkl_core, mkl_mc 
lapack_libs = mkl_lapack95_lp64
include_dirs = $MKL_PATH/include/intel64/lp64/
EOF
    pack_set --command "cp $(pwd)/$tmp site.cfg"
    pack_set --command "rm $(pwd)/$tmp"

    pack_set --command "$(get_parent_exec) setup.py build" \
	--command-flag "--compiler=intelem" \
	--command-flag "--fcompiler=intelem" 
elif [ "${tmp:0:3}" == "gnu" ]; then
    # Add requirements when creating the module
    pack_set --module-requirement atlas

    pack_set --command "$(get_parent_exec) setup.py build" \
	--command-flag "--compiler=unix" \
	--command-flag "--fcompiler=gnu95" 
fi

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

pack_install