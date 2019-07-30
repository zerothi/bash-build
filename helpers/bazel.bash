for v in 0.21.0 0.23.2
do
    add_package -build generic \
		-package bazel \
		-version $v \
		https://github.com/bazelbuild/bazel/releases/download/$v/bazel-$v-installer-linux-x86_64.sh
    
    pack_set -s $IS_MODULE -s $INSTALL_FROM_ARCHIVE
    
    pack_set -build-mod-req build-tools
    pack_set -module-opt "-lua-family bazel"
    pack_set -install-query $(pack_get -prefix)/bin/bazel
    
    pack_cmd "chmod u+x $(build_get -archive-path)/$(pack_get -archive)"
    pack_cmd "$(build_get -archive-path)/$(pack_get -archive) --prefix=$(pack_get -prefix)"
    
done

