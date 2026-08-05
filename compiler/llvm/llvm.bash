old_ulimit_n=$(ulimit -n)
ulimit -n 32768

# The documentation for building LLVM is sparse.
# And generally not applicable between different versions.
# It is getting better but...
#
# Here are some sites:
#
# https://llvm.org/docs/BuildingADistribution.html
# https://llvm.org/docs/CMake.html
# https://llvm.org/docs/AdvancedBuilds.html

gnu_v=9
#source_pack compiler/llvm/7/llvm.bash
#source_pack compiler/llvm/8/llvm.bash
#source_pack compiler/llvm/9/llvm.bash
#source_pack compiler/llvm/10/llvm.bash

gnu_v=12
#source_pack compiler/llvm/11/llvm.bash
source_pack compiler/llvm/12/llvm.bash
#source_pack compiler/llvm/13/llvm.bash
#source_pack compiler/llvm/14/llvm.bash
#source_pack compiler/llvm/15/llvm.bash
source_pack compiler/llvm/16/llvm.bash
#source_pack compiler/llvm/18/llvm.bash
#source_pack compiler/llvm/19/llvm.bash
source_pack compiler/llvm/22/llvm.bash

ulimit -n $old_ulimit_n
