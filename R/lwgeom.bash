add_R_package lwgeom 0.2-5
pack_set -mod-req R.udunits2 -mod-req geos -mod-req R.sf

mk_R_install_script new "config_geos = '--with-geos-config=$(pack_get -prefix geos)/bin/geos-config'"
mk_R_install_script "config_proj = '--with-proj-include=$(pack_get -prefix proj)/include --with-proj-lib=$(pack_get -prefix proj)/lib'"
mk_R_install_script "config_libs = 'LIBS=\'$(list -LD-rp hdf5-serial netcdf-serial sqlite proj geos)\''"
mk_R_install_script "config_pkglibs = 'PKG_LIBS=\'$(list -LD-rp hdf5-serial netcdf-serial sqlite proj geos)\''"
# Now create full script
mk_R_install_script "install.packages('$archive_path/$(pack_get -archive)',"
mk_R_install_script "'$(pack_get -prefix)', repos=NULL, type='source',"
mk_R_install_script "configure.args=paste(config_geos,config_proj,sep=' '),"
mk_R_install_script "configure.vars=paste(config_libs,config_pkglibs,sep=' '))"
file=$(pwd)/$(mk_R_install_script get)

pack_cmd "Rscript $file && rm $file"
