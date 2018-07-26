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
extension=""
while getopts r:g:a:c:e: OPT; do
  case "${OPT}" in
    r) repo="${OPTARG}";;
    g) group="${OPTARG}";;
    a) artifact="${OPTARG}";;
    c) classifier="${OPTARG}";;
    e) extension="${OPTARG}";;
  esac
done
shift $(( $OPTIND - 1 ))

if [ -z "${repo}" ] || [ -z "${group}" ] || [ -z "${artifact}" ]; then
  usage "-r REPOSITORY -g GROUPID -a ARTIFACTID [-c CLASSIFIER] [-e EXTENSION]"
fi

# find the latest version and build 
ga=${group//./\/}/$artifact
repopath=$repo/$ga
version=`curl -s $repopath/maven-metadata.xml | grep latest | sed "s/.*<latest>\([^<]*\)<\/latest>.*/\1/"`

jar=""

if [ -z "${extension}" ]; then
  extension=jar
fi


artifactVersion=$artifact-$version
artifactSnapShotVersion=$artifact-$version-SNAPSHOT

if [ -z "${classifier}" ]; then
  jar=.$extension
else
  jar=-$classifier.$extension
fi

url=$repopath/$version/$artifactVersion$jar
snapshotUrl=$repopath/$version/$artifactSnapShotVersion$jar

# Download
# echo $url
curl --fail $url && exit 0
