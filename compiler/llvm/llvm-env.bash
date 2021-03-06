# Common options for each of the LLVM-compliers
pack_set -module-opt "-prepend-ENV LD_LIBRARY_PATH=$(pack_get -prefix)/lib"
pack_set -module-opt "-undefined-ENV CC=clang"
pack_set -module-opt "-undefined-ENV CXX=clang++"
# we currently do not have "flang" in LLVM, so in LLVM 9 we should have it
if [[ $(vrs_cmp $(pack_get -version) 9) -ge 0 ]]; then
    pack_set -module-opt "-undefined-ENV FC=flang"
    pack_set -module-opt "-undefined-ENV F77=flang"
    pack_set -module-opt "-undefined-ENV F90=flang"
fi
pack_set -module-opt "-undefined-ENV AR=llvm-ar"
pack_set -module-opt "-undefined-ENV RANLIB=llvm-ranlib"
pack_set -module-opt "-undefined-ENV NM=llvm-nm"
