#!/bin/bash

set -eo pipefail

# output config log
echo -e "\tTYPE: ${TYPE}"
echo -e "\tDEFAULT_FIRST_VERSION: ${VERSION}"
echo -e "\tVERBOSE: ${VERBOSE}"

cd "${GITHUB_WORKSPACE}/" || exit 1

# enable debug
if [[ $VERBOSE == 'true' ]]; 
then
    set -x
fi

# fetch tags
git fetch --tags

formatTag="^v\d+\.\d+\.\d+$"

output() {
    echo -e "${1}=${2}" >> "${GITHUB_OUTPUT}"
}

generate_first_tag() {
    echo -e "\tFirst tag version is ${VERSION}"
    git tag v$VERSION
    git push --tags origin v$VERSION
    output "new_tag" $VERSION
}

validate_tag() {
    if [[ ! ${1} =~ $formatTag ]];
    then
        echo -e "\t${1} is invalid version, please, use the follow format - 0.0.0"
        exit 1
    fi
}

parse_version() {
    # get latest version
    latest_version=`git describe --abbrev=0 --tags --match="v[0-9]*"`

    echo -e "\tLatest tag is $latest_version"

    verion_bits=(${latest_version//./ })

    major=`echo ${verion_bits[0]} | sed 's/v//'`
    minor=${verion_bits[1]}
    patch=${verion_bits[2]}

    case $VERSION in
        "major")
            echo -e "\tUpdate major version"
            major=$((major+1))
            minor=0
            patch=0
        ;;
        "minor")
        echo -e "\tUpdate minor version"
            minor=$((minor+1))
            patch=0
        ;;
        "patch")
            echo -e "\tUpdate patch version"
            patch=$((patch+1))
        ;;
        *)
            echo -e "\tInvalid type of version, please, use major, minor or patch"
            exit 1
        ;;
    esac

    NEW_TAG="v$major.$minor.$patch"

    validate_tag $NEW_TAG

    output "tag" $latest_version
    output "new_tag" $NEW_TAG

    echo -e "\tNew tag is $NEW_TAG"
}

is_existed_tag=`git ls-remote --tags origin`

if [[ -z $is_existed_tag ]];
then
    validate_tag $VERSION
    generate_first_tag
    exit 0
fi

commit=`git rev-parse HEAD`
need_tag=`git describe --contains $commit || true`

echo -e "\tCommit is $commit and contains $need_tag"

if [[ -n "$need_tag" ]]; 
then
    echo -e "\tCommit hash already has a tag. Please, create new commit and try again."
    exit 0
fi

parse_version

git tag $NEW_TAG
git push --tag origin $NEW_TAG