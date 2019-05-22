#!/bin/sh

function generate_docs() {
    REPO_NAME=$1
    MODULE=$2
    VERSION=$3
    ROOT=$4

    DOCS_PATH=$REPO_NAME/$VERSION/$MODULE

    echo "    🧩 $MODULE"

    if [[ $MODULE == "COperatingSystem" ]] || 
       [[ $MODULE == "Boilerplate" ]] || 
       [[ $MODULE == "CCryptoOpenSSL" ]] || 
       [[ $MODULE == *"Benchmark" ]] || 
       [[ $MODULE == *"Development" ]]; then
        echo "       skipping module..."
    elif [ -e "$ROOT/$DOCS_PATH/index.html" ] && [ $VERSION != "master" ]; then
        echo "       already exists..."
    elif [ -e "Sources/$MODULE/include" ]; then
        echo "       skipping C module..."
    elif [ -e "Sources/$MODULE/main.swift" ]; then
        echo "       skipping executable..."
    else 
        echo "       building..."
        swift build &> /dev/null

        echo "       sourcekitten doc..."
        sourcekitten doc --spm-module $MODULE > module.json 2> /dev/null

        rm -rf $ROOT/$DOCS_PATH
        mkdir -p $ROOT/$DOCS_PATH
        echo "       jazzy gen..."
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
            --output $ROOT/$DOCS_PATH \
            &> /dev/null

        echo "       done..."
    fi
}

function main() {
    echo "💧 Vapor docs generator"
    ROOT=`pwd`
    declare -a arr=(
        "auth"
        "console"
        "core"
        "crypto"
        "database-kit"
        "fluent"
        "fluent-postgresql"
        "fluent-sqlite"
        "http"
        "jwt"
        "leaf"
        "multipart"
        "mysql"
        "nio-postgres"
        "postgresql"
        "redis"
        "routing"
        "service"
        "sql"
        "sqlite"
        "template-kit"
        "url-encoded-form"
        "validation"
        "vapor"
        "websocket"
    )
    rm -rf .build
    mkdir .build
    cd .build
    for REPO_NAME in "${arr[@]}"
    do
        echo "📦 $REPO_NAME.git"
        git clone git@github.com:vapor/$REPO_NAME.git &> /dev/null
        cd $REPO_NAME

        # all versions
        for VERSION in $(git tag | tail -n 1) 
        do
            echo "  🏷  $VERSION"
            git checkout $VERSION &> /dev/null
            for MODULE in Sources/*
            do
                generate_docs $REPO_NAME `basename $MODULE` $VERSION $ROOT
            done
        done

        # master
        git checkout master &> /dev/null
        echo "  🏷  master"
        for MODULE in Sources/*
        do
            generate_docs $REPO_NAME `basename $MODULE` "master" $ROOT
        done

        cd ../
        rm -rf $REPO_NAME
    done
    cd ../
    rm -rf .build
}

main
