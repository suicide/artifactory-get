#!/bin/bash

# downloads latest version of an artifact from artifactory
# inspired by http://stackoverflow.com/questions/13989033/how-do-i-download-the-latest-artifact-from-artifactory
# THX

set -e

usage(){
  echo "Usage: $*" >&2
  exit 64
}

repo=""
group=""
artifact=""
classifier=""
while getopts r:g:a:c: OPT; do
  case "${OPT}" in
    r) repo="${OPTARG}";;
    g) group="${OPTARG}";;
    a) artifact="${OPTARG}";;
    c) classifier="${OPTARG}";;
  esac
done
shift $(( $OPTIND - 1 ))

if [ -z "${repo}" ] || [ -z "${group}" ] || [ -z "${artifact}" ]; then
  usage "-r REPOSITORY -g GROUPID -a ARTIFACTID [-c CLASSIFIER]"
fi

# find the latest version and build 
ga=${group//./\/}/$artifact
repopath=$repo/$ga
version=`curl -s $repopath/maven-metadata.xml | grep latest | sed "s/.*<latest>\([^<]*\)<\/latest>.*/\1/"`
build=`curl -s $repopath/$version/maven-metadata.xml | grep '<value>' | head -1 | sed "s/.*<value>\([^<]*\)<\/value>.*/\1/"`

jar=""
if [ -z "${classifier}" ]; then
  jar=$artifact-$build.jar
else
  jar=$artifact-$build-$classifier.jar
fi

url=$repopath/$version/$jar

# Download
# echo $url
curl $url
