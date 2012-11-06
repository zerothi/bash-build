
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

