O="<h1>Directory Listing</h1>"

for REPO in */
do
	cd $REPO
	O="$O$REPO"
	O="$O<ul>"
	for VERSION in */
	do
		cd $VERSION
		O="$O<li>"
		O="$O$VERSION"
		O="$O<ul>"
			for MODULE in */
			do
				cd $MODULE
				O="$O<li>"
				O="$O<a href=\"/$REPO$VERSION${MODULE}index.html\">$MODULE</a><br>"
				O="$O</li>"
				cd ..
			done
		O="$O</ul>"
		O="$O</li>"
		cd ..
	done
	O="$O</ul>"
	cd ..
done

echo -e $O > index.html;

git add .
git commit -am "build"
git push
vapor cloud deploy --build=incremental --env=production -y 

