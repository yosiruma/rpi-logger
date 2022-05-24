cat .gitignore_custom >.gitignore

while read line; do
  curl -sL https://www.toptal.com/developers/gitignore/api/$line >>.gitignore
done <.gitignore_io
