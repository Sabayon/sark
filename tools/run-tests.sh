#!/bin/bash
set -ev

# If we are on the releases branches, do a normal test.
if [ "${TRAVIS_BRANCH}" = "releases" ]; then
  cpanm --installdeps .
  perl Makefile.PL
  make test
else
  # otherwise we do a standard dzil full test
  git config --global user.email "dummy@travis"
  git config --global user.name "dummy"
  source ./tools/bootstrap.sh
  dzil test
fi
