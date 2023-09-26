add_R_package sf 1.0-14
pack_set -mod-req R.rgeos -mod-req R.units -mod-req gdal -mod-req geos -mod-req R.s2

mk_R_install_script new
mk_R_install_script "config_geos = '--with-geos-config=$(pack_get -prefix geos)/bin/geos-config'"
mk_R_install_script "config_gdal = '--with-gdal-config=$(pack_get -prefix gdal)/bin/gdal-config'"
mk_R_install_script "config_proj = '--with-proj-include=$(pack_get -prefix proj)/include --with-proj-lib=$(pack_get -prefix proj)/lib'"
mk_R_install_script "config_libs = 'LIBS=\'$(list -LD-rp hdf5-serial netcdf-serial sqlite proj geos gdal)\''"
mk_R_install_script "config_pkglibs = 'PKG_LIBS=\'$(list -LD-rp hdf5-serial netcdf-serial sqlite proj geos gdal)\''"
# Now create full script
mk_R_install_script "install.packages('$archive_path/$(pack_get -archive)',"
mk_R_install_script "'$(pack_get -prefix)', repos=NULL, type='source',"
mk_R_install_script "configure.args=c(config_geos,config_gdal,config_proj),"
#mk_R_install_script "configure.vars=c(config_libs,config_pkglibs))"
mk_R_install_script "configure.vars=c(config_pkglibs))"
file=$(pwd)/$(mk_R_install_script get)

pack_cmd "Rscript --verbose $file"
