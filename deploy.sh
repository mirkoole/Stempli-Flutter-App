#!/bin/zsh

rm -r docs

flutter create web --base-href /Stempli-Flutter-App/

mv build/web docs
