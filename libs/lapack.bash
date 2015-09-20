# Then install LAPACK
bl=$1
shift

add_package --package lapack-$bl http://www.student.dtu.dk/~nicpa/packages/lapack-1593.tar.bz2

pack_set -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --LD $bl)/liblapack.a

pack_set --module-requirement $bl

# Prepare the make file
file=make.inc
tmp="sed -i -e"
pack_cmd "cp $file.example $file"
pack_cmd "$tmp 's;FORTRAN[[:space:]]*=.*;FORTRAN = $FC;g' $file"
pack_cmd "$tmp 's;CC[[:space:]]*=.*;CC = $CC;g' $file"
pack_cmd "$tmp 's;ARCH[[:space:]]*=.*;ARCH = $AR;g' $file"
if $(is_c gnu) ; then
    pack_cmd "$tmp 's;OPTS[[:space:]]*=.*;OPTS = $FCFLAGS -frecursive;g' $file"
else
    pack_cmd "$tmp 's;OPTS[[:space:]]*=.*;OPTS = $FCFLAGS;g' $file"
fi 
pack_cmd "$tmp 's;CFLAGS[[:space:]]*=.*;CFLAGS = $CFLAGS;g' $file"
if $(is_c gnu) ; then
    pack_cmd "$tmp 's;NOOPT[[:space:]]*=.*;NOOPT = -fPIC -frecursive;g' $file"
else
    pack_cmd "$tmp 's;NOOPT[[:space:]]*=.*;NOOPT = -fPIC;g' $file"
fi
pack_cmd "$tmp 's;LOADER[[:space:]]*=.*;LOADER = $FC;g' $file"
pack_cmd "$tmp 's;LOADOPTS[[:space:]]*=.*;LOADOPTS = $FCFLAGS;g' $file"
pack_cmd "$tmp 's;TIMER[[:space:]]*=.*;TIMER = INT_CPU_TIME;g' $file"
pack_cmd "$tmp 's;_LINUX;;g' $file"
pack_cmd "$tmp 's;_SUN4;;g' $file"
case $bl in
    blis)
	pack_cmd "$tmp 's?BLASLIB[[:space:]]*=.*?BLASLIB = $(list --LD-rp $bl) -lblis?g' $file"
	;;
    blas)
	pack_cmd "$tmp 's?BLASLIB[[:space:]]*=.*?BLASLIB = $(list --LD-rp $bl) -lblas?g' $file"
	;;
    atlas)
	pack_cmd "$tmp 's?BLASLIB[[:space:]]*=.*?BLASLIB = $(list --LD-rp $bl) -lf77blas -lcblas -latlas?g' $file"
	;;
    openblas)
	pack_cmd "$tmp 's?BLASLIB[[:space:]]*=.*?BLASLIB = $(list --LD-rp $bl) -lopenblas?g' $file"
	;;
esac
pack_cmd "echo '' >> $file"
pack_cmd "echo 'LAPACKE_WITH_TMG = Yes' >> $file"

# Make commands
pack_cmd "make $(get_make_parallel) lapacklib lapackelib tmglib"

pack_cmd "cp liblapack.a liblapacke.a $(pack_get --LD $bl)/"
pack_cmd "cp libtmglib.a $(pack_get --LD $bl)/libtmg.a"
pack_cmd "mkdir -p $(pack_get --prefix $bl)/include/"
pack_cmd "cp LAPACKE/include/*.h $(pack_get --prefix $bl)/include/"

if [[ $bl == "atlas" ]]; then
    # We need to collect the two sets
    pack_cmd "mkdir -p tmp"
    pack_cmd "cd tmp"
    # Extract atlas optimized lapack routines
    pack_cmd "$AR x $(pack_get --LD $bl)/liblapack_atlas.a"
    # replace them
    pack_cmd "$AR r ../liblapack.a *.o"
    pack_cmd "cd .."
    pack_cmd "ranlib liblapack.a"
    pack_cmd "cp liblapack.a $(pack_get --LD $bl)/liblapack.a"
fi
