#!/bin/zsh

rm -r docs

flutter build web --base-href /Stempli-Flutter-App/

mv build/web docs
