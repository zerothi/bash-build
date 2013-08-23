msg_install --message "Installing all helper modules if needed..."

# Install modules
source helpers/modules.bash

source helpers/gnumake.bash

source helpers/help2man.bash
source helpers/m4.bash
source helpers/autoconf.bash
source helpers/automake.bash

# Install bison
source helpers/bison.bash
source helpers/flex.bash
source helpers/pcre.bash
source helpers/swig.bash

