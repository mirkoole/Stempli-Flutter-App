#!/bin/zsh

# build android app
flutter build apk
flutter build apk --split-per-abi
flutter build appbundle

cd build/app/intermediates/merged_native_libs/release/out/lib
zip -r native_debug_symbols.zip arm64-v8a armeabi-v7a x86_64
mv native_debug_symbols.zip ~/Downloads
cd -
