git fetch origin gh-pages
git checkout gh-pages
git checkout main
mkdocs gh-deploy --force
pause