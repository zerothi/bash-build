
# This is the order for compiling SIESTA/TranSIESTA in parallel
# Making the version one time before corrects the input to it
pack_cmd "make version"
pack_cmd "make $(get_make_parallel) FoX/.FoX"
pack_cmd "make $(get_make_parallel) libxmlparser.a"
pack_cmd "make libmpi_f90.a"
pack_cmd "make $(get_make_parallel) libfdf.a"
while [[ $# -gt 0 ]]; do
    prev=$1
    shift
    case $prev in
	libvardict.a)
            pack_cmd "make $prev"
	    ;;
	libncdf.a)
            pack_cmd "make $prev"
	    ;;
	libSiestaXC.a)
            pack_cmd "make $prev"
	    ;;
	*)
            pack_cmd "make $(get_make_parallel) $prev"
	    ;;
    esac
done
# Asserts that the version.o is updated
pack_cmd "make $prev"

