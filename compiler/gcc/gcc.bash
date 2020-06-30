for gcc_v in 4.9.4
do
    gcc=gcc_$gcc_v
    source_pack compiler/gcc/prereq.bash
    source_pack compiler/gcc/4/gmp.bash
    source_pack compiler/gcc/4/mpfr.bash
    source_pack compiler/gcc/4/mpc.bash
    source_pack compiler/gcc/4/isl.bash
    source_pack compiler/gcc/4/gcc.bash
done

gcc_v=5.5.0
gcc=gcc_$gcc_v
source_pack compiler/gcc/prereq.bash
source_pack compiler/gcc/5/gmp.bash
source_pack compiler/gcc/5/mpfr.bash
source_pack compiler/gcc/5/mpc.bash
source_pack compiler/gcc/5/isl.bash
source_pack compiler/gcc/5/gcc.bash

gcc_v=6.5.0
gcc=gcc_$gcc_v
source_pack compiler/gcc/prereq.bash
source_pack compiler/gcc/6/gmp.bash
source_pack compiler/gcc/6/mpfr.bash
source_pack compiler/gcc/6/mpc.bash
source_pack compiler/gcc/6/isl.bash
source_pack compiler/gcc/6/gcc.bash
source_pack compiler/gcc/6/gdb.bash

gcc_v=7.5.0
gcc=gcc_$gcc_v
source_pack compiler/gcc/prereq.bash
source_pack compiler/gcc/7/gmp.bash
source_pack compiler/gcc/7/mpfr.bash
source_pack compiler/gcc/7/mpc.bash
source_pack compiler/gcc/7/isl.bash
source_pack compiler/gcc/7/gcc.bash
source_pack compiler/gcc/7/gdb.bash

gcc_v=8.4.0
gcc=gcc_$gcc_v
source_pack compiler/gcc/prereq.bash
source_pack compiler/gcc/8/gmp.bash
source_pack compiler/gcc/8/mpfr.bash
source_pack compiler/gcc/8/mpc.bash
source_pack compiler/gcc/8/isl.bash
source_pack compiler/gcc/8/gcc.bash
source_pack compiler/gcc/8/gdb.bash

gcc_v=9.1.0
gcc=gcc_$gcc_v
source_pack compiler/gcc/prereq.bash
source_pack compiler/gcc/9/gmp.bash
source_pack compiler/gcc/9/mpfr.bash
source_pack compiler/gcc/9/mpc.bash
source_pack compiler/gcc/9/isl.bash
source_pack compiler/gcc/9/gcc.bash
source_pack compiler/gcc/9/gdb.bash

gcc_v=10.1.0
gcc=gcc_$gcc_v
source_pack compiler/gcc/prereq.bash
source_pack compiler/gcc/10/gmp.bash
source_pack compiler/gcc/10/mpfr.bash
source_pack compiler/gcc/10/mpc.bash
source_pack compiler/gcc/10/isl.bash
source_pack compiler/gcc/10/gcc.bash
source_pack compiler/gcc/10/gdb.bash


# Local variables which should only be visible here...
unset gcc_v
unset gcc
