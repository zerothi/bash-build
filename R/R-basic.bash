_R_dwn=$(pwd_archives)/R
mkdir -p $_R_dwn

_R_pack=
function R_append {
    while [[ $# -gt 0 ]];
    do
	_R_pack="$_R_pack, \"$1\""
	shift
    done
}

function R_install {
    pack_cmd "R_MAKEVARS_SITE=$makevars R -q --no-save --no-init-file -e 'lop <- c(${_R_pack:2}) ; np <- lop[!(lop %in% installed.packages()[,\"Package\"])] ; if(length(np)>0){install.packages(np, destdir=\"$_R_dwn\", verbose=TRUE, keep_outputs=TRUE, repos=\"https://cloud.r-project.org\")}; q()'"
    _R_pack=
}

add_package R_installs.local
pack_set -directory .

# NOTE
#
# If you want dependencies, they should be added to the R installation
# since these installs are *not* modules

mod_reqs="$(pack_get -mod-req)"
# Create the temporary Makevars files
makevars=$(readlink -m $(build_get -build-path)/Makevars)

pack_cmd "echo '# BB makevars for R' > $makevars"
pack_cmd "sed -i '$ a\
CPPFLAGS += $(list -INCDIRS $mod_reqs)\n\
CFLAGS += $(list -INCDIRS $mod_reqs)\n\
LDFLAGS += $(list -LD-rp $mod_reqs)\n\
PKG_CPPFLAGS += $(list -INCDIRS $mod_reqs)\n\
PKG_CFLAGS += $(list -INCDIRS $mod_reqs)\n\
PKG_LIBS += $(list -LD-rp $mod_reqs)\n\
' $makevars"

R_append devtools
R_install

R_append Rcpp
R_install
R_append openssl
R_install
R_append rstudioapi
R_append base64enc
R_append rmarkdown
R_append jose
R_append htmltools
R_append openssl
R_append sourcetools
R_append fansi
R_append R6
R_append crayon
R_append cli
R_append rlang
R_append utf8
R_append pillar
R_append digest
R_append praise
R_append withr
R_append magrittr
R_append testthat
R_append pkgconfig
R_append glue
R_append covr
R_append stringi
R_append ellipsis
R_append clipr
R_append evaluate
R_append yaml
R_append knitr
R_append hms
R_append gtable
R_append scales
R_append prettyunits
R_append progress
R_append profmem
R_append BH
R_append plogr
R_append reshape2
R_append classInt
R_append DBI


R_install

unset _R_dwn

unset _R_pack
unset add_R_package
unset R_append


pack_install
