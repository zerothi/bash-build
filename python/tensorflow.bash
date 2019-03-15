v=1.13.1
add_package --archive tensorflow-$v.tar.gz \
	    https://github.com/tensorflow/tensorflow/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE
if [[ $(pack_installed bazel[0.21.0]) -ne $_I_INSTALLED ]]; then
    pack_set --host-reject $(get_hostname)
fi

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/site.py

pack_set $(list --prefix ' --module-requirement ' numpy mpi4py)

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages"
_mods="$(pack_get -module-load bazel[0.21.0])"

pack_cmd "module load $_mods"

pack_cmd "PYTHON_BIN_PATH=$(get_parent_exec) \
USE_DEFAULT_PYTHON_LIB_PATH=1 \
TF_ENABLE_XLA=0 \
TF_NEED_OPENCL_SYCL=0 \
TF_NEED_ROCM=0 \
TF_NEED_CUDA=0 \
TF_DOWNLOAD_CLANG=0 \
TF_SET_ANDROID_WORKSPACE=0 \
TF_NEED_MPI=1 MPI_HOME=$(pack_get -prefix mpi) \
PREFIX=$(pack_get -prefix) \
CC_OPT_FLAGS='$CFLAGS' ./configure"
pack_cmd "bazel build --jobs $NPROCS --verbose_failures --config=opt --linkopt='$(list -LD-rp $(pack_get -mod-req-path))' //tensorflow/tools/pip_package:build_pip_package"
pack_cmd "pip install --prefix=$(pack_get -prefix) ./*.whl"

pack_cmd "module unload $_mods"
