for REPO in */
do
	cd $REPO
	echo "$REPO"
	for VERSION in */
	do
		cd $VERSION
		echo "$VERSION"

		cd ..
	done
	cd ..
done


git add .
git commit -am "build"
git push
vapor cloud deploy --build=incremental --env=production -y 

