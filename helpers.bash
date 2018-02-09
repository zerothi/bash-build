msg_install --message "Installing all helper modules if needed..."


# Add a module which contains the default build tools
add_package --build generic --version 1.0 \
    --package build-tools fake
pack_set -s $IS_MODULE
pack_set --module-name build-tools/1.0
pack_set --prefix $(build_get --installation-path[generic])/build-tools/1.0
pack_set --install-query $(pack_get --prefix)/bin
pack_set --command "mkdir -p $(pack_get --prefix)/bin/"

source_pack helpers/help2man.bash
source_pack helpers/m4.bash
source_pack helpers/autoconf.bash
source_pack helpers/automake.bash
source_pack helpers/libtool.bash
source_pack helpers/pkgconfig.bash
# gnumake relies on libtool
source_pack helpers/gnumake.bash
source_pack helpers/texinfo.bash
# After all build-tools have been installed
source_pack helpers/binutils.bash
source_pack helpers/dejagnu.bash

# xdev (utilities)
source_pack helpers/imake.bash
source_pack helpers/makedepend.bash


source_pack helpers/zlib.bash
source_pack helpers/libpng.bash
source_pack helpers/libgd.bash

source_pack helpers/cmake.bash
source_pack helpers/freetype.bash
source_pack helpers/libunistring.bash
source_pack helpers/libffi.bash

# Install parallel binary
source_pack helpers/parallel.bash

# Install all compilers
source compiler/compilers.bash

# GPP
source_pack helpers/gpp.bash

# Build helpers
source_pack helpers/guile.bash
source_pack helpers/bison.bash
source_pack helpers/flex.bash
source_pack helpers/pcre.bash
source_pack helpers/swig.bash

source_pack helpers/optipng.bash

# Install LLVM generically
source_pack helpers/libxml2.bash

source_pack helpers/readline.bash
source_pack helpers/termcap.bash
source_pack helpers/openssl.bash

# Install LLVM compiler
source llvm/llvm.bash

source_pack helpers/numactl.bash

# Install git for those who want the newest release
source_pack helpers/git.bash

# Other helpers
source_pack helpers/doxygen.bash
source_pack helpers/ffmpeg.bash
source_pack helpers/gts.bash
source_pack helpers/graphviz.bash
source_pack helpers/sqlite.bash

source_pack helpers/boost.bash

source_pack helpers/default.bash
