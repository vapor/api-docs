O="[\n"
for REPO in */
do
	cd $REPO
	for VERSION in */
	do
		cd $VERSION
			for MODULE in */
			do
				cd $MODULE
				O+="    {\"repo\": \"${REPO%?}\", \"version\": \"${VERSION%?}\", \"module\": \"${MODULE%?}\"},\n"
				cd ..
			done
		cd ..
	done
	cd ..
done
O=${O%?}
O=${O%?}
O=${O%?}
O+="\n]\n"

echo -e $O > manifest.json;

git add .
git commit -am "build"
git push
vapor cloud deploy --build=incremental --env=production -y 

