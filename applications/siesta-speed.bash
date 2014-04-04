
# This is the order for compiling SIESTA/TranSIESTA in parallel
# Making the version one time before corrects the input to it
pack_set --command "make version"
pack_set --command "make $(get_make_parallel) FoX/.FoX"
pack_set --command "make $(get_make_parallel) libxmlparser.a"
pack_set --command "make libmpi_f90.a"
pack_set --command "make $(get_make_parallel) libfdf.a"
while [ $# -gt 0 ]; do
    pack_set --command "make $(get_make_parallel) $1"
    shift
done
