v=1.14.0
add_package https://github.com/openucx/ucx/releases/download/v$v/ucx-${v//-rc*/}.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# What to check for when checking for installation...
pack_set -install-query $(pack_get -prefix)/bin/ucx_info

pack_set -build-mod-req build-tools
pack_set -mod-req numactl

tmp_flags=
if [[ -d /usr/include/infiniband ]]; then
    tmp_flags="$tmp_flags --with-verbs"
fi

if ! $(is_host nicpa) ; then
    tmp_flags="$tmp_flags --with-mlx5-dv"
    tmp_flags="$tmp_flags --with-ib-hw-tm"
fi

if [[ "$(get_c -n)" == *"debug"* ]]; then
    tmp_flags="$tmp_flags --enable-debug"
    pack_cmd "unset CFLAGS ; unset CXXFLAGS"
fi

#tmp_flags="$tmp_flags --with-rc --with-ud"
#if [[ "x${CPUTYPEV}" == "xXeonGold6126" ]]; then
#    tmp_flags="$tmp_flags --without-dc"
#else
#    tmp_flags="$tmp_flags --with-dc"
#fi
tmp_flags="$tmp_flags --with-dm --without-go"
tmp_flags="$tmp_flags --enable-mt --enable-cma"
tmp_flags="$tmp_flags --with-mcpu --with-march"
tmp_flags="$tmp_flags --disable-backtrace-detail"
tmp_flags="$tmp_flags --enable-devel-headers"
tmp_flags="$tmp_flags --enable-optimizations"
tmp_flags="$tmp_flags --enable-shared --disable-static"

# knem is a sys module which we cannot override
if [[ $(pack_installed knem) -eq 1 ]]; then
  pack_set -mod-req knem
  tmp_flags="$tmp_flags --with-knem=$(pack_get -prefix knem)"
elif [ -d /opt/knem/bin/knem_cost ]; then
  tmp_flags="$tmp_flags --with-knem=/opt/knem"
else
  _dir=$(locate knem_cost | head -n 1)
  _dir=$(dirname $_dir)
  _dir=$(dirname $_dir)
  tmp_flags="$tmp_flags --with-knem=$_dir"
fi

# Install commands that it should run
pack_cmd "unset MPICC ; unset MPICXX ; unset MPIFC"
pack_cmd "../contrib/configure-release $tmp_flags" \
	 "--prefix=$(pack_get -prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > ucx.test 2>&1 || echo forced"
pack_store ucx.test
pack_cmd "make install"
