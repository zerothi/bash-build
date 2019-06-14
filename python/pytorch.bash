v=1.1.0
add_package -version $v -directory pytorch v$v@https://github.com/pytorch/pytorch.git

pack_set -s $IS_MODULE -s $PRELOAD_MODULE -s $BUILD_TOOLS

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/site.py

pack_set $(list -prefix ' -module-requirement ' numactl numpy mpi eigen llvm[7])

pack_cmd "git submodule init"
pack_cmd "git submodule update --init --recursive"

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"
#pack_cmd "unset LDFLAGS"

tmp_flags=
tmp_flags="$tmp_flags MAX_JOBS=$NPROCS"
tmp_flags="$tmp_flags USE_NUMPY=1"
tmp_flags="$tmp_flags USE_EIGEN=1"
tmp_flags="$tmp_flags USE_CUDA=0"
tmp_flags="$tmp_flags USE_MKLDNN=0"
tmp_flags="$tmp_flags USE_DISTRIBUTED=1"
tmp_flags="$tmp_flags CMAKE_PREFIX_PATH=$(pack_get -prefix)"

pack_cmd "$tmp_flags $(get_parent_exec) setup.py install"
