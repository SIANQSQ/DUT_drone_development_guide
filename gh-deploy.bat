
git fetch origin gh-pages
git checkout gh-pages          # 如果本地没有该分支，会自动创建并追踪远程
git checkout main
mkdocs gh-deploy