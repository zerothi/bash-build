msg_install --message "Installing all helper modules if needed..."

# Install modules
source helpers/modules.bash

source helpers/gnumake.bash

source helpers/help2man.bash
source helpers/m4.bash
source helpers/autoconf.bash
source helpers/automake.bash
source helpers/libtool.bash
source helpers/cmake.bash

# Install bison
source helpers/bison.bash
source helpers/flex.bash
source helpers/pcre.bash
source helpers/swig.bash


# Install LLVM generically
source libs/zlib.bash
pack_set --alias gen-zlib
source libs/libffi.bash
pack_set --alias gen-libffi
source helpers/llvm.bash