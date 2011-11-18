#!/bin/bash


if [ $# -ne 1 ]
then
  echo "Usage: `basename $0` release"
  echo "where release is of the form v11, v12, ..."
  exit 1
fi
version=$1
tagname=release-${version}
./git-version.sh ${tagname}

# Commit the version change
git commit autojump

#Create tag
git tag -a ${tagname}

#check for tag existence
git describe release-$1 2>&1 >/dev/null ||
{
    echo "Invalid version $1"
    exit 1
}

git archive --format=tar --prefix autojump_${version}/ ${tagname} | gzip > autojump_${version}.tar.gz
