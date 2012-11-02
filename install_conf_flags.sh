
# This script needs to have install_funcs loaded
# Function for population the CONF_ARGS array for configure arguments
function populate_configure_flags {
    local -a args=()
    case $(pack_get --package $1) in
	openmpi*)
	    args=(
		--prefix=$(pack_get --install-prefix $1)
	    );;
	Python*|python*)
	    args=(
		--prefix=$(pack_get --install-prefix $1)
	    );;
	git*)
	    args=(
		--prefix=$(pack_get --install-prefix $1)
		--with-zlib=$(pack_get --install-prefix zlib)
	    );;
	zlib*)
	    args=(
		--prefix
		$(pack_get --install-prefix $1)
		--static
	    );;
	hdf5*)
	    exit_on_error $? "Could not determine zlib version in use"
	    args=(
		CC=${MPICC}
		CXX=${MPICXX}
		F77=${MPIF90}
		F90=${MPIF90}
		FC=${MPIF90}
		--prefix=$(pack_get --install-prefix $1)
		--with-zlib=$(pack_get --install-prefix zlib)
		--enable-parallel
		--disable-shared 
		#--enable-shared  # They are not tested with parallel
		--enable-static
		--enable-fortran
		--enable-fortran2003
	    );;
	parallel-netcdf*)
	    args=(
		CC=${MPICC}
		CXX=${MPICXX}
		F77=${MPIF90}
		F90=${MPIF90}
		FC=${MPIF90}
		--prefix=$(pack_get --install-prefix $1)
		--with-mpi=$(pack_get --install-prefix openmpi)
		--enable-fortran
	    )		
	    ;;
	netcdf-fortran*)
	    args=(
		CC=${MPICC}
		CXX=${MPICXX}
		F77=${MPIF77}
		F90=${MPIF90}
		FC=${MPIF90}
		--prefix=$(pack_get --install-prefix $1)
		--disable-shared 
		--enable-static
	    );;
	netcdf*)
	    args=(
		CC=${MPICC}
		CXX=${MPICXX}
		--prefix=$(pack_get --install-prefix $1)
		--disable-shared
		--enable-static
		--enable-pnetcdf
		--enable-netcdf-4
	    );;
	*)
	    doerr "Could not find configure for the archive"
	    ;;
    esac
    echo ${args[@]}
}


function populate_LIBS {
    local -a args=()
    case $(pack_get --package $1) in
	hdf5*)
	    args=(
		$(pack_get --install-prefix zlib)
	    );;
	netcdf-fortran*)
	    args=(
		$(pack_get --install-prefix netcdf)
		$(pack_get --install-prefix hdf5)
		$(pack_get --install-prefix zlib)
		$(pack_get --install-prefix parallel-netcdf)
	    );;
	netcdf*)
	    args=(
		$(pack_get --install-prefix hdf5)
		$(pack_get --install-prefix zlib)
		$(pack_get --install-prefix parallel-netcdf)
	    );;
    esac
    echo ${args[@]}
}


# Create -L../lib64 using the archive name
function create_LD {
    local -a args=( $(populate_LIBS $1) )
    local tmp=""
    local i=0
    while : ; do 
	[ $i -ge ${#args[@]} ] && break
	[ -d ${args[$i]}/lib64 ] && tmp="$tmp -L${args[$i]}/lib64"
	[ -d ${args[$i]}/lib ] && tmp="$tmp -L${args[$i]}/lib"
	i=$((i+1))
    done
    echo ${tmp:1}
}

# Create -I../include using the archive name
function create_INC {
    local -a args=( $(populate_LIBS $1) )
    local tmp=""
    local i=0
    while : ; do 
	[ $i -ge ${#args[@]} ] && break
	[ -d ${args[$i]}/include ] && tmp="$tmp -I${args[$i]}/include"
	i=$((i+1))
    done
    echo ${tmp:1}
}

# Create ..:..:.. using the archive name
function create_LDLIBPATH {
    local -a args=( $(populate_LIBS $1) )
    local tmp=""
    local i=0
    while : ; do 
	[ $i -ge ${#args[@]} ] && break
	[ -d ${args[$i]}/lib64 ] && tmp="$tmp:${args[$i]}/lib64"
	[ -d ${args[$i]}/lib ] && tmp="$tmp:${args[$i]}/lib"
	i=$((i+1))
    done
    echo ${tmp:1}
}

function populate_add_LIBS {
    local -a args=()
    case $(pack_get --package $1) in
	netcdf-fortran*)
	    args=(
		$(pack_get --install-prefix netcdf)/lib/libnetcdf.a # order is important
		$(pack_get --install-prefix parallel-netcdf)/lib/libpnetcdf.a
		$(pack_get --install-prefix hdf5)/lib/libhdf5_hl.a
		$(pack_get --install-prefix hdf5)/lib/libhdf5hl_fortran.a
		$(pack_get --install-prefix hdf5)/lib/libhdf5.a
		$(pack_get --install-prefix hdf5)/lib/libhdf5_fortran.a
		$(pack_get --install-prefix zlib)/lib/libz.a
		-lcurl
	    );;
    esac
    echo ${args[@]}
}


# This script needs to have install_funcs loaded
# Function for population the CONF_ARGS array for configure arguments
function populate_requirements {
    local -a args=()
    case $(pack_get --package $1) in
	hdf5*)
	    args=(
		$(pack_get --module-name zlib)
	    );;
	netcdf*)
	    args=(
		$(pack_get --module-name zlib)
		$(pack_get --module-name hdf5)
		$(pack_get --module-name parallel-netcdf)
	    );;
    esac
    echo ${args[@]}
}
