#!/bin/bash

# Locate the code directory
SCRIPTPATH=$(cd  $(dirname $0); pwd -P)
BUNDLE=${SCRIPTPATH}/.bundle

# Setup
if [ ! -p "${BUNDLE}/bin" ] ; then
    export PATH="${PATH}:${BUNDLE}/bin"
    export PERL5LIB="${BUNDLE}/lib/perl5"
    export PERL_MB_OPT="--install_base '${BUNDLE}'"
    export PERL_MM_OPT="INSTALL_BASE='${BUNDLE}'"
fi

if [ ! -x "${BUNDLE}/bin/cpanm" ] ; then
    curl -L http://cpanmin.us | perl - -l "${BUNDLE}" App::cpanminus local::lib
fi

eval $(perl -I${BUNDLE}/lib/perl5 -Mlocal::lib)

set +x

# Install Dist Zilla within the local bundle
cpanm -n Dist::Zilla

# Ensure all required DistZilla dependencies are installed
dzil authordeps --missing | cpanm -n

# Ensure all the sark dependencies are installed
dzil listdeps --missing | cpanm -n
