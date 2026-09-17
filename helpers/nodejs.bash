for v in 22.23.2 24.21.0 26.8.2
do
  add_package -package nodejs -version $v -build generic \
         https://nodejs.org/dist/v$v/node-v$v-linux-x64.tar.xz

  pack_set -s $IS_MODULE

  pack_set -install-query $(pack_get -prefix)/bin/node

  pack_cmd "mkdir -p $(pack_get -prefix)"
  pack_cmd "mv bin CHANGELOG.md include lib LICENSE README.md share $(pack_get -prefix)/"
done
