# Create a new build with name generic
new_build --name generic \
    --installation-path /opt/generic \
    --module-path /opt/modules-generic \
    --build-path .compile \
    --source source-generic.sh \
    --build-module-path "--package --version" \
    --build-installation-path "--package --version"

# Create a new build with name generic
new_build --name generic-no-version \
    --installation-path /opt/generic \
    --module-path /opt/modules-generic \
    --build-path .compile \
    --source source-generic.sh \
    --build-module-path "--package" \
    --build-installation-path "--package"

# Create a new build with name generic
new_build --name generic-empty \
    --installation-path /opt/generic \
    --module-path /opt/modules-generic \
    --build-path .compile \
    --source source-generic.sh \
    --build-module-path "--package" \
    --build-installation-path ""

# Create a vendor buld
new_build --name vendor \
    --installation-path /opt/vendor \
    --module-path /opt/modules-vendor \
    --build-path .compile \
    --source source-generic.sh \
    --build-module-path "--package --version" \
    --build-installation-path "--package --version"
