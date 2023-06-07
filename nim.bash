nV=1.6
InV=$nV.12
add_package -package nim \
	    https://nim-lang.org/download/nim-$InV.tar.xz

# The settings
pack_set -s $MAKE_PARALLEL -s $IS_MODULE
pack_set -module-requirement pcre
pack_set -module-requirement openssl
pack_set -module-requirement nodejs

pack_set -install-query $(pack_get -prefix)/bin/nim

# Create building nim
pack_cmd "unset CFLAGS"
pack_cmd "sh build.sh"
pack_cmd "bin/nim c --noNimblePath --skipUserCfg --skipParentCfg --hints:off koch"
pack_cmd "./koch boot -d:release --noNimblePath --skipUserCfg --skipParentCfg --hints:off"
pack_cmd "./koch tools --skipUserCfg --skipParentCfg --hints:off"
pack_cmd "./koch docs -d:release || echo 'failed doing documentation...'"
pack_cmd "./koch geninstall $(pack_get -prefix)"
# Now also install nimble
pack_cmd "./koch nimble"
pack_cmd "sed -i -e '/case/,/esac/{s:/nim::g}' install.sh"
pack_cmd "sh install.sh $(pack_get -prefix)"


# Create a new build with this module
new_build -name _internal-nim$InV \
    -module-path $(build_get -module-path)-nim/$InV \
    -source $(build_get -source) \
    $(list -prefix "-default-module " $(pack_get -mod-req-module) nim[$InV]) \
    -installation-path $(dirname $(pack_get -prefix $(get_parent)))/packages \
    -build-module-path "-package -version" \
    -build-installation-path "$InV -package -version" \
    -build-path $(build_get -build-path)/nim-$nV

mkdir -p $(build_get -module-path[_internal-nim$InV])-apps
build_set -default-setting[_internal-nim$InV] $(build_get -default-setting)

# Now add options to ensure that loading this module will enable the path for the *new build*
pack_set -module-opt "-use-path $(build_get -module-path[_internal-nim$InV])"
case $_mod_format in
    $_mod_format_ENVMOD)
	;;
    *)
	pack_set -module-opt "-use-path $(build_get -module-path[_internal-nim$InV])-apps"
	;;
esac

pack_install


create_module \
    -module-path $(build_get -module-path)-apps \
    -n $(pack_get -alias).$(pack_get -version) \
    -W "Script for loading $(pack_get -package): $(get_c)" \
    -v $(pack_get -version) \
    -M $(pack_get -alias).$(pack_get -version) \
    -P "/directory/should/not/exist" \
    $(list -prefix '-L ' $(pack_get -module-requirement)) \
    -L $(pack_get -alias) 

# The lookup name in the list for version number etc...
set_parent $(pack_get -alias)[$InV]
set_parent_exec $(pack_get -prefix)/bin/nim

# Save the default build index
def_idx=$(build_get -default-build)
# Change to the new build default
build_set -default-build _internal-nim$InV


# Install all nim packages
[ -e nim-install.bash ] && source nim-install.bash
clear_parent

# Initialize the module read path
old_path=$(build_get -module-path)
build_set -module-path $old_path-apps
source nim/nim-mods.bash
build_set -module-path $old_path


# Reset default build
build_set -default-build $def_idx
