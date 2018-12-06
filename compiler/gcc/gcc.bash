gcc_v=5.5.0
gcc=gcc_$gcc_v
#source_pack compiler/gcc/prereq.bash
#source_pack compiler/gcc/5/gmp.bash
#source_pack compiler/gcc/5/mpfr.bash
#source_pack compiler/gcc/5/mpc.bash
#source_pack compiler/gcc/5/isl.bash
#source_pack compiler/gcc/5/gcc.bash
#source_pack compiler/gcc/5/gdb.bash

gcc_v=6.5.0
gcc=gcc_$gcc_v
source_pack compiler/gcc/prereq.bash
source_pack compiler/gcc/6/gmp.bash
source_pack compiler/gcc/6/mpfr.bash
source_pack compiler/gcc/6/mpc.bash
source_pack compiler/gcc/6/isl.bash
source_pack compiler/gcc/6/gcc.bash
source_pack compiler/gcc/6/gdb.bash

gcc_v=7.4.0
gcc=gcc_$gcc_v
source_pack compiler/gcc/prereq.bash
source_pack compiler/gcc/7/gmp.bash
source_pack compiler/gcc/7/mpfr.bash
source_pack compiler/gcc/7/mpc.bash
source_pack compiler/gcc/7/isl.bash
source_pack compiler/gcc/7/gcc.bash
source_pack compiler/gcc/7/gdb.bash

gcc_v=8.2.0
gcc=gcc_$gcc_v
source_pack compiler/gcc/prereq.bash
source_pack compiler/gcc/8/gmp.bash
source_pack compiler/gcc/8/mpfr.bash
source_pack compiler/gcc/8/mpc.bash
source_pack compiler/gcc/8/isl.bash
source_pack compiler/gcc/8/gcc.bash
source_pack compiler/gcc/8/gdb.bash

# Local variables which should only be visible here...
unset gcc_v
unset gcc
