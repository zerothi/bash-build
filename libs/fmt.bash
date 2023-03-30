v=9.1.0
add_package https://github.com/fmtlib/fmt/releases/download/$v/fmt-$v.zip

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/libfmt.a
pack_set -lib -lfmt

pack_cmd "cmake -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix) -Bbuild-tmp -S."
pack_cmd "cmake --build build-tmp $(get_make_parallel)"
pack_cmd "cmake --build build-tmp $(get_make_parallel) --target install"
