function generate_docs() {
	REPO_NAME=$1
	MODULE=$2
	VERSION=$3

	# create the unique docs path
	DOCS_PATH=$REPO_NAME/$VERSION/$MODULE
	LATEST_PATH=$REPO_NAME/latest

	echo "💧  Generating docs for $DOCS_PATH"

	# remove these docs if they already exist
	rm -rf $DOCS_PATH

	mkdir code
	cd code
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
		--output ../../$DOCS_PATH

	cd ../../
	rm -rf code
	rm -rf $LATEST_PATH/$MODULE
	mkdir $LATEST_PATH
	cp -R $DOCS_PATH $LATEST_PATH
}

generate_docs $1 $2 $3
