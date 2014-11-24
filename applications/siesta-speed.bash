
# This is the order for compiling SIESTA/TranSIESTA in parallel
# Making the version one time before corrects the input to it
pack_set --command "make version"
pack_set --command "make $(get_make_parallel) FoX/.FoX"
pack_set --command "make $(get_make_parallel) libxmlparser.a"
pack_set --command "make libmpi_f90.a"
pack_set --command "make $(get_make_parallel) libfdf.a"
while [ $# -gt 0 ]; do
    if [ "$1" == "libvardict.a" ]; then
        pack_set --command "make $1"
    elif [ "$1" == "libncdf.a" ]; then
        pack_set --command "make $1"
    elif [ "$1" == "libSiestaXC.a" ]; then
        pack_set --command "make -j 2 $1"
    else
        pack_set --command "make $(get_make_parallel) $1"
    fi
    shift
done
