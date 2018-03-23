git add .
git commit -am "build"
git push
vapor cloud deploy --build=incremental --env=production
n
y

