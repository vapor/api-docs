#!/bin/sh

function generate-docs {
  # remove the old documentation
  rm -rf /var/www/api-docs/$1/$2
  # generate the new documentation for the given package
  swift doc generate ./packages/$1/Sources --module-name $1 --output /var/www/api-docs/$1/$2
  # allow nginx to serve generated files
  chmod +x /var/www/api-docs/$1
  chmod +x /var/www/api-docs/$1/$2
}

function update-doc {
  #used to get the latest tag, for now we simply use master
  #TAG_NAME=`(cd ~/packages/$1 && git pull > /dev/null 2>&1 && git tag -l | (tail -n1))`
  TAG_NAME=master
  echo "generating docs for $1 at $TAG_NAME"
  generate-docs $1 $TAG_NAME
}

#update swift doc
(cd swift-doc && git pull && make install)

# generate api-docs for all packages in ./packages
for d in ./packages/*
do
  # check if d is a directory
  if [ -d "$d" ]
  then
    update-doc ${d##*/}
  fi
done
