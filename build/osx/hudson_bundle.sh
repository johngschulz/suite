#!/bin/bash

# Script directory
d=`dirname $0`

# Load versions
source ${d}/hudson_config.sh

function usage() {
  echo "Usage: $0 <srcdir>"
  exit 1
}

# Check for one argument
if [ $# -lt 1 ]; then
  usage
fi

# Enter source directory
srcdir=$1
if [ ! -d $srcdir ]; then
  exit 1
else
  pushd $srcdir
fi

# Check for the existence of the GTK environment
if [ ! -d $HOME/gtk ]; then
  exit 1
fi
if [ ! -d $HOME/.local ]; then
  exit 1
fi

# Set up paths necessary to build
export PATH=${buildroot}/pgsql/bin:${HOME}/gtk/inst/bin:${HOME}/.local/bin:${PATH}
export DYLD_LIBRARY_PATH=${buildroot}/pgsql/lib

# Copy the latest libpq libraries into a place the
# bundler can find them...
cp -f ${buildroot}/pgsql/lib/libpq.*.dylib ${HOME}/gtk/inst/lib

# Bundle the pgShapeLoader.app
pushd shp2pgsql-ige-mac-bundle
echo buildroot = $buildroot
export buildroot
jhbuild run ige-mac-bundler ShapeLoader.bundle
checkrv $? "Bundle pgshapeloader"
popd

# Zip up the results and put on the web
pushd ${buildroot}
zip -r9 ${webroot}/new-postgis-osx.zip pgsql
checkrv $? "Bundle zip"
mv -f ${webroot}/new-postgis-osx.zip ${webroot}/postgis-osx.zip
popd

# Exit cleanly
exit 0
    
