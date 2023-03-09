#!/bin/zsh

rm -r docs

flutter clean

flutter build web --base-href /Stempli-Flutter-App/

mv build/web docs

git 