v=1.13.1
add_package -archive tensorflow-$v.tar.gz \
	    https://github.com/tensorflow/tensorflow/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE
if [[ $(pack_installed bazel[0.21.0]) -ne $_I_INSTALLED ]]; then
    pack_set -host-reject $(get_hostname)
fi

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/site.py

# As per github issue 14428 it seems MPI is not maintained! :(
pack_set $(list -prefix ' -module-requirement ' numpy)

if ! $(is_c gnu) ; then
    pack_set -host-reject $(get_hostname)
fi

pack_cmd "mkdir -p $(pack_get -prefix)/lib/python$pV/site-packages"
_mods="$(pack_get -module-load bazel[0.21.0])"

pack_cmd "module load $_mods"

pack_cmd "sed -i -e 's:\(mnemonic[[:space:]]*=[[:space:]]*\"PythonSwig\"\):\1,use_default_shell_env=True:' tensorflow/tensorflow.bzl"

_envs="GCC_HOST_COMPILER_PATH=$(pack_get -prefix gcc)/bin/gcc"
_envs="$_envs CPU_COMPILER=$(pack_get -prefix gcc)/bin/gcc"

pack_cmd "$_envs PYTHON_BIN_PATH=$(get_parent_exec) \
USE_DEFAULT_PYTHON_LIB_PATH=1 \
TF_ENABLE_XLA=0 \
TF_NEED_OPENCL_SYCL=0 \
TF_NEED_ROCM=0 \
TF_NEED_CUDA=0 \
TF_DOWNLOAD_CLANG=0 \
TF_SET_ANDROID_WORKSPACE=0 \
TF_NEED_MPI=0 MPI_HOME=$(pack_get -prefix mpi) \
PREFIX=$(pack_get -prefix) \
CC_OPT_FLAGS='$CFLAGS' ./configure"

# local_resources 2048 limits memory usage
pack_cmd "$_envs bazel build --jobs $NPROCS -s --local_resources 2048,.5,1.0 \
-k --verbose_failures \
-c opt \
--config=opt \
--force_pic \
--cxxopt=-D_GLIBCXX_USE_CXX11_ABI=0 \
--define=PREFIX=$(pack_get -prefix) \
//tensorflow/tools/pip_package:build_pip_package"

pack_cmd "mkdir my-tensorflow-directory-for-pip"
pack_cmd "./bazel-bin/tensorflow/tools/pip_package/build_pip_package my-tensorflow-directory-for-pip"

pack_cmd "pip install --prefix=$(pack_get -prefix) ./my-tensorflow-directory-for-pip./*.whl"
pack_cmd "module unload $_mods"
