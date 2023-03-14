#!/bin/zsh

# deploy web-app to github pages
rm -r docs
flutter clean
flutter build web --base-href /Stempli-Flutter-App/
mv build/web docs
git commit -am "deploy web"
git push

# build android app
flutter build apk
flutter build apk --split-per-abi
flutter build appbundle