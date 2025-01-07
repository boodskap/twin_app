#!/bin/bash
VERSION=1.0.2
flutter clean && flutter build web --no-tree-shake-icons
#docker build -f Dockerfile -t boodskapiot/twin_app:$VERSION build/web
