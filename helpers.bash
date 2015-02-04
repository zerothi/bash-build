msg_install --message "Installing all helper modules if needed..."

# Add a module which contains the default build tools
add_package --build generic --version npa \
    --package build-tools fake
pack_set -s $IS_MODULE
#pack_set --installed $_I_INSTALLED # Make sure it is "installed"
pack_set --module-name build-tools/npa
pack_set --prefix $(build_get --installation-path[generic])/build-tools/npa
pack_set --install-query $(pack_get --prefix)/bin
pack_set --command "mkdir -p $(pack_get --prefix)/bin/"

# Install modules
source helpers/modules.bash


source helpers/help2man.bash
source helpers/m4.bash
source helpers/autoconf.bash
source helpers/automake.bash
source helpers/libtool.bash
# gnumake relies on libtool
source helpers/gnumake.bash
source helpers/cmake.bash
source helpers/freetype.bash
source helpers/libunistring.bash
source helpers/libffi.bash

# Install my GCC version
source helpers/gmp.bash

#source helpers/guile.bash # not related to GCC, but depends on gmp
#source helpers/autogen.bash # not related to GCC, but depends on guile

source helpers/mpfr.bash
source helpers/mpc.bash
source helpers/isl.bash
source helpers/cloog.bash
source helpers/gcc.bash

# Install bison
source helpers/bison.bash
source helpers/flex.bash
source helpers/pcre.bash
source helpers/swig.bash

# Install LLVM generically
source helpers/zlib.bash
source helpers/llvm.bash

source helpers/numactl.bash
#source helpers/libxml2.bash

# Install git for those who want the newest release
source helpers/git.bash
source helpers/doxygen.bash

# Other helpers
source helpers/ffmpeg.bash

source helpers/default.bash