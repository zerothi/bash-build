source compiler/gcc/ansidecl.h.fix

# hide the ansidecl problem
ansidecl_hide

function install_gcc {
    local gcc_v=$1
    shift
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
}

# GCC 5-8 uses linux/cyclades.h
# However, this got removed in 9 
install_gcc 4.9.4
#install_gcc 7.5.0
#install_gcc 8.5.0
install_gcc 10.5.0
install_gcc 14.2.0
install_gcc 13.3.0
install_gcc 12.3.0

# restore ansidecl.h
ansidecl_restore


# Local variables which should only be visible here...
unset gcc_v
unset gcc
