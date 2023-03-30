# Add prereq
source_pack compiler/gcc/prereq.bash
for f in gmp mpfr mpc isl gcc gdb
do
   gcc_major_v=${gcc_v%%.*}
   if [ -e compiler/gcc/${gcc_major_v}/$f.bash ]; then
	source_pack compiler/gcc/${gcc_major_v}/$f.bash
   fi
done
