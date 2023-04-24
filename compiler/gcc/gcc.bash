source compiler/gcc/ansidecl.h.fix

# hide the ansidecl problem
ansidecl_hide

for gcc_v in \
	4.9.4 \
	7.5.0 \
	8.5.0 \
	10.4.0 \
	12.2.0
do
gcc=gcc_$gcc_v


source_pack compiler/gcc/prereq.bash
for f in gmp mpfr mpc isl gcc gdb
do
   gcc_major_v=${gcc_v%%.*}
   f=compiler/gcc/${gcc_major_v}/$f.bash 
   if [ -e $f ]; then
	source_pack $f
   fi
   unset gcc_major_v
done
done

# restore ansidecl.h
ansidecl_restore


# Local variables which should only be visible here...
unset gcc_v
unset gcc
