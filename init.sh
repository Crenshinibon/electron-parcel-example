#!/bin/bash
export current_year=`date +"%Y"`
export package_author_name=`npm config get init-author-name`
export package_author_email=`npm config get init-author-email`
export package_var=`echo $package_name | sed -r 's/([a-z]+)-([a-z])?([a-z]*)-?([a-z])?([a-z]*)-?([a-z])?([a-z]*)/\1\U\2\L\3\U\4\L\5\U\6\L\7/'`

git config user.email $package_author_email

printf "\n\nPackage description: " && read package_description
export package_description

echo Template repo locally cloned. Running template init procedure.

# create repo on github
gh re --no-browser --new $package_name --user $package_author --description "$package_description"

# change origin remote url
git remote set-url origin https://github.com/$package_author/$package_name.git

echo Rendering templates $(find ./*)

# evaluate templates
for templateFile in $(find ./*); do

  echo rendering template ${templateFile}
  cat $templateFile | envsubst > "${templateFile}.tmp"
  mv -f "${templateFile}.tmp" ${templateFile}
done;

# install dev dependencies
npm i --save-dev `cat ./devDependencies`
rm ./devDependencies
rm init.sh

# push skeleton to GH
git add . --all
git commit -m "$package_name package skeleton"
git push --set-upstream origin master

# enable travis
travis sync
travis enable --no-interactive --repo $package_author/$package_name

# publish skeleton release
npm version patch
git push --follow-tags
npm publish
