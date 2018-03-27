O=""

for REPO in */
do
	cd $REPO
	echo "REPO: $REPO"
	for VERSION in */
	do
		cd $VERSION
		echo "  VERSION: $VERSION"
			for MODULE in */
			do
				cd $MODULE
				echo "    MODULE: $MODULE"

				cd ..
			done
		cd ..
	done
	cd ..
done


git add .
git commit -am "build"
git push
vapor cloud deploy --build=incremental --env=production -y 

