#!/bin/sh

function generate_docs() {
    REPO_NAME=$1
    MODULE=$2
    VERSION=$3
    ROOT=$4

    # create the unique docs path
    DOCS_PATH=$REPO_NAME/$VERSION/$MODULE
    LATEST_PATH=$REPO_NAME/latest/$MODULE

    echo "💧  Generating docs for $DOCS_PATH"
    echo "    in $ROOT/$DOCS_PATH"

    if [ -e "$ROOT/$DOCS_PATH/index.html" ]; then
        echo "$VERSION already exists, skipping..."
    else 
        echo "Starting $VERSION..."
        mkdir -p $ROOT/$DOCS_PATH
        mkdir .build
        cd .build
        git clone -b $VERSION git@github.com:vapor/$REPO_NAME.git
        cd $REPO_NAME

        swift build
        sourcekitten doc --spm-module $MODULE > module.json

        jazzy \
            --clean \
                --sourcekitten-sourcefile module.json \
            --author Vapor \
            --author_url https://vapor.codes \
            --github_url https://github.com/vapor/$REPO_NAME \
            --github-file-prefix https://github.com/vapor/$REPO_NAME/tree/$VERSION \
            --module-version $VERSION \
            --module $MODULE \
            --root-url https://api.vapor.codes/$DOCS_PATH/ \
            --theme fullwidth \
            --output $ROOT/$DOCS_PATH

        cd ../../
        rm -rf .build

        # copy into latest
        rm -rf $ROOT/$LATEST_PATH
        cp -R $ROOT/$DOCS_PATH $ROOT/$LATEST_PATH
    fi
}

function main() {
    ROOT=`pwd`
    declare -a arr=(
        "vapor"
        "nio-postgres"
    )
    rm -rf .build
    mkdir .build
    cd .build
    for REPO_NAME in "${arr[@]}"
    do
        echo "💧  Generating docs for $REPO_NAME"
        git clone git@github.com:vapor/$REPO_NAME.git
        cd $REPO_NAME
        for VERSION in $(git tag | tail -n 1) 
        do
            generate_docs $REPO_NAME "NIOPostgres" $VERSION $ROOT
        done
        cd ../
        rm -rf $REPO_NAME
    done
    cd ../
    rm -rf .build
}

main